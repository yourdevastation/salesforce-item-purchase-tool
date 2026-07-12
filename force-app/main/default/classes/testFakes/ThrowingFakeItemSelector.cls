@IsTest
public class ThrowingFakeItemSelector implements IItemSelector {
  public List<Item__c> getItemsByFilters(
    String type,
    String family,
    String searchTerm,
    Integer limitSize,
    Integer offsetSize
  ) {
    throw new IllegalArgumentException(
      'Simulated unexpected error in ItemSelector'
    );
  }

  public List<Item__c> getItemsForUpdate(Set<Id> itemIds) {
    throw new IllegalArgumentException(
      'Simulated unexpected error in ItemSelector'
    );
  }

  public List<Item__c> getItemsWithPurchaseLines(Set<Id> itemIds) {
    throw new IllegalArgumentException(
      'Simulated unexpected error in ItemSelector'
    );
  }
}
