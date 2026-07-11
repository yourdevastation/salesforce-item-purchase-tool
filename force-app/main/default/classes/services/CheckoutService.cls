public with sharing class CheckoutService {
  public static Id processCheckout(Id accountId, List<CartLineDTO> cartLines) {
    IItemSelector itemSelector = AppFactory.getItemSelector();
    IAccountSelector accountSelector = AppFactory.getAccountSelector();
    ICheckoutUnitOfWork uow = AppFactory.getCheckoutUnitOfWork();

    if (String.isNotBlank(accountId)) {
      List<Account> accounts = accountSelector.getAccountByIdSafe(accountId);
      if (accounts.isEmpty()) {
        throw new CheckoutExceptions.InvalidAccountIdException(
          'Invalid Account or you do not have access to it.'
        );
      }
    } else {
      throw new CheckoutExceptions.AccountIdMissingException(
        'Account is required to checkout.'
      );
    }

    if (cartLines == null || cartLines.isEmpty()) {
      throw new CheckoutExceptions.EmptyCartException(
        'Cart is empty. Cannot proceed with checkout.'
      );
    }

    Set<Id> itemIds = new Set<Id>();
    Map<Id, Integer> requestedQuantities = new Map<Id, Integer>();
    for (CartLineDTO line : cartLines) {
      itemIds.add(line.id);
      requestedQuantities.put(line.id, line.quantity);
    }

    if (itemIds.size() > 100) {
      throw new CheckoutExceptions.CartLimitExceededException(
        'Cart is too large. Maximum 100 distinct items allowed.'
      );
    }

    Map<Id, Item__c> dbItems = new Map<Id, Item__c>(
      itemSelector.getItemsForUpdate(itemIds)
    );

    uow.registerPurchase(new Purchase__c(ClientId__c = accountId));

    for (Id itemId : requestedQuantities.keySet()) {
      Item__c dbItem = dbItems.get(itemId);
      Integer reqQty = requestedQuantities.get(itemId);

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
      uow.registerItemUpdate(dbItem);

      uow.registerPurchaseLine(
        new PurchaseLine__c(
          ItemId__c = itemId,
          Amount__c = reqQty,
          UnitCost__c = dbItem.Price__c
        )
      );
    }

    uow.commitWork();

    return uow.getPurchaseId();
  }
}
