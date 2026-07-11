public with sharing class Logger {
  /**
   * Centralized error logging service.
   * Note: Currently uses System.debug to adhere strictly to the assignment's Data Model.
   * In a production environment, this method would publish a Platform Event (Publish Immediately)
   * to persist errors in a custom Log__c object, bypassing transaction rollbacks.
   */
  public static void logError(Exception e, String context) {
    String logMessage =
      'ERROR in ' +
      context +
      ':\n' +
      'Message: ' +
      e.getMessage() +
      '\n' +
      'Stack Trace: ' +
      e.getStackTraceString();

    System.debug(LoggingLevel.ERROR, logMessage);
  }
}
