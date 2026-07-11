import LightningModal from "lightning/modal";

import ITEM_OBJECT from "@salesforce/schema/Item__c";
import NAME_FIELD from "@salesforce/schema/Item__c.Name";
import PRICE_FIELD from "@salesforce/schema/Item__c.Price__c";
import TYPE_FIELD from "@salesforce/schema/Item__c.Type__c";
import FAMILY_FIELD from "@salesforce/schema/Item__c.Family__c";
import QUANTITY_FIELD from "@salesforce/schema/Item__c.AvailableQuantity__c";
import DESCRIPTION_FIELD from "@salesforce/schema/Item__c.Description__c";

export default class ItemCreateModal extends LightningModal {
  objectApiName = ITEM_OBJECT;

  fields = {
    name: NAME_FIELD,
    price: PRICE_FIELD,
    type: TYPE_FIELD,
    family: FAMILY_FIELD,
    quantity: QUANTITY_FIELD,
    description: DESCRIPTION_FIELD
  };

  handleClose() {
    this.close({ action: "close" });
  }

  triggerSubmit() {
    this.template.querySelector('[data-id="hiddenSubmit"]').click();
  }

  handleSubmit(event) {
    event.preventDefault();
    const sfFields = event.detail.fields;

    const dtoData = {
      name: sfFields.Name,
      price: parseFloat(sfFields.Price__c),
      type: sfFields.Type__c,
      family: sfFields.Family__c,
      availableQuantity: parseInt(sfFields.AvailableQuantity__c, 10),
      description: sfFields.Description__c
    };

    this.close({
      action: "createitem",
      data: dtoData
    });
  }
}
