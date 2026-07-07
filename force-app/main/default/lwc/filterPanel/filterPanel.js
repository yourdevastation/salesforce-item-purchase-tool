import { LightningElement, api, wire } from "lwc";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";

import ITEM_OBJECT from "@salesforce/schema/Item__c";
import TYPE_FIELD from "@salesforce/schema/Item__c.Type__c";
import FAMILY_FIELD from "@salesforce/schema/Item__c.Family__c";

export default class FilterPanel extends LightningElement {
  @api itemCount = 0;

  typeOptions = [{ label: "All Types", value: "" }];
  familyOptions = [{ label: "All Families", value: "" }];

  @wire(getObjectInfo, { objectApiName: ITEM_OBJECT })
  itemObjectInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$itemObjectInfo.data.defaultRecordTypeId",
    fieldApiName: TYPE_FIELD
  })
  wiredTypeValues({ data, error }) {
    if (data) {
      this.typeOptions = [{ label: "All Types", value: "" }, ...data.values];
    } else if (error) {
      console.error("Error fetching Type picklist values", error);
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$itemObjectInfo.data.defaultRecordTypeId",
    fieldApiName: FAMILY_FIELD
  })
  wiredFamilyValues({ data, error }) {
    if (data) {
      this.familyOptions = [
        { label: "All Families", value: "" },
        ...data.values
      ];
    } else if (error) {
      console.error("Error fetching Family picklist values", error);
    }
  }

  handleTypeChange(event) {
    this.dispatchEvent(
      new CustomEvent("filterchange", {
        detail: { filterName: "type", value: event.detail.value }
      })
    );
  }

  handleFamilyChange(event) {
    this.dispatchEvent(
      new CustomEvent("filterchange", {
        detail: { filterName: "family", value: event.detail.value }
      })
    );
  }
}
