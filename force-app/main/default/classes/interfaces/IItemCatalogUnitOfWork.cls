public interface IItemCatalogUnitOfWork {
  void registerNew(SObject record);
  void commitWork();
}
