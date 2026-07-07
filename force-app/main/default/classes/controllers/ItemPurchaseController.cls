public with sharing class ItemPurchaseController {
  @AuraEnabled(cacheable=true)
  public static List<ItemDTO> getItems(
    String type,
    String family,
    String searchTerm
  ) {
    try {
      return ItemCatalogService.getFilteredItems(type, family, searchTerm);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
