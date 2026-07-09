public with sharing class CartLineDTO {
  @AuraEnabled
  public Id id { get; set; }
  @AuraEnabled
  public Integer quantity { get; set; }

  public CartLineDTO() {
  }
}
