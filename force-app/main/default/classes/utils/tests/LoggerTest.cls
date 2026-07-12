@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
// Smoke tests only — no DML or SOQL. Logger writes to System.debug();
// the running user identity has no effect on logging output.
private class LoggerTest {
  @IsTest
  static void logError_doesNotThrow_whenCalledWithValidException() {
    Exception testException = new IllegalArgumentException('Test error');

    Test.startTest();
    Boolean exceptionThrown = false;
    try {
      Logger.logError(testException, 'LoggerTest.logError_doesNotThrow');
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(
      !exceptionThrown,
      'Logger.logError must never throw an exception itself'
    );
  }

  @IsTest
  static void logError_doesNotThrow_whenCalledWithDmlException() {
    Account acc = new Account();

    DmlException dmlEx;
    try {
      insert acc;
    } catch (DmlException e) {
      dmlEx = e;
    }

    Test.startTest();
    Boolean exceptionThrown = false;
    try {
      Logger.logError(
        dmlEx,
        'LoggerTest.logError_doesNotThrow_whenCalledWithDmlException'
      );
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(
      !exceptionThrown,
      'Logger.logError must handle DmlException gracefully. Error: ' +
      (exceptionThrown ? 'Exception was thrown' : 'None')
    );
  }

  @IsTest
  static void logError_doesNotThrow_whenExceptionIsNull() {
    Test.startTest();
    Boolean exceptionThrown = false;

    try {
      Logger.logError(
        null,
        'LoggerTest.logError_doesNotThrow_whenExceptionIsNull'
      );
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();

    System.assert(
      !exceptionThrown,
      'Logger.logError must not throw a NullPointerException when a null Exception is passed'
    );
  }
}
