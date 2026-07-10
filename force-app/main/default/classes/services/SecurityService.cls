public with sharing class SecurityService {
  private static UserSelector selector = new UserSelector();

  public static Boolean canManageCatalog(Id userId) {
    return selector.isUserManager(userId);
  }

  public static void requireCatalogManagerAccess(Id userId) {
    if (!canManageCatalog(userId)) {
      throw new SecurityException(
        'Access Denied: Only managers can modify the catalog.'
      );
    }
  }
}
