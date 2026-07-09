trigger PurchaseLineTrigger on PurchaseLine__c(
  after insert,
  after update,
  after delete,
  after undelete
) {
  List<PurchaseLine__c> recordsToProcess = Trigger.isDelete
    ? Trigger.old
    : Trigger.new;
  PurchaseLineTriggerHandler.recalculateTotals(
    recordsToProcess,
    Trigger.oldMap
  );
}
