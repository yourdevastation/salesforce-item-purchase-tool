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
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Id checkout(Id accountId, List<CartLineDTO> cartLines) {
    try {
      return CheckoutService.processCheckout(accountId, cartLines);
    } catch (CheckoutExceptions.CheckoutException e) {
      throw new AuraHandledException(e.getMessage());
    } catch (Exception e) {
      throw new AuraHandledException('Internal error during checkout');
    }
  }

  @AuraEnabled
  public static void createItemWithImage(ItemDTO itemDto) {
    try {
      ItemCatalogService.createNewItem(itemDto);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static Boolean checkManagerAccess() {
    return SecurityService.canManageCatalog(UserInfo.getUserId());
  }
}
