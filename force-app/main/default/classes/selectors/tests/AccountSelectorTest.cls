@IsTest
@SuppressWarnings('PMD.AvoidHardcodingId, PMD.ApexUnitTestClassShouldHaveRunAs')
// Real DML runs under the standard test user. No FLS/sharing rules are configured
// per project requirements, so System.runAs() does not add any coverage signal.
private class AccountSelectorTest {
  @IsTest
  static void getAccountByIdSafe_returnsAccount_whenAccountExists() {
    Account acc = TestDataFactory.insertAccount('Test Corp');

    Test.startTest();
    List<Account> results = new AccountSelector().getAccountByIdSafe(acc.Id);
    Test.stopTest();

    System.assertEquals(1, results.size(), 'Expected one account returned');
    System.assertEquals(
      acc.Id,
      results[0].Id,
      'Returned account Id must match'
    );
  }

  @IsTest
  static void getAccountByIdSafe_returnsEmptyList_whenAccountDoesNotExist() {
    Id fakeId = '001000000000001AAA';

    Test.startTest();
    List<Account> results = new AccountSelector().getAccountByIdSafe(fakeId);
    Test.stopTest();

    System.assert(
      results.isEmpty(),
      'Non-existent account id must return empty list, not throw'
    );
  }
}
