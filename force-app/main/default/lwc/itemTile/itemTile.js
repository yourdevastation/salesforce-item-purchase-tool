import { LightningElement, api } from "lwc";

export default class ItemTile extends LightningElement {
  @api item;

  get formattedPrice() {
    return this.item && this.item.price ? `$${this.item.price}` : "$0.00";
  }

  handleDetailsClick() {
    console.log("Details clicked for:", this.item.name);
  }

  handleAddClick() {
    console.log("Add to cart clicked for:", this.item.name);
  }
}
