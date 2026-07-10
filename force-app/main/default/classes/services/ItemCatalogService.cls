public with sharing class ItemCatalogService {
  private static ItemSelector selector = new ItemSelector();
  private static UserSelector userSelector = new UserSelector();

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

  public static void createNewItem(ItemDTO itemDto) {
    Id currentUserId = UserInfo.getUserId();

    if (!userSelector.isUserManager(currentUserId)) {
      throw new SecurityException(
        'Access Denied: Only managers can create items.'
      );
    }

    String imageUrl = UnsplashImageService.fetchImageUrl(itemDto.name);

    Item__c newItem = new Item__c(
      Name = itemDto.name,
      Price__c = itemDto.price,
      Type__c = itemDto.type,
      Family__c = itemDto.family,
      AvailableQuantity__c = itemDto.availableQuantity,
      Description__c = itemDto.description,
      Image__c = imageUrl
    );

    insert newItem;
  }
}
