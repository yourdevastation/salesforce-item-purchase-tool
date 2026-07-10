public inherited sharing class UserSelector {
  public Boolean isUserManager(Id userId) {
    List<User> users = [
      SELECT IsManager__c
      FROM User
      WHERE Id = :userId
      LIMIT 1
    ];
    return !users.isEmpty() ? users[0].IsManager__c : false;
  }
}
