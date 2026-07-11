public with sharing class AccountSelector implements IAccountSelector {
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
