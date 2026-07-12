public with sharing class ItemPurchaseController {
  @AuraEnabled(cacheable=true)
  public static List<ItemDTO> getItems(
    String type,
    String family,
    String searchTerm,
    Integer limitSize,
    Integer offsetSize
  ) {
    try {
      return ItemCatalogService.getFilteredItems(
        type,
        family,
        searchTerm,
        limitSize,
        offsetSize
      );
    } catch (Exception e) {
      Logger.logError(e, 'ItemPurchaseController.getItems');
      AuraHandledException ex = new AuraHandledException(
        'Could not load catalog items. Please try again later.'
      );
      ex.setMessage('Could not load catalog items. Please try again later.');
      throw ex;
    }
  }

  @AuraEnabled
  public static Id checkout(Id accountId, List<CartLineDTO> cartLines) {
    try {
      return CheckoutService.processCheckout(accountId, cartLines);
    } catch (CheckoutExceptions.CheckoutException e) {
      AuraHandledException ex = new AuraHandledException(e.getMessage());
      ex.setMessage(e.getMessage());
      throw ex;
    } catch (Exception e) {
      Logger.logError(e, 'ItemPurchaseController.checkout');
      AuraHandledException ex = new AuraHandledException(
        'Internal error during checkout'
      );
      ex.setMessage('Internal error during checkout');
      throw ex;
    }
  }

  @AuraEnabled
  public static void createItemWithImage(ItemDTO itemDto) {
    try {
      ItemCatalogService.createNewItem(itemDto);
    } catch (AuthorizationExceptions.AuthorizationException e) {
      Logger.logError(e, 'ItemPurchaseController.createItemWithImage');
      AuraHandledException ex = new AuraHandledException(e.getMessage());
      ex.setMessage(e.getMessage());
      throw ex;
    } catch (Exception e) {
      Logger.logError(e, 'ItemPurchaseController.createItemWithImage');
      AuraHandledException ex = new AuraHandledException(
        'Internal error during item creation'
      );
      ex.setMessage('Internal error during item creation');
      throw ex;
    }
  }

  @AuraEnabled(cacheable=true)
  public static Boolean checkManagerAccess() {
    return SecurityService.canManageCatalog(UserInfo.getUserId());
  }
}
