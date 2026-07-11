public with sharing class ItemSelector implements IItemSelector {
  public List<Item__c> getItemsByFilters(
    String type,
    String family,
    String searchTerm,
    Integer limitSize,
    Integer offsetSize
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
      String safeTerm = searchTerm.replace('%', '\\%').replace('_', '\\_');
      conditions.add(
        '(Name LIKE :searchPattern OR Description__c LIKE :searchPattern)'
      );
      binds.put('searchPattern', '%' + safeTerm + '%');
    }

    String whereClause = conditions.isEmpty()
      ? ''
      : ' WHERE ' + String.join(conditions, ' AND ');

    binds.put('limitSize', limitSize);
    binds.put('offsetSize', offsetSize);

    String query =
      'SELECT Id, Name, Description__c, Type__c, Family__c, Image__c, Price__c, AvailableQuantity__c ' +
      'FROM Item__c' +
      whereClause +
      ' ORDER BY Name LIMIT :limitSize OFFSET :offsetSize';

    return Database.queryWithBinds(query, binds, AccessLevel.USER_MODE);
  }

  public List<Item__c> getItemsForUpdate(Set<Id> itemIds) {
    return [
      SELECT Id, Name, AvailableQuantity__c, Price__c
      FROM Item__c
      WHERE Id IN :itemIds
      WITH USER_MODE
      FOR UPDATE
    ];
  }

  public List<Item__c> getItemsWithPurchaseLines(Set<Id> itemIds) {
    return [
      SELECT Id, (SELECT Id FROM Purchase_Lines__r LIMIT 1)
      FROM Item__c
      WHERE Id IN :itemIds
      WITH USER_MODE
    ];
  }
}
