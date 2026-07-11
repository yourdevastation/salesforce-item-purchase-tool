public interface ICheckoutUnitOfWork {
  void registerPurchase(Purchase__c purchase);
  void registerPurchaseLine(PurchaseLine__c line);
  void registerItemUpdate(Item__c item);
  void commitWork();
  Id getPurchaseId();
}
