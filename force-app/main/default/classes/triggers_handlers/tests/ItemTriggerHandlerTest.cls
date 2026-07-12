@IsTest
private class ItemTriggerHandlerTest {
  @IsTest
  static void beforeDelete_allowsDeletion_whenItemHasNoPurchaseHistory() {
    AppFactory.reset();

    Item__c item = TestDataFactory.insertItem('Deletable Item', 10, 5);

    Test.startTest();
    Boolean exceptionThrown = false;
    try {
      delete item;
    } catch (DmlException e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(
      !exceptionThrown,
      'Item with no purchase history must be deletable without error'
    );

    List<Item__c> remaining = [SELECT Id FROM Item__c WHERE Id = :item.Id];
    System.assert(
      remaining.isEmpty(),
      'Item must be fully deleted from the database'
    );
  }

  @IsTest
  static void beforeDelete_blocksDeletion_whenItemHasPurchaseHistory() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('History Corp');
    Item__c item = TestDataFactory.insertItem('Historical Item', 50, 10);
    Purchase__c purchase = TestDataFactory.insertPurchase(acc.Id);

    PurchaseLine__c line = new PurchaseLine__c(
      PurchaseId__c = purchase.Id,
      ItemId__c = item.Id,
      Amount__c = 1,
      UnitCost__c = 50
    );
    insert line;

    Test.startTest();
    Boolean errorOccurred = false;
    try {
      delete item;
    } catch (DmlException e) {
      errorOccurred = true;
      System.assert(
        e.getMessage().contains('Cannot delete'),
        'Error message must explain why deletion is blocked'
      );
    }
    Test.stopTest();

    System.assert(
      errorOccurred,
      'Item with purchase history must be blocked from deletion'
    );

    List<Item__c> remaining = [SELECT Id FROM Item__c WHERE Id = :item.Id];
    System.assertEquals(
      1,
      remaining.size(),
      'Item with purchase history must still exist after blocked delete'
    );
  }

  @IsTest
  static void beforeDelete_partialSuccess_whenSomeItemsHaveHistoryAndSomeDont() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Bulk Trigger Corp');
    Item__c protectedItem = TestDataFactory.insertItem('Protected Item', 30, 5);
    Item__c deletableItem = TestDataFactory.insertItem(
      'Deletable Item 2',
      30,
      5
    );

    Purchase__c purchase = TestDataFactory.insertPurchase(acc.Id);
    PurchaseLine__c line = new PurchaseLine__c(
      PurchaseId__c = purchase.Id,
      ItemId__c = protectedItem.Id,
      Amount__c = 1,
      UnitCost__c = 30
    );
    insert line;

    List<Item__c> bulkDeletable = new List<Item__c>();
    for (Integer i = 0; i < 9; i++) {
      bulkDeletable.add(
        new Item__c(
          Name = 'Bulk Deletable ' + i,
          Price__c = 10,
          AvailableQuantity__c = 5,
          Type__c = 'Type 1',
          Family__c = 'Family 1'
        )
      );
    }
    insert bulkDeletable;
    bulkDeletable.add(deletableItem);

    List<Item__c> allToDelete = new List<Item__c>(bulkDeletable);
    allToDelete.add(protectedItem);

    Test.startTest();
    List<Database.DeleteResult> results = Database.delete(allToDelete, false);
    Test.stopTest();

    Integer successCount = 0;
    Integer failureCount = 0;
    for (Database.DeleteResult dr : results) {
      if (dr.isSuccess()) {
        successCount++;
      } else {
        failureCount++;
        System.assert(
          dr.getErrors()[0].getMessage().contains('Cannot delete'),
          'Failure must be the trigger-blocked item with purchase history'
        );
      }
    }

    System.assertEquals(
      10,
      successCount,
      '10 items without history must be deleted successfully'
    );
    System.assertEquals(
      1,
      failureCount,
      'Exactly 1 item with history must fail to delete'
    );

    List<Item__c> remaining = [
      SELECT Id
      FROM Item__c
      WHERE Id = :protectedItem.Id
    ];
    System.assertEquals(
      1,
      remaining.size(),
      'Protected item must still exist after partial delete'
    );
  }

  @IsTest
  static void beforeDelete_handles200Items_withinGovernorLimits() {
    AppFactory.reset();

    List<Item__c> items = TestDataFactory.insertItems(200, 5);

    Test.startTest();
    List<Database.DeleteResult> results = Database.delete(items, false);
    Test.stopTest();

    Integer successCount = 0;
    for (Database.DeleteResult dr : results) {
      if (dr.isSuccess()) {
        successCount++;
      }
    }
    System.assertEquals(
      200,
      successCount,
      'All 200 items without purchase history must be deleted within governor limits'
    );
  }
}
