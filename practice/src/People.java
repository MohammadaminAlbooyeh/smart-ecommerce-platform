public class People{

    private String name;
    private int age;
    private String job;
    public void setName(String n){
        name = n;
    }
    public void setAge(int a){
        age = a;
    }
    public void setJob(String j){
        job = j;
    }
    public String getName(){
        return name;
    }
    public int getAge(){
        return age;
    }
    public String getJob(){
        return job;
    }

    public static void main(String args[]){
        People person = new People();
        
        person.setName("John");
        person.setAge(30);
        person.setJob("Developer");
        
        System.out.println("Name: " + person.getName());
        System.out.println("Age: " + person.getAge());
        System.out.println("Job: " + person.getJob());
    }
}