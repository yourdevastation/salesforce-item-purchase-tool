@IsTest
public class FakeCheckoutUnitOfWork implements ICheckoutUnitOfWork {
  public Boolean commitWorkWasCalled = false;
  public Id purchaseIdToReturn;

  public List<Purchase__c> registeredPurchases = new List<Purchase__c>();
  public List<PurchaseLine__c> registeredLines = new List<PurchaseLine__c>();
  public List<Item__c> registeredItemUpdates = new List<Item__c>();

  public void registerPurchase(Purchase__c purchase) {
    registeredPurchases.add(purchase);
  }

  public void registerPurchaseLine(PurchaseLine__c line) {
    registeredLines.add(line);
  }

  public void registerItemUpdate(Item__c item) {
    registeredItemUpdates.add(item);
  }

  public void commitWork() {
    commitWorkWasCalled = true;
  }

  public Id getPurchaseId() {
    return purchaseIdToReturn;
  }
}
