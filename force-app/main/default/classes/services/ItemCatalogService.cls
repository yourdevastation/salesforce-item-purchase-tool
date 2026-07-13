public with sharing class ItemCatalogService {
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public static List<ItemDTO> getFilteredItems(
    String type,
    String family,
    String searchTerm,
    Integer limitSize,
    Integer offsetSize
  ) {
    IItemSelector selector = AppFactory.getItemSelector();

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
    IItemCatalogUnitOfWork unitOfWork = AppFactory.getItemCatalogUnitOfWork();

    Id currentUserId = UserInfo.getUserId();

    SecurityService.requireCatalogManagerAccess(currentUserId);

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
