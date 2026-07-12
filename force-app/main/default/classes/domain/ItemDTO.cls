@SuppressWarnings('PMD.AvoidBooleanMethodParameters')
// isOutOfStock is an @AuraEnabled DTO field required by the LWC client.
// PMD incorrectly flags the Boolean constructor assignment as a "method parameter".
public with sharing class ItemDTO {
  @AuraEnabled
  public Id id { get; set; }
  @AuraEnabled
  public String name { get; set; }
  @AuraEnabled
  public String description { get; set; }
  @AuraEnabled
  public String type { get; set; }
  @AuraEnabled
  public String family { get; set; }
  @AuraEnabled
  public String image { get; set; }
  @AuraEnabled
  public Decimal price { get; set; }
  @AuraEnabled
  public Decimal availableQuantity { get; set; }
  @AuraEnabled
  public Boolean isOutOfStock { get; set; }

  public ItemDTO(Item__c item) {
    this.id = item.Id;
    this.name = item.Name;
    this.description = item.Description__c;
    this.type = item.Type__c;
    this.family = item.Family__c;
    this.image = item.Image__c;
    this.price = item.Price__c;
    this.availableQuantity = item.AvailableQuantity__c;
    this.isOutOfStock = (item.AvailableQuantity__c == 0);
  }

  public ItemDTO() {
  }
}
