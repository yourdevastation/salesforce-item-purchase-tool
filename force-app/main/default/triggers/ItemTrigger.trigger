trigger ItemTrigger on Item__c(before delete) {
  if (Trigger.isBefore && Trigger.isDelete) {
    ItemTriggerHandler.beforeDelete(Trigger.old);
  }
}
