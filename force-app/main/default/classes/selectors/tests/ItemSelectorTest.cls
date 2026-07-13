@IsTest
@SuppressWarnings('PMD.AvoidHardcodingId, PMD.ApexUnitTestClassShouldHaveRunAs')
// Real DML runs under the standard test user. No FLS/sharing rules are configured
// per project requirements, so System.runAs() does not add any coverage signal.
private class ItemSelectorTest {
  private static final Integer DEFAULT_LIMIT = 200;
  private static final Integer DEFAULT_OFFSET = 0;

  private static List<Item__c> callSelector(
    String type,
    String family,
    String searchTerm
  ) {
    return new ItemSelector()
      .getItemsByFilters(
        type,
        family,
        searchTerm,
        DEFAULT_LIMIT,
        DEFAULT_OFFSET
      );
  }

  @IsTest
  static void getItemsByFilters_returnsOnlyMatchingType_whenFilteredByType() {
    Item__c type1Item = new Item__c(
      Name = 'Type1 Item',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 1'
    );
    Item__c type2Item = new Item__c(
      Name = 'Type2 Item',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 2',
      Family__c = 'Family 1'
    );
    insert new List<Item__c>{ type1Item, type2Item };

    Test.startTest();
    List<Item__c> results = callSelector('Type 1', null, null);
    Test.stopTest();

    System.assertEquals(1, results.size(), 'Expected exactly one Type 1 item');
    System.assertEquals('Type1 Item', results[0].Name);
  }

  @IsTest
  static void getItemsByFilters_returnsOnlyMatchingFamily_whenFilteredByFamily() {
    Item__c fam1Item = new Item__c(
      Name = 'Fam1 Item',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 1'
    );
    Item__c fam2Item = new Item__c(
      Name = 'Fam2 Item',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 2'
    );
    insert new List<Item__c>{ fam1Item, fam2Item };

    Test.startTest();
    List<Item__c> results = callSelector(null, 'Family 2', null);
    Test.stopTest();

    System.assertEquals(
      1,
      results.size(),
      'Expected exactly one Family 2 item'
    );
    System.assertEquals('Fam2 Item', results[0].Name);
  }

  @IsTest
  static void getItemsByFilters_returnsMatchingNameAndDescription_whenFilteredBySearchTerm() {
    Item__c nameMatch = new Item__c(
      Name = 'Gadget Pro',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 1',
      Description__c = 'Nothing special'
    );
    Item__c descMatch = new Item__c(
      Name = 'Generic Item',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 1',
      Description__c = 'Contains Gadget word in description'
    );
    Item__c noMatch = new Item__c(
      Name = 'Unrelated',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 1',
      Description__c = 'Nothing'
    );
    insert new List<Item__c>{ nameMatch, descMatch, noMatch };

    Test.startTest();
    List<Item__c> results = callSelector(null, null, 'Gadget');
    Test.stopTest();

    System.assertEquals(
      2,
      results.size(),
      'Expected both name-match and description-match items'
    );
  }

  @IsTest
  static void getItemsByFilters_returnsOnlyIntersection_whenAllFiltersApplied() {
    Item__c target = new Item__c(
      Name = 'Target Widget',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 1',
      Description__c = 'Special item'
    );
    Item__c wrongType = new Item__c(
      Name = 'Target Widget',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 2',
      Family__c = 'Family 1'
    );
    Item__c wrongFamily = new Item__c(
      Name = 'Target Widget',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 2'
    );
    insert new List<Item__c>{ target, wrongType, wrongFamily };

    Test.startTest();
    List<Item__c> results = callSelector('Type 1', 'Family 1', 'Target');
    Test.stopTest();

    System.assertEquals(
      1,
      results.size(),
      'Expected exactly one item matching all three filters'
    );
    System.assertEquals(target.Id, results[0].Id);
  }

  @IsTest
  static void getItemsByFilters_returnsAllItems_whenNoFiltersApplied() {
    List<Item__c> items = new List<Item__c>();
    for (Integer i = 0; i < 5; i++) {
      items.add(
        new Item__c(
          Name = 'Item ' + i,
          Price__c = 10,
          AvailableQuantity__c = 5,
          Type__c = 'Type 1',
          Family__c = 'Family 1'
        )
      );
    }
    insert items;

    Test.startTest();
    List<Item__c> results = callSelector(null, null, null);
    Test.stopTest();

    System.assertEquals(5, results.size(), 'Expected all 5 items returned');
  }

  @IsTest
  static void getItemsByFilters_returnsEmptyList_whenNoMatchFound() {
    insert TestDataFactory.buildItem('Alpha', 10, 5);

    Test.startTest();
    List<Item__c> results = callSelector(
      'Type 1',
      'Family 1',
      'ZZZ_NonExistent'
    );
    Test.stopTest();

    System.assert(results.isEmpty(), 'Expected empty result when no match');
  }

  @IsTest
  static void getItemsByFilters_escapesLikeSpecialChars_whenSearchTermContainsPercentSign() {
    Item__c specialItem = new Item__c(
      Name = '50% Off Sale',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 1'
    );
    Item__c normalItem = new Item__c(
      Name = 'Normal Item',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 1'
    );
    insert new List<Item__c>{ specialItem, normalItem };

    Test.startTest();
    List<Item__c> results = callSelector(null, null, '50%');
    Test.stopTest();

    System.assertEquals(
      1,
      results.size(),
      'LIKE escaping must return only the exact match with % in the name'
    );
    System.assertEquals(specialItem.Id, results[0].Id);
  }

  @IsTest
  static void getItemsByFilters_escapesLikeSpecialChars_whenSearchTermContainsUnderscore() {
    Item__c underscoreItem = new Item__c(
      Name = 'Item_A Special',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 1'
    );
    Item__c normalItem = new Item__c(
      Name = 'ItemXA Normal',
      Price__c = 10,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 1'
    );
    insert new List<Item__c>{ underscoreItem, normalItem };

    Test.startTest();
    List<Item__c> results = callSelector(null, null, 'Item_A');
    Test.stopTest();

    System.assertEquals(
      1,
      results.size(),
      'LIKE escaping must match only the item with underscore in name, not wildcard-match ItemXA'
    );
    System.assertEquals(underscoreItem.Id, results[0].Id);
  }

  @IsTest
  static void getItemsByFilters_respectsPagination_whenLimitAndOffsetAreSet() {
    List<Item__c> items = new List<Item__c>();
    for (Integer i = 0; i < 5; i++) {
      items.add(
        new Item__c(
          Name = 'Page Item ' + i,
          Price__c = 10,
          AvailableQuantity__c = 5,
          Type__c = 'Type 1',
          Family__c = 'Family 1'
        )
      );
    }
    insert items;

    Test.startTest();
    List<Item__c> page1 = new ItemSelector()
      .getItemsByFilters(null, null, null, 2, 0);
    List<Item__c> page2 = new ItemSelector()
      .getItemsByFilters(null, null, null, 2, 2);
    Test.stopTest();

    System.assertEquals(2, page1.size(), 'Page 1 should have 2 items');
    System.assertEquals(2, page2.size(), 'Page 2 should have 2 items');
    System.assertNotEquals(page1[0].Id, page2[0].Id, 'Pages must be disjoint');
  }

  @IsTest
  static void getItemsByFilters_returnsLessThanLimit_whenOffsetExceedsTotalCount() {
    TestDataFactory.insertItems(3, 5);

    Test.startTest();
    List<Item__c> results = new ItemSelector()
      .getItemsByFilters(null, null, null, 10, 5);
    Test.stopTest();

    System.assert(
      results.isEmpty(),
      'Offset beyond total count should return empty list'
    );
  }

  @IsTest
  static void getItemsForUpdate_returnsItems_whenValidIdsProvided() {
    Item__c item1 = TestDataFactory.insertItem('ForUpdate Item 1', 20, 10);
    Item__c item2 = TestDataFactory.insertItem('ForUpdate Item 2', 30, 5);

    Test.startTest();
    List<Item__c> results = new ItemSelector()
      .getItemsForUpdate(new Set<Id>{ item1.Id, item2.Id });
    Test.stopTest();

    System.assertEquals(2, results.size(), 'Expected both items returned');
  }

  @IsTest
  static void getItemsForUpdate_returnsEmpty_whenNonExistentIdsProvided() {
    Id fakeId = '01t000000000001AAA';

    Test.startTest();
    List<Item__c> results = new ItemSelector()
      .getItemsForUpdate(new Set<Id>{ fakeId });
    Test.stopTest();

    System.assert(
      results.isEmpty(),
      'Non-existent ids must return empty list without exception'
    );
  }

  @IsTest
  static void getItemsWithPurchaseLines_returnsItemsWithRelatedLines() {
    Account acc = TestDataFactory.insertAccount('UOW Test Corp');
    Item__c itemWithLine = TestDataFactory.insertItem('Item With Line', 15, 10);

    Purchase__c purchase = new Purchase__c(ClientId__c = acc.Id);
    insert purchase;

    PurchaseLine__c line = new PurchaseLine__c(
      PurchaseId__c = purchase.Id,
      ItemId__c = itemWithLine.Id,
      Amount__c = 30,
      UnitCost__c = 15
    );
    insert line;

    Test.startTest();
    List<Item__c> results = new ItemSelector()
      .getItemsWithPurchaseLines(new Set<Id>{ itemWithLine.Id });
    Test.stopTest();

    System.assertEquals(
      1,
      results.size(),
      'Expected only the item with related purchase line'
    );
    System.assertEquals(
      itemWithLine.Id,
      results[0].Id,
      'Returned item must match the one with related purchase line'
    );
  }
}
