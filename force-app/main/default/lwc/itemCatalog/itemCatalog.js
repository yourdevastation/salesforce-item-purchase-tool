import { LightningElement, wire } from "lwc";
import getItems from "@salesforce/apex/ItemPurchaseController.getItems";

export default class ItemCatalog extends LightningElement {
  searchTerm = "";
  type = "";
  family = "";

  @wire(getItems, {
    type: "$type",
    family: "$family",
    searchTerm: "$searchTerm"
  })
  itemsWire;

  get items() {
    return this.itemsWire.data ? this.itemsWire.data : [];
  }

  get itemCount() {
    return this.items.length;
  }

  get hasItems() {
    return this.items.length > 0;
  }

  handleSearch(event) {
    this.searchTerm = event.detail.searchTerm;
  }

  handleFilterChange(event) {
    const { filterName, value } = event.detail;
    if (filterName === "type") {
      this.type = value;
    } else if (filterName === "family") {
      this.family = value;
    }
  }

  handleAddToCart(event) {
    this.dispatchEvent(
      new CustomEvent("addtocart", {
        detail: event.detail
      })
    );
  }
}
