public class Country {
    private String name;
    private int population;
    
    public Country(){
        name = "Iran";
    }

    public Country(int number){
        this();
        population = number;
    }

    public Country(String name, int number){
        this(number);
        this.name = name;
    }

    public static void main(String[] args) {
        Country c1 = new Country();
        Country c2 = new Country(1000000);
        Country c3 = new Country("Persia", 500000);
        
        System.out.println("Default country: " + c1.name + ", Population: " + c1.population);
        System.out.println("Number-only country: " + c2.name + ", Population: " + c2.population);
        System.out.println("Full constructor country: " + c3.name + ", Population: " + c3.population);
    }
}