@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
// All dependencies are replaced by Fake classes via AppFactory — no real DML/SOQL
// is executed, so System.runAs() would not add signal to any test in this class.
private class CheckoutServiceTest {
  private static Item__c buildFakeItem(Id itemId, Decimal qty) {
    Item__c item = new Item__c(
      Name = 'Test Item',
      Price__c = 10.00,
      AvailableQuantity__c = qty
    );
    item.Id = itemId;
    return item;
  }

  private static CartLineDTO buildLine(Id itemId, Integer qty) {
    CartLineDTO line = new CartLineDTO();
    line.id = itemId;
    line.quantity = qty;
    return line;
  }

  @IsTest
  static void processCheckout_completesSuccessfully_whenAllDataIsValid() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Checkout Corp');
    Item__c dbItem = TestDataFactory.insertItem('Happy Widget', 20.00, 5);

    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    FakeItemSelector fakeItem = new FakeItemSelector();
    fakeItem.itemsForUpdateToReturn = new List<Item__c>{
      buildFakeItem(dbItem.Id, 5)
    };
    AppFactory.mockItemSelector = fakeItem;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    fakeUow.purchaseIdToReturn = acc.Id; // use any Id as return value
    AppFactory.mockCheckoutUow = fakeUow;

    List<CartLineDTO> cart = new List<CartLineDTO>{ buildLine(dbItem.Id, 2) };

    Test.startTest();
    Id result = CheckoutService.processCheckout(acc.Id, cart);
    Test.stopTest();

    System.assertEquals(
      acc.Id,
      result,
      'processCheckout must return the purchaseId from UOW'
    );
    System.assert(
      fakeUow.commitWorkWasCalled,
      'commitWork must be called on success'
    );
    System.assertEquals(
      1,
      fakeUow.registeredLines.size(),
      'One PurchaseLine must be registered'
    );
    System.assertEquals(
      1,
      fakeUow.registeredItemUpdates.size(),
      'One item stock update must be registered'
    );
    System.assertEquals(
      3,
      fakeUow.registeredItemUpdates[0].AvailableQuantity__c,
      'Stock must be decremented by requested quantity'
    );
  }

  @IsTest
  static void processCheckout_throwsEmptyCartException_whenCartLinesIsNull() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Empty Cart Corp');
    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    Test.startTest();
    try {
      CheckoutService.processCheckout(acc.Id, null);
      System.assert(false, 'Expected EmptyCartException');
    } catch (CheckoutExceptions.EmptyCartException e) {
      System.assert(true, 'EmptyCartException correctly thrown for null cart');
    }
    Test.stopTest();

    System.assert(
      !fakeUow.commitWorkWasCalled,
      'commitWork must NOT be called for null cart'
    );
  }

  @IsTest
  static void processCheckout_throwsEmptyCartException_whenCartLinesIsEmpty() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Empty Cart Corp 2');
    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    Test.startTest();
    try {
      CheckoutService.processCheckout(acc.Id, new List<CartLineDTO>());
      System.assert(false, 'Expected EmptyCartException');
    } catch (CheckoutExceptions.EmptyCartException e) {
      System.assert(true, 'EmptyCartException correctly thrown for empty cart');
    }
    Test.stopTest();

    System.assert(
      !fakeUow.commitWorkWasCalled,
      'commitWork must NOT be called for empty cart'
    );
  }

  @IsTest
  static void processCheckout_throwsCartLimitExceededException_whenCartHasOver100Items() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Big Cart Corp');
    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    List<CartLineDTO> bigCart = new List<CartLineDTO>();
    for (Integer i = 0; i < 101; i++) {
      CartLineDTO line = new CartLineDTO();
      line.id = ('01t' + String.valueOf(i).leftPad(15, '0')).left(18);
      line.quantity = 1;
      bigCart.add(line);
    }

    Test.startTest();
    try {
      CheckoutService.processCheckout(acc.Id, bigCart);
      System.assert(false, 'Expected CartLimitExceededException');
    } catch (CheckoutExceptions.CartLimitExceededException e) {
      System.assert(
        true,
        'CartLimitExceededException correctly thrown for 101 items'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void processCheckout_throwsAccountIdMissingException_whenAccountIdIsNull() {
    AppFactory.reset();
    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    Test.startTest();
    try {
      CheckoutService.processCheckout(
        null,
        new List<CartLineDTO>{ buildLine(null, 1) }
      );
      System.assert(false, 'Expected AccountIdMissingException');
    } catch (CheckoutExceptions.AccountIdMissingException e) {
      System.assert(
        true,
        'AccountIdMissingException correctly thrown for null account'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void processCheckout_throwsInvalidAccountIdException_whenAccountNotFound() {
    AppFactory.reset();

    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    // accountsToReturn is empty — account not found
    AppFactory.mockAccountSelector = fakeAccount;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    Account stubAccount = TestDataFactory.insertAccount('Ghost Corp');

    List<CartLineDTO> cart = new List<CartLineDTO>{
      buildLine(stubAccount.Id, 1)
    };

    Test.startTest();
    try {
      CheckoutService.processCheckout(stubAccount.Id, cart);
      System.assert(false, 'Expected InvalidAccountIdException');
    } catch (CheckoutExceptions.InvalidAccountIdException e) {
      System.assert(
        true,
        'InvalidAccountIdException correctly thrown when account not found'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void processCheckout_throwsItemNotFoundException_whenItemDoesNotExist() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Missing Item Corp');
    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    FakeItemSelector fakeItem = new FakeItemSelector();
    // itemsForUpdateToReturn is empty — item not found in DB
    AppFactory.mockItemSelector = fakeItem;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    Item__c ghost = TestDataFactory.insertItem('Ghost Item', 10, 5);
    List<CartLineDTO> cart = new List<CartLineDTO>{ buildLine(ghost.Id, 1) };

    Test.startTest();
    try {
      CheckoutService.processCheckout(acc.Id, cart);
      System.assert(false, 'Expected ItemNotFoundException');
    } catch (CheckoutExceptions.ItemNotFoundException e) {
      System.assert(
        true,
        'ItemNotFoundException correctly thrown when DB item not found'
      );
    }
    Test.stopTest();

    System.assert(
      !fakeUow.commitWorkWasCalled,
      'commitWork must NOT be called when item not found'
    );
  }

  @IsTest
  static void processCheckout_throwsInsufficientStockException_whenStockInsufficient() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Low Stock Corp');
    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    Item__c dbItem = TestDataFactory.insertItem('Limited Item', 10, 1);

    FakeItemSelector fakeItem = new FakeItemSelector();
    fakeItem.itemsForUpdateToReturn = new List<Item__c>{
      buildFakeItem(dbItem.Id, 1)
    };
    AppFactory.mockItemSelector = fakeItem;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    List<CartLineDTO> cart = new List<CartLineDTO>{ buildLine(dbItem.Id, 5) };

    Test.startTest();
    try {
      CheckoutService.processCheckout(acc.Id, cart);
      System.assert(false, 'Expected InsufficientStockException');
    } catch (CheckoutExceptions.InsufficientStockException e) {
      System.assert(
        e.getMessage().contains('Insufficient stock'),
        'Exception message must be descriptive'
      );
    }
    Test.stopTest();

    System.assert(
      !fakeUow.commitWorkWasCalled,
      'commitWork must NOT be called when stock is insufficient'
    );
  }

  @IsTest
  static void processCheckout_throwsInsufficientStockException_whenAvailableQuantityIsNull() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Null Stock Corp');
    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    Item__c dbItem = TestDataFactory.insertItem('Null Stock Item', 10, 5);

    FakeItemSelector fakeItem = new FakeItemSelector();
    fakeItem.itemsForUpdateToReturn = new List<Item__c>{
      buildFakeItem(dbItem.Id, null) // null stock
    };
    AppFactory.mockItemSelector = fakeItem;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    List<CartLineDTO> cart = new List<CartLineDTO>{ buildLine(dbItem.Id, 1) };

    Test.startTest();
    try {
      CheckoutService.processCheckout(acc.Id, cart);
      System.assert(
        false,
        'Expected InsufficientStockException for null quantity'
      );
    } catch (CheckoutExceptions.InsufficientStockException e) {
      System.assert(
        true,
        'Null AvailableQuantity__c treated as insufficient stock'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void processCheckout_throwsInvalidQuantityException_whenRequestedQtyIsZero() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Zero Qty Corp');
    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    Item__c dbItem = TestDataFactory.insertItem('Zero Qty Item', 10, 10);

    FakeItemSelector fakeItem = new FakeItemSelector();
    fakeItem.itemsForUpdateToReturn = new List<Item__c>{
      buildFakeItem(dbItem.Id, 10)
    };
    AppFactory.mockItemSelector = fakeItem;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    List<CartLineDTO> cart = new List<CartLineDTO>{ buildLine(dbItem.Id, 0) };

    Test.startTest();
    try {
      CheckoutService.processCheckout(acc.Id, cart);
      System.assert(
        false,
        'Expected InvalidQuantityException for quantity = 0'
      );
    } catch (CheckoutExceptions.InvalidQuantityException e) {
      System.assert(
        true,
        'InvalidQuantityException correctly thrown for quantity = 0'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void processCheckout_throwsInvalidQuantityException_whenRequestedQtyIsNegative() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Neg Qty Corp');
    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    Item__c dbItem = TestDataFactory.insertItem('Neg Qty Item', 10, 10);

    FakeItemSelector fakeItem = new FakeItemSelector();
    fakeItem.itemsForUpdateToReturn = new List<Item__c>{
      buildFakeItem(dbItem.Id, 10)
    };
    AppFactory.mockItemSelector = fakeItem;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    List<CartLineDTO> cart = new List<CartLineDTO>{ buildLine(dbItem.Id, -5) };

    Test.startTest();
    try {
      CheckoutService.processCheckout(acc.Id, cart);
      System.assert(
        false,
        'Expected InvalidQuantityException for negative quantity'
      );
    } catch (CheckoutExceptions.InvalidQuantityException e) {
      System.assert(
        true,
        'InvalidQuantityException correctly thrown for negative quantity'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void processCheckout_handlesMultipleCartLines_registeringAllCorrectly() {
    AppFactory.reset();

    Account acc = TestDataFactory.insertAccount('Bulk Service Corp');
    FakeAccountSelector fakeAccount = new FakeAccountSelector();
    fakeAccount.accountsToReturn = new List<Account>{ acc };
    AppFactory.mockAccountSelector = fakeAccount;

    // Create 10 items
    List<Item__c> dbItems = TestDataFactory.insertItems(10, 20);
    List<Item__c> fakeItems = new List<Item__c>();
    for (Item__c it : dbItems) {
      fakeItems.add(buildFakeItem(it.Id, 20));
    }

    FakeItemSelector fakeItem = new FakeItemSelector();
    fakeItem.itemsForUpdateToReturn = fakeItems;
    AppFactory.mockItemSelector = fakeItem;

    FakeCheckoutUnitOfWork fakeUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockCheckoutUow = fakeUow;

    List<CartLineDTO> cart = new List<CartLineDTO>();
    for (Item__c it : dbItems) {
      cart.add(buildLine(it.Id, 1));
    }

    Test.startTest();
    CheckoutService.processCheckout(acc.Id, cart);
    Test.stopTest();

    System.assertEquals(
      10,
      fakeUow.registeredLines.size(),
      '10 PurchaseLines must be registered for 10 cart items'
    );
    System.assertEquals(
      10,
      fakeUow.registeredItemUpdates.size(),
      '10 item updates must be registered'
    );
    System.assert(fakeUow.commitWorkWasCalled, 'commitWork must be called');
  }
}
