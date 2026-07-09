public class CheckoutExceptions {
  public virtual class CheckoutException extends Exception {
  }

  public class EmptyCartException extends CheckoutException {
  }
  public class ItemNotFoundException extends CheckoutException {
  }
  public class InsufficientStockException extends CheckoutException {
  }
}
