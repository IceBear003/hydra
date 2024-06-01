package validation;

public enum ValidationType {
    RANDOM("随机"),
    FILE("文件");

    public final String name;

    ValidationType(String name) {
        this.name = name;
    }
}
