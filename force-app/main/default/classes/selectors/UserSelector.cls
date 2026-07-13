public inherited sharing class UserSelector implements IUserSelector {
  public Boolean isUserManager(Id userId) {
    List<User> users = [
      SELECT IsManager__c
      FROM User
      WHERE Id = :userId
      WITH USER_MODE
      LIMIT 1
    ];
    return !users.isEmpty() ? users[0].IsManager__c : false;
  }
}
