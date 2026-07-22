public class Circle {
    private double radius;

    public double getArea() {
        return radius * radius * 3.14;
    }

    public Circle(double r){
        radius = r;
    }

    public static void main(String[] args){
        Circle c = new Circle(2);
        System.out.println(c.getArea());
    }
}