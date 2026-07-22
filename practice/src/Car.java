public class Car{
    private Engine engine;
    private Tyre[] tyres;

    public Car(){
        engine = new Engine();
        tyres = new Tyre[4];
        for (int i =0; i < tyres.length; i++) {
            tyres[i] = new Tyre();
        }
    }
}