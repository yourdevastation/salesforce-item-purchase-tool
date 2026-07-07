public with sharing class ItemCatalogService {
  private static ItemSelector selector = new ItemSelector();

  public static List<ItemDTO> getFilteredItems(
    String type,
    String family,
    String searchTerm
  ) {
    List<Item__c> items = selector.getItemsByFilters(type, family, searchTerm);
    List<ItemDTO> dtos = new List<ItemDTO>();

    for (Item__c item : items) {
      dtos.add(new ItemDTO(item));
    }

    return dtos;
  }
}
