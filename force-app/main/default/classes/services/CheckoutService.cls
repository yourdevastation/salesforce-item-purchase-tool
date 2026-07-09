public with sharing class CheckoutService {
  private static ItemSelector itemSelector = new ItemSelector();

  public static Id processCheckout(Id accountId, List<CartLineDTO> cartLines) {
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

    Map<Id, Item__c> dbItems = new Map<Id, Item__c>(
      itemSelector.getItemsForUpdate(itemIds)
    );

    CheckoutUnitOfWork uow = new CheckoutUnitOfWork();
    uow.purchaseToInsert = new Purchase__c(ClientId__c = accountId);

    for (Id itemId : requestedQuantities.keySet()) {
      Item__c dbItem = dbItems.get(itemId);
      Integer reqQty = requestedQuantities.get(itemId);

      if (dbItem == null) {
        throw new CheckoutExceptions.ItemNotFoundException(
          'Item ' + itemId + ' no longer exists.'
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
      uow.itemsToUpdate.add(dbItem);

      uow.linesToInsert.add(
        new PurchaseLine__c(
          ItemId__c = itemId,
          Amount__c = reqQty,
          UnitCost__c = dbItem.Price__c
        )
      );
    }

    uow.commitWork();

    return uow.purchaseToInsert.Id;
  }
}
