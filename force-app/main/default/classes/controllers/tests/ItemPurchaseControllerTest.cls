@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
// All dependencies are replaced by Fake classes via AppFactory — no real DML/SOQL
// is executed, so System.runAs() would not add signal to any test in this class.
private class ItemPurchaseControllerTest {
  private class FakeUnsplashMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setBody(
        '{"results":[{"urls":{"regular":"https://images.unsplash.com/photo.jpg"}}]}'
      );
      return res;
    }
  }

  private static CartLineDTO buildLine(Id itemId, Integer qty) {
    CartLineDTO line = new CartLineDTO();
    line.id = itemId;
    line.quantity = qty;
    return line;
  }

  @IsTest
  static void getItems_returnsItemDtos_whenServiceSucceeds() {
    AppFactory.reset();

    FakeItemSelector fakeSelector = new FakeItemSelector();
    Item__c stubItem = new Item__c(
      Name = 'Controller Widget',
      Price__c = 15.00,
      AvailableQuantity__c = 5,
      Type__c = 'Type 1',
      Family__c = 'Family 1'
    );
    fakeSelector.itemsToReturn = new List<Item__c>{ stubItem };
    AppFactory.mockItemSelector = fakeSelector;

    Test.startTest();
    List<ItemDTO> result = ItemPurchaseController.getItems(
      'Type 1',
      'Family 1',
      null,
      10,
      0
    );
    Test.stopTest();

    System.assertEquals(
      1,
      result.size(),
      'Controller must return DTOs from service'
    );
    System.assertEquals('Controller Widget', result[0].name);
  }

  @IsTest
  static void getItems_throwsAuraHandledExceptionWithGenericMessage_whenUnexpectedExceptionOccurs() {
    AppFactory.reset();
    AppFactory.mockItemSelector = new ThrowingFakeItemSelector();

    Test.startTest();
    try {
      ItemPurchaseController.getItems(null, null, null, 10, 0);
      System.assert(false, 'Expected AuraHandledException was not thrown');
    } catch (AuraHandledException e) {
      System.assertEquals(
        'Could not load catalog items. Please try again later.',
        e.getMessage(),
        'getItems catch(Exception) must return the generic catalog error message'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void checkout_throwsAuraHandledExceptionWithGenericMessage_whenUnexpectedExceptionOccurs() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Unexpected Error Corp');
    Item__c item = TestDataFactory.insertItem('Exploding Widget', 10.00, 5);

    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    FakeItemSelector fakeItem = new FakeItemSelector();
    Item__c fakeDbItem = new Item__c(
      Name = 'Exploding Widget',
      Price__c = 10.00,
      AvailableQuantity__c = 5
    );
    fakeDbItem.Id = item.Id;
    fakeItem.itemsForUpdateToReturn = new List<Item__c>{ fakeDbItem };
    AppFactory.mockItemSelector = fakeItem;

    AppFactory.mockCheckoutUow = new ThrowingFakeCheckoutUnitOfWork();

    List<CartLineDTO> cart = new List<CartLineDTO>{ buildLine(item.Id, 1) };

    Test.startTest();
    try {
      ItemPurchaseController.checkout(acc.Id, cart);
      System.assert(false, 'Expected AuraHandledException was not thrown');
    } catch (AuraHandledException e) {
      System.assertEquals(
        'Internal error during checkout',
        e.getMessage(),
        'checkout catch(Exception) must return the generic checkout error message'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void createItemWithImage_throwsAuraHandledExceptionWithGenericMessage_whenUnexpectedExceptionOccurs() {
    AppFactory.reset();

    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = true;
    AppFactory.mockUserSelector = fakeUserSelector;

    AppFactory.mockItemCatalogUow = new ThrowingFakeItemCatalogUnitOfWork();
    Test.setMock(HttpCalloutMock.class, new FakeUnsplashMock());

    ItemDTO dto = new ItemDTO();
    dto.name = 'Exception Trigger Item';
    dto.price = 50.00;
    dto.type = 'Type 1';
    dto.family = 'Family 1';
    dto.availableQuantity = 5;
    dto.description = 'Forces an exception inside the UOW';

    Test.startTest();
    try {
      ItemPurchaseController.createItemWithImage(dto);
      System.assert(false, 'Expected AuraHandledException was not thrown');
    } catch (AuraHandledException e) {
      System.assertEquals(
        'Internal error during item creation',
        e.getMessage(),
        'createItemWithImage catch(Exception) must return the generic creation error message'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void checkout_returnsPurchaseId_whenCheckoutSucceeds() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Controller Checkout Corp');
    Item__c item = TestDataFactory.insertItem('Checkout Widget', 25.00, 10);

    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    FakeItemSelector fakeItem = new FakeItemSelector();
    Item__c fakeDbItem = new Item__c(
      Name = 'Checkout Widget',
      Price__c = 25.00,
      AvailableQuantity__c = 10
    );
    fakeDbItem.Id = item.Id;
    fakeItem.itemsForUpdateToReturn = new List<Item__c>{ fakeDbItem };
    AppFactory.mockItemSelector = fakeItem;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    fakeUow.purchaseIdToReturn = acc.Id; // any valid Id
    AppFactory.mockCheckoutUow = fakeUow;

    List<CartLineDTO> cart = new List<CartLineDTO>{ buildLine(item.Id, 1) };

    Test.startTest();
    Id result = ItemPurchaseController.checkout(acc.Id, cart);
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'checkout must return a non-null Purchase Id on success'
    );
  }

  @IsTest
  static void checkout_throwsAuraHandledExceptionWithDomainMessage_whenCheckoutExceptionOccurs() {
    AppFactory.reset();

    // accountsToReturn empty, so InvalidAccountIdException from service
    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    AppFactory.mockAccountSelector = fakeAccount;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    Account acc = TestDataFactory.insertAccount('Ghost Corp');
    List<CartLineDTO> cart = new List<CartLineDTO>{ buildLine(acc.Id, 1) };

    Test.startTest();
    try {
      ItemPurchaseController.checkout(acc.Id, cart);
      System.assert(false, 'Expected AuraHandledException');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage().contains('Invalid Account'),
        'Domain message must be surfaced to user for CheckoutExceptions'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void createItemWithImage_succeeds_whenUserIsManager() {
    AppFactory.reset();

    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = true;
    AppFactory.mockUserSelector = fakeUserSelector;

    FakeItemCatalogUnitOfWork fakeUow = new FakeItemCatalogUnitOfWork();
    AppFactory.mockItemCatalogUow = fakeUow;

    Test.setMock(HttpCalloutMock.class, new FakeUnsplashMock());

    ItemDTO dto = new ItemDTO();
    dto.name = 'Manager Item';
    dto.price = 99.00;
    dto.type = 'Type 1';
    dto.family = 'Family 1';
    dto.availableQuantity = 5;
    dto.description = 'Created by manager';

    Test.startTest();
    Boolean exceptionThrown = false;
    try {
      ItemPurchaseController.createItemWithImage(dto);
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(
      !exceptionThrown,
      'createItemWithImage must succeed for a manager'
    );
    System.assert(fakeUow.commitWorkWasCalled, 'UOW commitWork must be called');
  }

  @IsTest
  static void createItemWithImage_throwsAuraHandledException_whenUserIsNotManager() {
    AppFactory.reset();

    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = false;
    AppFactory.mockUserSelector = fakeUserSelector;

    FakeItemCatalogUnitOfWork fakeUow = new FakeItemCatalogUnitOfWork();
    AppFactory.mockItemCatalogUow = fakeUow;

    ItemDTO dto = new ItemDTO();
    dto.name = 'Unauthorized Item';
    dto.price = 10.00;
    dto.type = 'Type 1';
    dto.family = 'Family 1';
    dto.availableQuantity = 1;

    Test.startTest();
    try {
      ItemPurchaseController.createItemWithImage(dto);
      System.assert(false, 'Expected AuraHandledException for non-manager');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage().contains('Access Denied'),
        'Authorization message must be surfaced to user'
      );
    }
    Test.stopTest();

    System.assert(
      !fakeUow.commitWorkWasCalled,
      'UOW commitWork must NOT be called when authorization fails'
    );
  }

  @IsTest
  static void checkManagerAccess_returnsTrue_whenCurrentUserIsManager() {
    AppFactory.reset();

    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = true;
    AppFactory.mockUserSelector = fakeUserSelector;

    Test.startTest();
    Boolean result = ItemPurchaseController.checkManagerAccess();
    Test.stopTest();

    System.assertEquals(
      true,
      result,
      'checkManagerAccess must return true for manager'
    );
  }

  @IsTest
  static void checkManagerAccess_returnsFalse_whenCurrentUserIsNotManager() {
    AppFactory.reset();

    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = false;
    AppFactory.mockUserSelector = fakeUserSelector;

    Test.startTest();
    Boolean result = ItemPurchaseController.checkManagerAccess();
    Test.stopTest();

    System.assertEquals(
      false,
      result,
      'checkManagerAccess must return false for non-manager'
    );
  }
}
