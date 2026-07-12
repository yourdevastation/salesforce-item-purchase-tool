@IsTest
private class ItemCatalogUnitOfWorkTest {
  @IsTest
  static void commitWork_insertsItem_whenItemRegistered() {
    Item__c newItem = TestDataFactory.buildItem('Catalog Widget', 99.99, 10);

    ItemCatalogUnitOfWork uow = new ItemCatalogUnitOfWork();
    uow.registerNew(newItem);

    Test.startTest();
    uow.commitWork();
    Test.stopTest();

    List<Item__c> inserted = [
      SELECT Id, Name, Price__c
      FROM Item__c
      WHERE Name = 'Catalog Widget'
    ];
    System.assertEquals(
      1,
      inserted.size(),
      'Exactly one item must be inserted'
    );
    System.assertEquals(
      99.99,
      inserted[0].Price__c,
      'Price must be persisted correctly'
    );
  }

  @IsTest
  static void commitWork_clearsInternalList_afterInsert() {
    Item__c item = TestDataFactory.buildItem('One-Time Item', 10, 5);

    ItemCatalogUnitOfWork uow = new ItemCatalogUnitOfWork();
    uow.registerNew(item);

    Test.startTest();
    uow.commitWork();
    // Second commitWork should be a no-op (list already cleared)
    uow.commitWork();
    Test.stopTest();

    List<Item__c> items = [SELECT Id FROM Item__c WHERE Name = 'One-Time Item'];
    System.assertEquals(
      1,
      items.size(),
      'Calling commitWork a second time must not insert the record again'
    );
  }

  @IsTest
  static void commitWork_insertsMultipleItems_whenMultipleRegistered() {
    ItemCatalogUnitOfWork uow = new ItemCatalogUnitOfWork();
    uow.registerNew(TestDataFactory.buildItem('Multi Item A', 10, 5));
    uow.registerNew(TestDataFactory.buildItem('Multi Item B', 20, 3));

    Test.startTest();
    uow.commitWork();
    Test.stopTest();

    List<Item__c> items = [
      SELECT Id
      FROM Item__c
      WHERE Name IN ('Multi Item A', 'Multi Item B')
    ];
    System.assertEquals(
      2,
      items.size(),
      'Both registered items must be inserted'
    );
  }
}
