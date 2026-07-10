public class CheckoutExceptions {
  public virtual class CheckoutException extends Exception {
  }

  public class EmptyCartException extends CheckoutException {
  }
  public class ItemNotFoundException extends CheckoutException {
  }
  public class InsufficientStockException extends CheckoutException {
  }
  public class InvalidQuantityException extends CheckoutException {
  }
  public class AccountIdMissingException extends CheckoutException {
  }
  public class CartLimitExceededException extends CheckoutException {
  }
  public class InvalidAccountIdException extends CheckoutException {
  }
}
