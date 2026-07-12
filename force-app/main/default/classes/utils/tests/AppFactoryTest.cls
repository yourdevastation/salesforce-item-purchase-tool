@IsTest
private class AppFactoryTest {
  @IsTest
  static void getItemSelector_returnsRealItemSelector_whenNoMockSet() {
    AppFactory.reset();

    IItemSelector selector = AppFactory.getItemSelector();

    System.assert(
      selector instanceof ItemSelector,
      'AppFactory must return real ItemSelector when no mock is set'
    );
  }

  @IsTest
  static void getAccountSelector_returnsRealAccountSelector_whenNoMockSet() {
    AppFactory.reset();

    IAccountSelector selector = AppFactory.getAccountSelector();

    System.assert(
      selector instanceof AccountSelector,
      'AppFactory must return real AccountSelector when no mock is set'
    );
  }

  @IsTest
  static void getUserSelector_returnsRealUserSelector_whenNoMockSet() {
    AppFactory.reset();

    IUserSelector selector = AppFactory.getUserSelector();

    System.assert(
      selector instanceof UserSelector,
      'AppFactory must return real UserSelector when no mock is set'
    );
  }

  @IsTest
  static void getCheckoutUnitOfWork_returnsRealCheckoutUnitOfWork_whenNoMockSet() {
    AppFactory.reset();

    ICheckoutUnitOfWork uow = AppFactory.getCheckoutUnitOfWork();

    System.assert(
      uow instanceof CheckoutUnitOfWork,
      'AppFactory must return real CheckoutUnitOfWork when no mock is set'
    );
  }

  @IsTest
  static void getItemCatalogUnitOfWork_returnsRealItemCatalogUnitOfWork_whenNoMockSet() {
    AppFactory.reset();

    IItemCatalogUnitOfWork uow = AppFactory.getItemCatalogUnitOfWork();

    System.assert(
      uow instanceof ItemCatalogUnitOfWork,
      'AppFactory must return real ItemCatalogUnitOfWork when no mock is set'
    );
  }

  @IsTest
  static void getItemSelector_returnsMock_whenMockIsSet() {
    AppFactory.reset();

    FakeItemSelector fake = new FakeItemSelector();
    AppFactory.mockItemSelector = fake;

    IItemSelector selector = AppFactory.getItemSelector();

    System.assert(
      selector instanceof FakeItemSelector,
      'AppFactory must return the registered mock when set'
    );
  }

  @IsTest
  static void reset_clearsAllMocks_afterMocksWereSet() {
    AppFactory.mockItemSelector = new FakeItemSelector();
    AppFactory.mockAccountSelector = new FakeAccountSelector();
    AppFactory.mockUserSelector = new FakeUserSelector();
    AppFactory.mockCheckoutUow = new FakeCheckoutUnitOfWork();
    AppFactory.mockItemCatalogUow = new FakeItemCatalogUnitOfWork();

    AppFactory.reset();

    System.assert(
      AppFactory.getItemSelector() instanceof ItemSelector,
      'After reset, ItemSelector mock must be cleared'
    );
    System.assert(
      AppFactory.getAccountSelector() instanceof AccountSelector,
      'After reset, AccountSelector mock must be cleared'
    );
    System.assert(
      AppFactory.getUserSelector() instanceof UserSelector,
      'After reset, UserSelector mock must be cleared'
    );
    System.assert(
      AppFactory.getCheckoutUnitOfWork() instanceof CheckoutUnitOfWork,
      'After reset, CheckoutUnitOfWork mock must be cleared'
    );
    System.assert(
      AppFactory.getItemCatalogUnitOfWork() instanceof ItemCatalogUnitOfWork,
      'After reset, ItemCatalogUnitOfWork mock must be cleared'
    );
  }
}
