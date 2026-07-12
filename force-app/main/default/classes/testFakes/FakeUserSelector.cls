@IsTest
public class FakeUserSelector implements IUserSelector {
  public Boolean isManagerToReturn = false;

  public Boolean isUserManager(Id userId) {
    return isManagerToReturn;
  }
}
