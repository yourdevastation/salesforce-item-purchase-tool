@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
// FakeUserSelector replaces the real UserSelector SOQL — the running user identity
// is irrelevant, the fake always returns the configured isManagerToReturn value.
private class SecurityServiceTest {
  @IsTest
  static void requireCatalogManagerAccess_doesNotThrow_whenUserIsManager() {
    AppFactory.reset();
    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = true;
    AppFactory.mockUserSelector = fakeUserSelector;

    Test.startTest();
    Boolean exceptionThrown = false;
    try {
      SecurityService.requireCatalogManagerAccess(UserInfo.getUserId());
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(
      !exceptionThrown,
      'Manager must pass the authorization check without exception'
    );
  }

  @IsTest
  static void requireCatalogManagerAccess_throwsAccessDeniedException_whenUserIsNotManager() {
    AppFactory.reset();
    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = false;
    AppFactory.mockUserSelector = fakeUserSelector;

    Test.startTest();
    try {
      SecurityService.requireCatalogManagerAccess(UserInfo.getUserId());
      System.assert(false, 'Expected AccessDeniedException was not thrown');
    } catch (AuthorizationExceptions.AccessDeniedException e) {
      System.assert(
        e.getMessage().contains('Access Denied'),
        'Exception message must communicate access denial clearly'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void canManageCatalog_returnsTrue_whenUserIsManager() {
    AppFactory.reset();
    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = true;
    AppFactory.mockUserSelector = fakeUserSelector;

    Test.startTest();
    Boolean result = SecurityService.canManageCatalog(UserInfo.getUserId());
    Test.stopTest();

    System.assertEquals(
      true,
      result,
      'canManageCatalog must return true for a manager'
    );
  }

  @IsTest
  static void canManageCatalog_returnsFalse_whenUserIsNotManager() {
    AppFactory.reset();
    FakeUserSelector fakeUserSelector = new FakeUserSelector();
    fakeUserSelector.isManagerToReturn = false;
    AppFactory.mockUserSelector = fakeUserSelector;

    Test.startTest();
    Boolean result = SecurityService.canManageCatalog(UserInfo.getUserId());
    Test.stopTest();

    System.assertEquals(
      false,
      result,
      'canManageCatalog must return false for a non-manager'
    );
  }
}
