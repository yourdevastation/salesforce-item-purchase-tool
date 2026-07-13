public with sharing class Logger {
  /**
   * Centralized error logging service.
   * Note: Currently uses System.debug to adhere strictly to the assignment's Data Model.
   * In a production environment, this method would publish a Platform Event (Publish Immediately)
   * to persist errors in a custom Log__c object, bypassing transaction rollbacks.
   */
  public static void logError(Exception e, String context) {
    if (e == null) {
      System.debug(
        LoggingLevel.ERROR,
        'ERROR in ' + context + ':\nMessage: Exception object was null.'
      );
      return;
    }

    String errorMessage = e.getMessage();

    if (e instanceof System.DmlException) {
      System.DmlException dmlEx = (System.DmlException) e;
      List<String> dmlMessages = new List<String>();

      for (Integer i = 0; i < dmlEx.getNumDml(); i++) {
        dmlMessages.add(dmlEx.getDmlMessage(i));
      }
      errorMessage = String.join(dmlMessages, ' | ');
    }

    String logMessage =
      'ERROR in ' +
      context +
      ':\n' +
      'Message: ' +
      errorMessage +
      '\n' +
      'Stack Trace: ' +
      e.getStackTraceString();

    System.debug(LoggingLevel.ERROR, logMessage);
  }
}
