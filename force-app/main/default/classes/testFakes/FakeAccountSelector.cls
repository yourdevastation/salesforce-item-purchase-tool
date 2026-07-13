@IsTest
public class FakeAccountSelector implements IAccountSelector {
  public List<Account> accountsToReturn = new List<Account>();

  public List<Account> getAccountByIdSafe(Id accountId) {
    return accountsToReturn;
  }
}
