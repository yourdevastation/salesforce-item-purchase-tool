@IsTest
public class FakeItemSelector implements IItemSelector {
  public List<Item__c> itemsToReturn = new List<Item__c>();
  public List<Item__c> itemsForUpdateToReturn = new List<Item__c>();
  public List<Item__c> itemsWithPurchaseLinesToReturn = new List<Item__c>();

  public List<Item__c> getItemsByFilters(
    String type,
    String family,
    String searchTerm,
    Integer limitSize,
    Integer offsetSize
  ) {
    return itemsToReturn;
  }

  public List<Item__c> getItemsForUpdate(Set<Id> itemIds) {
    return itemsForUpdateToReturn;
  }

  public List<Item__c> getItemsWithPurchaseLines(Set<Id> itemIds) {
    return itemsWithPurchaseLinesToReturn;
  }
}
