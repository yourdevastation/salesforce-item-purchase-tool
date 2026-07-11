public with sharing class ItemCatalogService {
  private static IItemSelector selector = AppFactory.getItemSelector();
  private static IUserSelector userSelector = AppFactory.getUserSelector();
  private static IItemCatalogUnitOfWork unitOfWork = AppFactory.getItemCatalogUnitOfWork();

  public static List<ItemDTO> getFilteredItems(
    String type,
    String family,
    String searchTerm,
    Integer limitSize,
    Integer offsetSize
  ) {
    List<Item__c> items = selector.getItemsByFilters(
      type,
      family,
      searchTerm,
      limitSize,
      offsetSize
    );
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

    unitOfWork.registerNew(newItem);
    unitOfWork.commitWork();
  }
}
