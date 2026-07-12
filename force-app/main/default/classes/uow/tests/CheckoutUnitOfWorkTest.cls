@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
// Real DML runs under the standard test user. No FLS/sharing rules are configured
// per project requirements, so System.runAs() does not add any coverage signal.
private class CheckoutUnitOfWorkTest {
  @IsTest
  static void commitWork_createsPurchaseWithLines_whenValidDataRegistered() {
    Account acc = TestDataFactory.insertAccount('UOW Test Corp');
    Item__c item = TestDataFactory.insertItem('UOW Widget', 25.00, 10);

    CheckoutUnitOfWork uow = new CheckoutUnitOfWork();
    uow.registerPurchase(new Purchase__c(ClientId__c = acc.Id));
    uow.registerPurchaseLine(
      new PurchaseLine__c(
        ItemId__c = item.Id,
        Amount__c = 2,
        UnitCost__c = 25.00
      )
    );
    uow.registerItemUpdate(new Item__c(Id = item.Id, AvailableQuantity__c = 8));

    Test.startTest();
    uow.commitWork();
    Test.stopTest();

    Id purchaseId = uow.getPurchaseId();
    System.assertNotEquals(
      null,
      purchaseId,
      'Purchase Id must be populated after commitWork'
    );

    List<Purchase__c> purchases = [
      SELECT Id, ClientId__c
      FROM Purchase__c
      WHERE Id = :purchaseId
    ];
    System.assertEquals(
      1,
      purchases.size(),
      'Exactly one Purchase must be created'
    );
    System.assertEquals(
      acc.Id,
      purchases[0].ClientId__c,
      'Purchase must be linked to the correct Account'
    );

    List<PurchaseLine__c> lines = [
      SELECT Id, PurchaseId__c, Amount__c, UnitCost__c, ItemId__c
      FROM PurchaseLine__c
      WHERE PurchaseId__c = :purchaseId
    ];
    System.assertEquals(
      1,
      lines.size(),
      'Exactly one PurchaseLine must be created'
    );
    System.assertEquals(
      item.Id,
      lines[0].ItemId__c,
      'PurchaseLine must reference the correct Item'
    );
    System.assertEquals(
      2,
      lines[0].Amount__c,
      'PurchaseLine amount must match registered value'
    );
    System.assertEquals(
      25.00,
      lines[0].UnitCost__c,
      'PurchaseLine unit cost must match registered value'
    );

    Item__c updatedItem = [
      SELECT AvailableQuantity__c
      FROM Item__c
      WHERE Id = :item.Id
    ];
    System.assertEquals(
      8,
      updatedItem.AvailableQuantity__c,
      'Item stock must be decremented'
    );
  }

  @IsTest
  static void commitWork_setsPurchaseIdOnLines_beforeInsertingLines() {
    Account acc = TestDataFactory.insertAccount('FK Test Corp');
    Item__c item = TestDataFactory.insertItem('FK Widget', 10, 5);

    CheckoutUnitOfWork uow = new CheckoutUnitOfWork();
    uow.registerPurchase(new Purchase__c(ClientId__c = acc.Id));

    for (Integer i = 0; i < 3; i++) {
      uow.registerPurchaseLine(
        new PurchaseLine__c(
          ItemId__c = item.Id,
          Amount__c = 1,
          UnitCost__c = 10
        )
      );
    }

    Test.startTest();
    uow.commitWork();
    Test.stopTest();

    Id purchaseId = uow.getPurchaseId();
    List<PurchaseLine__c> lines = [
      SELECT PurchaseId__c
      FROM PurchaseLine__c
      WHERE PurchaseId__c = :purchaseId
    ];
    System.assertEquals(
      3,
      lines.size(),
      'All 3 lines must have the FK set and be inserted'
    );
  }

  @IsTest
  static void commitWork_rollsBackEntireTransaction_whenDmlFails() {
    Account acc = TestDataFactory.insertAccount('Rollback Corp');
    Item__c item = TestDataFactory.insertItem('Rollback Widget', 15.00, 10);

    CheckoutUnitOfWork uow = new CheckoutUnitOfWork();
    uow.registerPurchase(new Purchase__c(ClientId__c = acc.Id));
    uow.registerItemUpdate(new Item__c(Id = item.Id, AvailableQuantity__c = 5));
    uow.registerPurchaseLine(
      new PurchaseLine__c(
        ItemId__c = null, // null violates Master-Detail required field
        Amount__c = 1,
        UnitCost__c = 15.00
      )
    );

    Test.startTest();
    Boolean exceptionThrown = false;
    try {
      uow.commitWork();
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(
      exceptionThrown,
      'commitWork must re-throw the caught exception'
    );

    List<Purchase__c> purchases = [
      SELECT Id
      FROM Purchase__c
      WHERE ClientId__c = :acc.Id
    ];
    System.assert(
      purchases.isEmpty(),
      'Savepoint rollback must prevent Purchase__c from being committed'
    );
  }

  @IsTest
  static void commitWork_handles100Lines_withinGovernorLimits() {
    Account acc = TestDataFactory.insertAccount('Bulk Corp');
    Item__c item = TestDataFactory.insertItem('Bulk Item', 5.00, 200);

    CheckoutUnitOfWork uow = new CheckoutUnitOfWork();
    uow.registerPurchase(new Purchase__c(ClientId__c = acc.Id));

    for (Integer i = 0; i < 100; i++) {
      uow.registerPurchaseLine(
        new PurchaseLine__c(
          ItemId__c = item.Id,
          Amount__c = 1,
          UnitCost__c = 5.00
        )
      );
    }
    uow.registerItemUpdate(new Item__c(Id = item.Id, AvailableQuantity__c = 0));

    Test.startTest();
    uow.commitWork();
    Test.stopTest();

    Id purchaseId = uow.getPurchaseId();
    Integer lineCount = [
      SELECT COUNT()
      FROM PurchaseLine__c
      WHERE PurchaseId__c = :purchaseId
    ];
    System.assertEquals(
      100,
      lineCount,
      'All 100 PurchaseLines must be inserted in one commitWork'
    );
  }

  @IsTest
  static void getPurchaseId_returnsNull_whenNoPurchaseRegistered() {
    CheckoutUnitOfWork uow = new CheckoutUnitOfWork();

    System.assertEquals(
      null,
      uow.getPurchaseId(),
      'getPurchaseId must return null when no purchase was registered'
    );
  }
}
