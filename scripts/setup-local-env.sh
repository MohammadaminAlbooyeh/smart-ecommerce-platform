#!/usr/bin/env bash
set -euo pipefail

# setup-local-env.sh — clone, build, and run all sibling service repos + infrastructure.
# Usage: ./scripts/setup-local-env.sh [--skip-clone] [--skip-build] [--skip-infra]

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PARENT_DIR="$(dirname "$ROOT_DIR")"
GITHUB_ORG="${GITHUB_ORG:-MohammadaminAlbooyeh}"

SERVICES=(
  "payment-switch-gateway"
  "order-service"
  "inventory-service"
  "cart-service"
  "product-search-engine"
  "recommendation_engine"
  "real_time_fraud_detection_system"
  "real_time_analytics_dashboard"
  "user-service"
)

SKIP_CLONE=false
SKIP_BUILD=false
SKIP_INFRA=false

for arg in "$@"; do
  case "$arg" in
    --skip-clone)  SKIP_CLONE=true ;;
    --skip-build)  SKIP_BUILD=true ;;
    --skip-infra)  SKIP_INFRA=true ;;
    *) echo "Unknown flag: $arg"; exit 1 ;;
  esac
done

echo "==> Parent directory for service repos: $PARENT_DIR"

clone_service() {
  local service="$1"
  local url="https://github.com/${GITHUB_ORG}/${service}.git"
  echo "==> Cloning $service from $url ..."
  git clone --depth 1 "$url" "$PARENT_DIR/$service" 2>/dev/null || {
    echo "    [WARN] Could not clone $service (repo may not exist or is private). Skipping."
  }
}

build_service() {
  local service="$1"
  local path="$PARENT_DIR/$service"
  if [ ! -d "$path" ]; then return; fi
  echo "==> Building $service ..."
  if [ -f "$path/pom.xml" ]; then
    (cd "$path" && mvn -q -DskipTests package) || echo "    [WARN] Maven build failed for $service"
  elif [ -f "$path/build.gradle" ] || [ -f "$path/build.gradle.kts" ]; then
    (cd "$path" && ./gradlew -q build -x test) || echo "    [WARN] Gradle build failed for $service"
  elif [ -f "$path/Dockerfile" ]; then
    echo "    [INFO] $service has Dockerfile, will build via docker compose."
  elif [ -f "$path/setup.py" ] || [ -f "$path/pyproject.toml" ]; then
    (cd "$path" && pip install -q -e .) || echo "    [WARN] pip install failed for $service"
  else
    echo "    [INFO] No build tool detected for $service, skipping."
  fi
}

# Step 1: Clone missing service repos
if [ "$SKIP_CLONE" = false ]; then
  for service in "${SERVICES[@]}"; do
    if [ ! -d "$PARENT_DIR/$service" ]; then
      clone_service "$service"
    else
      echo "==> $service already exists, skipping clone."
    fi
  done
fi

# Step 2: Build each service
if [ "$SKIP_BUILD" = false ]; then
  for service in "${SERVICES[@]}"; do
    if [ -d "$PARENT_DIR/$service" ]; then
      build_service "$service"
    fi
  done
fi

# Step 3: Copy .env.example to .env if not present
if [ ! -f "$ROOT_DIR/.env" ] && [ -f "$ROOT_DIR/.env.example" ]; then
  echo "==> Creating .env from .env.example ..."
  cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
  echo "    [INFO] Edit .env to set JWT_SECRET and other credentials before running."
fi

# Step 4: Start infrastructure
if [ "$SKIP_INFRA" = false ]; then
  echo "==> Starting infrastructure (postgres, redis, kafka, elasticsearch) ..."
  docker compose -f "$ROOT_DIR/infrastructure/docker-compose/docker-compose.full.yml" up -d
  echo "==> Infrastructure is up."
  echo "==> To start app services, run:"
  echo "    docker compose -f infrastructure/docker-compose/docker-compose.full.yml up --build"
fi

echo "==> Setup complete!"
