package validation;

public class Validation {
    public ValidationType type;
    public ValidationLevel level;

    public Validation(ValidationType type, ValidationLevel level){
        this.type = type;
        this.level = level;
    }
}
