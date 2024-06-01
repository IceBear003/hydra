public class Main {
    public static void main(String[] args) {
        for (int i = 0; i < 100000; i++) {
            System.out.print("\r" + i + "%"); // 打印进度百分比，并使用\r返回行首
            System.out.flush(); // 刷新输出缓冲区，确保立即显示
            try {
                Thread.sleep(100); // 模拟一些处理过程
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
    }
}