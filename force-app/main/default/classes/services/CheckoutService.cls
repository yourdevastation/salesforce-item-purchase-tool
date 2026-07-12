public with sharing class CheckoutService {
  public static Id processCheckout(Id accountId, List<CartLineDTO> cartLines) {
    IItemSelector itemSelector = AppFactory.getItemSelector();
    IAccountSelector accountSelector = AppFactory.getAccountSelector();
    ICheckoutUnitOfWork uow = AppFactory.getCheckoutUnitOfWork();

    validateAccount(accountId, accountSelector);
    validateCartNotEmpty(cartLines);

    Map<Id, Integer> requestedQuantities = extractRequestedQuantities(
      cartLines
    );
    Map<Id, Item__c> dbItems = new Map<Id, Item__c>(
      itemSelector.getItemsForUpdate(requestedQuantities.keySet())
    );

    uow.registerPurchase(new Purchase__c(ClientId__c = accountId));
    registerPurchaseLines(requestedQuantities, dbItems, uow);

    uow.commitWork();
    return uow.getPurchaseId();
  }

  private static void validateAccount(
    Id accountId,
    IAccountSelector accountSelector
  ) {
    if (String.isBlank(accountId)) {
      throw new CheckoutExceptions.AccountIdMissingException(
        'Account is required to checkout.'
      );
    }
    if (accountSelector.getAccountByIdSafe(accountId).isEmpty()) {
      throw new CheckoutExceptions.InvalidAccountIdException(
        'Invalid Account or you do not have access to it.'
      );
    }
  }

  private static void validateCartNotEmpty(List<CartLineDTO> cartLines) {
    if (cartLines == null || cartLines.isEmpty()) {
      throw new CheckoutExceptions.EmptyCartException(
        'Cart is empty. Cannot proceed with checkout.'
      );
    }
  }

  private static Map<Id, Integer> extractRequestedQuantities(
    List<CartLineDTO> cartLines
  ) {
    if (cartLines.size() > 100) {
      throw new CheckoutExceptions.CartLimitExceededException(
        'Cart is too large. Maximum 100 distinct items allowed.'
      );
    }
    Map<Id, Integer> quantities = new Map<Id, Integer>();
    for (CartLineDTO line : cartLines) {
      quantities.put(line.id, line.quantity);
    }
    return quantities;
  }

  private static void registerPurchaseLines(
    Map<Id, Integer> requestedQuantities,
    Map<Id, Item__c> dbItems,
    ICheckoutUnitOfWork uow
  ) {
    for (Id itemId : requestedQuantities.keySet()) {
      Item__c dbItem = validateAndReserveStock(
        itemId,
        requestedQuantities.get(itemId),
        dbItems
      );
      uow.registerItemUpdate(dbItem);
      uow.registerPurchaseLine(
        new PurchaseLine__c(
          ItemId__c = itemId,
          Amount__c = requestedQuantities.get(itemId),
          UnitCost__c = dbItem.Price__c
        )
      );
    }
  }

  private static Item__c validateAndReserveStock(
    Id itemId,
    Integer reqQty,
    Map<Id, Item__c> dbItems
  ) {
    Item__c dbItem = dbItems.get(itemId);
    if (dbItem == null) {
      throw new CheckoutExceptions.ItemNotFoundException(
        'Item ' + itemId + ' no longer exists.'
      );
    }
    if (reqQty == null || reqQty <= 0) {
      throw new CheckoutExceptions.InvalidQuantityException(
        'Invalid quantity for item ' +
          dbItem.Name +
          '. Quantity must be greater than zero.'
      );
    }
    if (
      dbItem.AvailableQuantity__c == null ||
      dbItem.AvailableQuantity__c < reqQty
    ) {
      throw new CheckoutExceptions.InsufficientStockException(
        'Insufficient stock for item: ' +
          dbItem.Name +
          '. Available: ' +
          dbItem.AvailableQuantity__c +
          ', Requested: ' +
          reqQty
      );
    }
    dbItem.AvailableQuantity__c -= reqQty;
    return dbItem;
  }
}
