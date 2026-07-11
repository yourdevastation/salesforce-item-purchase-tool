public with sharing class CheckoutUnitOfWork implements ICheckoutUnitOfWork {
  private Purchase__c purchaseToInsert;
  private List<PurchaseLine__c> linesToInsert = new List<PurchaseLine__c>();
  private List<Item__c> itemsToUpdate = new List<Item__c>();

  public void registerPurchase(Purchase__c purchase) {
    this.purchaseToInsert = purchase;
  }

  public void registerPurchaseLine(PurchaseLine__c line) {
    this.linesToInsert.add(line);
  }

  public void registerItemUpdate(Item__c item) {
    this.itemsToUpdate.add(item);
  }

  public Id getPurchaseId() {
    return this.purchaseToInsert != null ? this.purchaseToInsert.Id : null;
  }

  public void commitWork() {
    System.Savepoint sp = Database.setSavepoint();
    try {
      if (purchaseToInsert != null) {
        SObjectAccessDecision decision = Security.stripInaccessible(
          AccessType.CREATABLE,
          new List<Purchase__c>{ purchaseToInsert }
        );
        Database.insert(decision.getRecords(), AccessLevel.USER_MODE);
        purchaseToInsert = (Purchase__c) decision.getRecords()[0];
      }

      for (PurchaseLine__c line : linesToInsert) {
        line.PurchaseId__c = purchaseToInsert.Id;
      }

      if (!linesToInsert.isEmpty()) {
        SObjectAccessDecision lines = Security.stripInaccessible(
          AccessType.CREATABLE,
          linesToInsert
        );
        Database.insert(lines.getRecords(), AccessLevel.USER_MODE);
      }

      if (!itemsToUpdate.isEmpty()) {
        SObjectAccessDecision items = Security.stripInaccessible(
          AccessType.UPDATABLE,
          itemsToUpdate
        );
        Database.update(items.getRecords(), AccessLevel.USER_MODE);
      }
    } catch (Exception e) {
      Database.rollback(sp);
      throw e;
    }
  }
}
