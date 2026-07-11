public interface IItemSelector {
  List<Item__c> getItemsByFilters(
    String type,
    String family,
    String searchTerm,
    Integer limitSize,
    Integer offsetSize
  );
  List<Item__c> getItemsForUpdate(Set<Id> itemIds);
  List<Item__c> getItemsWithPurchaseLines(Set<Id> itemIds);
}
