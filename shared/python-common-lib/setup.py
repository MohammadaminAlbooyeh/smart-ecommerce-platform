from setuptools import setup, find_packages

setup(
    name="platform-common-lib",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "pydantic>=2.0",
        "kafka-python>=2.0",
    ],
    python_requires=">=3.10",
)
