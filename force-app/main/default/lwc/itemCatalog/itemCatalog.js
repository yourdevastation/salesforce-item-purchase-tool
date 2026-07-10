import { LightningElement, wire, api, track } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getItems from "@salesforce/apex/ItemPurchaseController.getItems";

export default class ItemCatalog extends LightningElement {
  searchTerm = "";
  type = "";
  family = "";
  isLoading = false;

  limitSize = 9;
  offsetSize = 0;
  @track allItems = [];
  hasMore = false;
  itemsWireResult;

  get queryLimit() {
    return this.limitSize + 1;
  }

  @wire(getItems, {
    type: "$type",
    family: "$family",
    searchTerm: "$searchTerm",
    limitSize: "$queryLimit",
    offsetSize: "$offsetSize"
  })
  wiredGetItems(result) {
    this.itemsWireResult = result;

    if (result.data) {
      let fetchedItems = [...result.data];

      this.hasMore = fetchedItems.length > this.limitSize;

      if (this.hasMore) {
        fetchedItems.pop();
      }

      if (this.offsetSize === 0) {
        this.allItems = fetchedItems;
      } else {
        this.allItems = [...this.allItems, ...fetchedItems];
      }
    } else if (result.error) {
      console.error(result.error);
      this.allItems = [];
    }
  }

  get items() {
    return this.allItems;
  }

  get itemCount() {
    return this.allItems.length;
  }

  get hasItems() {
    return this.allItems.length > 0;
  }

  handleLoadMore() {
    this.offsetSize += this.limitSize;
  }

  @api
  async refreshList() {
    this.isLoading = true;
    this.offsetSize = 0;
    try {
      await refreshApex(this.itemsWireResult);
    } finally {
      this.isLoading = false;
    }
  }

  handleSearch(event) {
    this.searchTerm = event.detail.searchTerm;
    this.offsetSize = 0;
  }

  handleFilterChange(event) {
    const { filterName, value } = event.detail;
    if (filterName === "type") {
      this.type = value;
    } else if (filterName === "family") {
      this.family = value;
    }
    this.offsetSize = 0;
  }

  handleAddToCart(event) {
    this.dispatchEvent(
      new CustomEvent("addtocart", {
        detail: event.detail
      })
    );
  }
}
