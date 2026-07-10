public with sharing class AccountSelector {
  public List<Account> getAccountByIdSafe(Id accountId) {
    return [
      SELECT Id
      FROM Account
      WHERE Id = :accountId
      WITH USER_MODE
      LIMIT 1
    ];
  }
}
