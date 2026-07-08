import { LightningElement, api } from "lwc";
import ItemDetailsModal from "c/itemDetailsModal";

export default class ItemTile extends LightningElement {
  @api item;

  get formattedPrice() {
    return this.item && this.item.price ? `$${this.item.price}` : "$0.00";
  }

  async handleDetailsClick() {
    const result = await ItemDetailsModal.open({
      size: "small",
      description: "Item Details Modal",
      recordId: this.item.id,
      item: this.item
    });

    if (result && result.action === "add") {
      this.dispatchEvent(
        new CustomEvent("addtocart", {
          detail: { item: result.item }
        })
      );
    }
  }

  handleAddClick() {
    this.dispatchEvent(
      new CustomEvent("addtocart", {
        detail: { item: this.item }
      })
    );
  }
}
