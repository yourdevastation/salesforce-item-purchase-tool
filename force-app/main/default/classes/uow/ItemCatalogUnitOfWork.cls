public with sharing class ItemCatalogUnitOfWork implements IItemCatalogUnitOfWork {
  private List<SObject> recordsToInsert = new List<SObject>();

  public void registerNew(SObject record) {
    this.recordsToInsert.add(record);
  }

  public void commitWork() {
    if (!this.recordsToInsert.isEmpty()) {
      SObjectAccessDecision decision = Security.stripInaccessible(
        AccessType.CREATABLE,
        this.recordsToInsert
      );

      Database.insert(decision.getRecords(), AccessLevel.USER_MODE);

      this.recordsToInsert.clear();
    }
  }
}
