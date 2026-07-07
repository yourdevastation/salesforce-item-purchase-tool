import { LightningElement, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";

export default class ItemPurchaseApp extends LightningElement {
  accountId;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference && currentPageReference.state) {
      this.accountId = currentPageReference.state.c__accountId;
    }
  }
}
