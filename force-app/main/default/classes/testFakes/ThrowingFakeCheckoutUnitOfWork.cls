@IsTest
public class ThrowingFakeCheckoutUnitOfWork implements ICheckoutUnitOfWork {
  public void registerPurchase(Purchase__c purchase) {
  }
  public void registerPurchaseLine(PurchaseLine__c line) {
  }
  public void registerItemUpdate(Item__c item) {
  }

  public void commitWork() {
    throw new IllegalArgumentException(
      'Simulated unexpected error in CheckoutUnitOfWork'
    );
  }

  public Id getPurchaseId() {
    return null;
  }
}
