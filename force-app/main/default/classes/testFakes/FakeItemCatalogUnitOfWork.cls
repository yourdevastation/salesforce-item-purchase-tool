@IsTest
public class FakeItemCatalogUnitOfWork implements IItemCatalogUnitOfWork {
  public Boolean registerNewWasCalled = false;
  public Boolean commitWorkWasCalled = false;
  public List<SObject> registeredRecords = new List<SObject>();

  public void registerNew(SObject record) {
    registerNewWasCalled = true;
    registeredRecords.add(record);
  }

  public void commitWork() {
    commitWorkWasCalled = true;
  }
}
