public with sharing class AppFactory {
  @TestVisible
  private static IItemSelector mockItemSelector;
  @TestVisible
  private static IAccountSelector mockAccountSelector;
  @TestVisible
  private static IUserSelector mockUserSelector;

  @TestVisible
  private static ICheckoutUnitOfWork mockCheckoutUow;
  @TestVisible
  private static IItemCatalogUnitOfWork mockItemCatalogUow;

  public static IItemSelector getItemSelector() {
    return mockItemSelector != null ? mockItemSelector : new ItemSelector();
  }

  public static IAccountSelector getAccountSelector() {
    return mockAccountSelector != null
      ? mockAccountSelector
      : new AccountSelector();
  }

  public static IUserSelector getUserSelector() {
    return mockUserSelector != null ? mockUserSelector : new UserSelector();
  }

  public static ICheckoutUnitOfWork getCheckoutUnitOfWork() {
    return mockCheckoutUow != null ? mockCheckoutUow : new CheckoutUnitOfWork();
  }

  public static IItemCatalogUnitOfWork getItemCatalogUnitOfWork() {
    return mockItemCatalogUow != null
      ? mockItemCatalogUow
      : new ItemCatalogUnitOfWork();
  }

  @TestVisible
  private static void reset() {
    mockItemSelector = null;
    mockAccountSelector = null;
    mockUserSelector = null;
    mockCheckoutUow = null;
    mockItemCatalogUow = null;
  }
}
