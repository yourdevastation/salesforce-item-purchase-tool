import { api } from "lwc";
import LightningModal from "lightning/modal";

import ITEM_OBJECT from "@salesforce/schema/Item__c";
import NAME_FIELD from "@salesforce/schema/Item__c.Name";
import IMAGE_FIELD from "@salesforce/schema/Item__c.Image__c";
import PRICE_FIELD from "@salesforce/schema/Item__c.Price__c";
import TYPE_FIELD from "@salesforce/schema/Item__c.Type__c";
import FAMILY_FIELD from "@salesforce/schema/Item__c.Family__c";
import QUANTITY_FIELD from "@salesforce/schema/Item__c.AvailableQuantity__c";
import DESCRIPTION_FIELD from "@salesforce/schema/Item__c.Description__c";

export default class ItemDetailsModal extends LightningModal {
  @api recordId;
  @api item;

  objectApiName = ITEM_OBJECT;
  fields = {
    name: NAME_FIELD,
    image: IMAGE_FIELD,
    price: PRICE_FIELD,
    type: TYPE_FIELD,
    family: FAMILY_FIELD,
    quantity: QUANTITY_FIELD,
    description: DESCRIPTION_FIELD
  };

  handleClose() {
    this.close({ action: "close" });
  }

  handleAddToCart() {
    this.close({
      action: "add",
      item: this.item
    });
  }
}
