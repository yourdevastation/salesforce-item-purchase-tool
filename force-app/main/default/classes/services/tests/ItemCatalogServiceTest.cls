@IsTest
private class ItemCatalogServiceTest {
  private class FakeUnsplashMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setBody(
        '{"results":[{"urls":{"regular":"https://images.unsplash.com/test.jpg"}}]}'
      );
      return res;
    }
  }

  @IsTest
  static void getFilteredItems_mapsItemToDto_withAllFields() {
    AppFactory.reset();

    FakeItemSelector fakeSelector = new FakeItemSelector();
    Item__c stubItem = new Item__c(
      Name = 'Mapped Widget',
      Price__c = 49.99,
      AvailableQuantity__c = 3,
      Type__c = 'Type 1',
      Family__c = 'Family 1',
      Description__c = 'A great widget',
      Image__c = 'https://example.com/img.jpg'
    );
    fakeSelector.itemsToReturn = new List<Item__c>{ stubItem };
    AppFactory.mockItemSelector = fakeSelector;

    Test.startTest();
    List<ItemDTO> dtos = ItemCatalogService.getFilteredItems(
      null,
      null,
      null,
      10,
      0
    );
    Test.stopTest();

    System.assertEquals(1, dtos.size(), 'Service must return one DTO');
    ItemDTO dto = dtos[0];
    System.assertEquals('Mapped Widget', dto.name, 'DTO name must match');
    System.assertEquals(49.99, dto.price, 'DTO price must match');
    System.assertEquals(
      3,
      dto.availableQuantity,
      'DTO availableQuantity must match'
    );
    System.assertEquals('Type 1', dto.type, 'DTO type must match');
    System.assertEquals('Family 1', dto.family, 'DTO family must match');
    System.assertEquals(
      'A great widget',
      dto.description,
      'DTO description must match'
    );
    System.assertEquals(
      'https://example.com/img.jpg',
      dto.image,
      'DTO image must match'
    );
    System.assertEquals(
      false,
      dto.isOutOfStock,
      'isOutOfStock must be false when qty > 0'
    );
  }

  @IsTest
  static void getFilteredItems_setsIsOutOfStockTrue_whenAvailableQuantityIsZero() {
    AppFactory.reset();

    FakeItemSelector fakeSelector = new FakeItemSelector();
    Item__c outOfStockItem = new Item__c(
      Name = 'Empty Item',
      Price__c = 10,
      AvailableQuantity__c = 0,
      Type__c = 'Type 1',
      Family__c = 'Family 1'
    );
    fakeSelector.itemsToReturn = new List<Item__c>{ outOfStockItem };
    AppFactory.mockItemSelector = fakeSelector;

    Test.startTest();
    List<ItemDTO> dtos = ItemCatalogService.getFilteredItems(
      null,
      null,
      null,
      10,
      0
    );
    Test.stopTest();

    System.assertEquals(
      true,
      dtos[0].isOutOfStock,
      'isOutOfStock must be true when qty = 0'
    );
  }

  @IsTest
  static void getFilteredItems_returnsEmptyList_whenSelectorReturnsNothing() {
    AppFactory.reset();

    FakeItemSelector fakeSelector = new FakeItemSelector();
    AppFactory.mockItemSelector = fakeSelector;

    Test.startTest();
    List<ItemDTO> dtos = ItemCatalogService.getFilteredItems(
      null,
      null,
      null,
      10,
      0
    );
    Test.stopTest();

    System.assert(
      dtos.isEmpty(),
      'Service must return empty list when selector returns no items'
    );
  }

  @IsTest
  static void createNewItem_registersAndCommits_whenUserIsManager() {
    AppFactory.reset();

    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = true;
    AppFactory.mockUserSelector = fakeUserSelector;

    FakeItemCatalogUnitOfWork fakeUow = new FakeItemCatalogUnitOfWork();
    AppFactory.mockItemCatalogUow = fakeUow;

    Test.setMock(HttpCalloutMock.class, new FakeUnsplashMock());

    ItemDTO dto = new ItemDTO();
    dto.name = 'New Product';
    dto.price = 25.00;
    dto.type = 'Type 1';
    dto.family = 'Family 1';
    dto.availableQuantity = 10;
    dto.description = 'Test item';

    Test.startTest();
    ItemCatalogService.createNewItem(dto);
    Test.stopTest();

    System.assert(
      fakeUow.registerNewWasCalled,
      'registerNew must be called on UOW for manager user'
    );
    System.assert(
      fakeUow.commitWorkWasCalled,
      'commitWork must be called on UOW for manager user'
    );
  }

  @IsTest
  static void createNewItem_setsImageUrlOnItem_fromUnsplashResponse() {
    AppFactory.reset();

    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = true;
    AppFactory.mockUserSelector = fakeUserSelector;

    FakeItemCatalogUnitOfWork fakeUow = new FakeItemCatalogUnitOfWork();
    AppFactory.mockItemCatalogUow = fakeUow;

    Test.setMock(HttpCalloutMock.class, new FakeUnsplashMock());

    ItemDTO dto = new ItemDTO();
    dto.name = 'Camera';
    dto.price = 500.00;
    dto.type = 'Type 1';
    dto.family = 'Family 1';
    dto.availableQuantity = 5;
    dto.description = 'A camera';

    Test.startTest();
    ItemCatalogService.createNewItem(dto);
    Test.stopTest();

    System.assert(
      !fakeUow.registeredRecords.isEmpty(),
      'A record must be registered'
    );
    Item__c registeredItem = (Item__c) fakeUow.registeredRecords[0];
    System.assertEquals(
      'https://images.unsplash.com/test.jpg',
      registeredItem.Image__c,
      'Image URL from Unsplash must be set on the item'
    );
  }

  @IsTest
  static void createNewItem_propagatesAccessDeniedException_whenUserIsNotManager() {
    AppFactory.reset();

    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = false;
    AppFactory.mockUserSelector = fakeUserSelector;

    FakeItemCatalogUnitOfWork fakeUow = new FakeItemCatalogUnitOfWork();
    AppFactory.mockItemCatalogUow = fakeUow;

    ItemDTO dto = new ItemDTO();
    dto.name = 'Unauthorized Item';
    dto.price = 10;
    dto.type = 'Type 1';
    dto.family = 'Family 1';
    dto.availableQuantity = 1;

    Test.startTest();
    try {
      ItemCatalogService.createNewItem(dto);
      System.assert(false, 'Expected AccessDeniedException was not thrown');
    } catch (AuthorizationExceptions.AccessDeniedException e) {
      System.assert(true, 'AccessDeniedException correctly propagated');
    }
    Test.stopTest();

    System.assert(
      !fakeUow.commitWorkWasCalled,
      'commitWork must NOT be called when authorization fails'
    );
  }
}
