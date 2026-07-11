public with sharing class ItemTriggerHandler {
  public static void beforeDelete(List<Item__c> oldItems) {
    preventDeletionWithPurchaseHistory(oldItems);
  }

  private static void preventDeletionWithPurchaseHistory(
    List<Item__c> itemsToDelete
  ) {
    IItemSelector selector = AppFactory.getItemSelector();
    Map<Id, Item__c> itemsMap = new Map<Id, Item__c>(itemsToDelete);

    List<Item__c> itemsFromDb = selector.getItemsWithPurchaseLines(
      itemsMap.keySet()
    );

    for (Item__c dbItem : itemsFromDb) {
      if (!dbItem.Purchase_Lines__r.isEmpty()) {
        itemsMap.get(dbItem.Id)
          .addError(
            'Cannot delete this Item because it is part of a completed Purchase history.'
          );
      }
    }
  }
}
