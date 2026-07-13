@IsTest
public class ThrowingFakeItemCatalogUnitOfWork implements IItemCatalogUnitOfWork {
  public void registerNew(SObject record) {
  }

  public void commitWork() {
    throw new IllegalArgumentException(
      'Simulated unexpected error in ItemCatalogUnitOfWork'
    );
  }
}
