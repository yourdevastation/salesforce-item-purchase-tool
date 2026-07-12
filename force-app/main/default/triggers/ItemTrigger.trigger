trigger ItemTrigger on Item__c(before delete) {
  ItemTriggerHandler.beforeDelete(Trigger.old);
}
