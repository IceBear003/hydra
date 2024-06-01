package validation;

public enum ValidationLevel {
    AVERAGE("普通"),
    STRESS_ONE_PORT("单端口压力"),
    STRESS_MULTI_PORT("多端口压力");

    public final String name;

    ValidationLevel(String name) {
        this.name = name;
    }
}
