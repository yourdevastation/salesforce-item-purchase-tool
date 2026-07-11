public with sharing class SecurityService {
  public static Boolean canManageCatalog(Id userId) {
    IUserSelector selector = AppFactory.getUserSelector();
    return selector.isUserManager(userId);
  }

  public static void requireCatalogManagerAccess(Id userId) {
    if (!canManageCatalog(userId)) {
      throw new AuthorizationExceptions.AccessDeniedException(
        'Access Denied: Only managers can modify the catalog.'
      );
    }
  }
}
