public class Main {
    public static void main(String[] args) {
        double ans= 0.0;
        for(int i=32;i<=128;i++){
            ans+= (i + 0.0) / (8.0 * Math.ceil(i / 8.0));
        }
        System.out.println(ans / (128 - 32 + 1));
    }
}
