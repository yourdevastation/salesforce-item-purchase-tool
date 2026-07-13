@IsTest
public class TestDataFactory {
  public static Item__c buildItem(
    String name,
    Decimal price,
    Integer availableQty
  ) {
    return new Item__c(
      Name = name,
      Price__c = price,
      AvailableQuantity__c = availableQty,
      Type__c = 'Type 1',
      Family__c = 'Family 1',
      Description__c = 'Test description'
    );
  }

  public static Item__c insertItem(
    String name,
    Decimal price,
    Integer availableQty
  ) {
    Item__c item = buildItem(name, price, availableQty);
    insert item;
    return item;
  }

  public static List<Item__c> insertItems(
    Integer count,
    Integer availableQtyEach
  ) {
    List<Item__c> items = new List<Item__c>();
    for (Integer i = 0; i < count; i++) {
      items.add(buildItem('Item ' + i, 10, availableQtyEach));
    }
    insert items;
    return items;
  }

  public static Account insertAccount(String name) {
    Account acc = new Account(Name = name);
    insert acc;
    return acc;
  }

  public static Purchase__c insertPurchase(Id accountId) {
    Purchase__c p = new Purchase__c(ClientId__c = accountId);
    insert p;
    return p;
  }

  public static User buildManagerUser() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    Integer rand = Math.abs(Crypto.getRandomInteger());
    return new User(
      FirstName = 'Test',
      LastName = 'Manager',
      Email = 'test.manager' + rand + '@example.com',
      Username = 'test.manager' + rand + '@example.com.test',
      Alias = 'tmgr',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      ProfileId = p.Id,
      IsManager__c = true
    );
  }

  public static User buildStandardUser() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    Integer rand = Math.abs(Crypto.getRandomInteger());
    return new User(
      FirstName = 'Test',
      LastName = 'User',
      Email = 'test.user' + rand + '@example.com',
      Username = 'test.user' + rand + '@example.com.test',
      Alias = 'tusr',
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      ProfileId = p.Id,
      IsManager__c = false
    );
  }
}
