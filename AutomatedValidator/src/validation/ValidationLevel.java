package validation;

public enum ValidationLevel {
    AVERAGE("普通"),
    BURST_ONE_PORT("单端口突发传输"),
    //TODO：数突发端口数量
    BURST_MULTI_PORT("多端口突发传输"),
    CONTINUOUS_BURST_ONE_PORT("单端口连续突发传输"),
    //TODO：数突发端口数量
    CONTINUOUS_BURST_MULTI_PORT("多端口连续突发传输");

    public final String name;

    ValidationLevel(String name) {
        this.name = name;
    }
}
