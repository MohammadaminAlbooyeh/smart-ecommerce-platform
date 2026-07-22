public class Cat{
    private String name;
    private int age;

    public void setName(String n){
        name = n;
    }
    public void setAge(int a){
        age = a;
    }
    public String getName(){
        return name;
    }
    public int getAge(){
        return age;
    }
    public static void main(String args[]){
        Cat cat = new Cat();
        
        cat.setName("Whiskers");
        cat.setAge(3);
        
        System.out.println("Name: " + cat.getName());
        System.out.println("Age: " + cat.getAge());
    }
}