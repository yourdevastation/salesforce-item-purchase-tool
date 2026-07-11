public interface IAccountSelector {
  List<Account> getAccountByIdSafe(Id accountId);
}
