public without sharing class PurchaseLineTriggerHandler {
  public static void recalculateTotals(
    List<PurchaseLine__c> records,
    Map<Id, PurchaseLine__c> oldMap
  ) {
    Set<Id> purchaseIds = collectAffectedPurchaseIds(records, oldMap);
    if (purchaseIds.isEmpty()) {
      return;
    }

    Map<Id, Purchase__c> purchasesToUpdate = new Map<Id, Purchase__c>();
    for (Id pId : purchaseIds) {
      purchasesToUpdate.put(
        pId,
        new Purchase__c(Id = pId, TotalItems__c = 0, GrandTotal__c = 0)
      );
    }

    for (PurchaseLine__c line : [
      SELECT PurchaseId__c, Amount__c, UnitCost__c
      FROM PurchaseLine__c
      WHERE PurchaseId__c IN :purchaseIds
    ]) {
      Purchase__c parent = purchasesToUpdate.get(line.PurchaseId__c);
      if (parent == null)
        continue;

      Decimal amount = line.Amount__c != null ? line.Amount__c : 0;
      Decimal cost = line.UnitCost__c != null ? line.UnitCost__c : 0;

      parent.TotalItems__c += amount;
      parent.GrandTotal__c += amount * cost;
    }

    update purchasesToUpdate.values();
  }

  private static Set<Id> collectAffectedPurchaseIds(
    List<PurchaseLine__c> records,
    Map<Id, PurchaseLine__c> oldMap
  ) {
    Set<Id> purchaseIds = new Set<Id>();
    for (PurchaseLine__c line : records) {
      if (line.PurchaseId__c != null) {
        purchaseIds.add(line.PurchaseId__c);
      }
      if (oldMap != null && oldMap.containsKey(line.Id)) {
        Id oldPurchaseId = oldMap.get(line.Id).PurchaseId__c;
        if (oldPurchaseId != null && oldPurchaseId != line.PurchaseId__c) {
          purchaseIds.add(oldPurchaseId);
        }
      }
    }
    return purchaseIds;
  }
}
