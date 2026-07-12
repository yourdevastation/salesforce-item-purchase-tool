@IsTest
private class UserSelectorTest {
  @IsTest
  static void isUserManager_returnsTrue_whenUserHasIsManagerTrue() {
    User mgr = TestDataFactory.buildManagerUser();
    insert mgr;

    Test.startTest();
    Boolean result = new UserSelector().isUserManager(mgr.Id);
    Test.stopTest();

    System.assertEquals(
      true,
      result,
      'User with IsManager__c = true should be recognized as a manager'
    );
  }

  @IsTest
  static void isUserManager_returnsFalse_whenUserHasIsManagerFalse() {
    User stdUser = TestDataFactory.buildStandardUser();
    insert stdUser;

    Test.startTest();
    Boolean result = new UserSelector().isUserManager(stdUser.Id);
    Test.stopTest();

    System.assertEquals(
      false,
      result,
      'Standard user without IsManager__c must return false'
    );
  }

  @IsTest
  static void isUserManager_returnsFalse_whenUserDoesNotExist() {
    Id fakeId = '005000000000001AAA';

    Test.startTest();
    Boolean result = new UserSelector().isUserManager(fakeId);
    Test.stopTest();

    System.assertEquals(
      false,
      result,
      'Non-existent user id should safely return false via list-assignment guard'
    );
  }
}
