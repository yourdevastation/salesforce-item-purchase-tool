public with sharing class ItemSelector {
  public List<Item__c> getItemsByFilters(
    String type,
    String family,
    String searchTerm
  ) {
    List<String> conditions = new List<String>();
    Map<String, Object> binds = new Map<String, Object>();

    if (String.isNotBlank(type)) {
      conditions.add('Type__c = :type');
      binds.put('type', type);
    }
    if (String.isNotBlank(family)) {
      conditions.add('Family__c = :family');
      binds.put('family', family);
    }
    if (String.isNotBlank(searchTerm)) {
      conditions.add(
        '(Name LIKE :searchPattern OR Description__c LIKE :searchPattern)'
      );
      binds.put('searchPattern', '%' + searchTerm + '%');
    }

    String whereClause = conditions.isEmpty()
      ? ''
      : ' WHERE ' + String.join(conditions, ' AND ');

    String query =
      'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c, AvailableQuantity__c ' +
      'FROM Item__c' +
      whereClause +
      ' ORDER BY Name';

    return Database.queryWithBinds(query, binds, AccessLevel.USER_MODE);
  }

  public List<Item__c> getItemsForUpdate(Set<Id> itemIds) {
    return [
      SELECT Id, Name, AvailableQuantity__c, Price__c
      FROM Item__c
      WHERE Id IN :itemIds
      FOR UPDATE
    ];
  }
}
