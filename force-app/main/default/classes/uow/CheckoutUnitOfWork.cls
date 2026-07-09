public with sharing class CheckoutUnitOfWork {
  public Purchase__c purchaseToInsert;
  public List<PurchaseLine__c> linesToInsert = new List<PurchaseLine__c>();
  public List<Item__c> itemsToUpdate = new List<Item__c>();

  public void commitWork() {
    Savepoint sp = Database.setSavepoint();

    try {
      if (purchaseToInsert != null) {
        insert purchaseToInsert;
      }

      if (!linesToInsert.isEmpty()) {
        for (PurchaseLine__c line : linesToInsert) {
          line.PurchaseId__c = purchaseToInsert.Id;
        }
        insert linesToInsert;
      }

      if (!itemsToUpdate.isEmpty()) {
        update itemsToUpdate;
      }
    } catch (Exception e) {
      Database.rollback(sp);
      throw e;
    }
  }
}
