import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class CartModal extends LightningModal {
  @api cartItems = [];

  localCartItems = [];

  connectedCallback() {
    this.localCartItems = this.cartItems.map((ci) => ({ ...ci }));
  }

  get flatCartItems() {
    return this.localCartItems.map((itemObj) => {
      const available = itemObj.item.availableQuantity || 0;
      return {
        id: itemObj.id,
        name: itemObj.item.name,
        price: itemObj.item.price,
        quantity: itemObj.quantity,
        availableQuantity: available,
        totalPrice: itemObj.item.price * itemObj.quantity,
        isMaxReached: itemObj.quantity >= available
      };
    });
  }

  get grandTotal() {
    return this.flatCartItems.reduce((sum, row) => sum + row.totalPrice, 0);
  }

  get isCartEmpty() {
    return this.localCartItems.length === 0;
  }

  handlePlus(event) {
    const id = event.currentTarget.dataset.id;
    const index = this.localCartItems.findIndex((ci) => ci.id === id);
    if (index === -1) return;

    const current = this.localCartItems[index];
    const available = current.item.availableQuantity || 0;
    if (current.quantity < available) {
      this.updateLocalQuantity(index, current.quantity + 1);
    }
  }

  handleMinus(event) {
    const id = event.currentTarget.dataset.id;
    const index = this.localCartItems.findIndex((ci) => ci.id === id);
    if (index === -1) return;

    const current = this.localCartItems[index];
    if (current.quantity > 1) {
      this.updateLocalQuantity(index, current.quantity - 1);
    } else {
      this.removeLocalItem(id);
    }
  }

  handleInputChange(event) {
    const id = event.currentTarget.dataset.id;
    const index = this.localCartItems.findIndex((ci) => ci.id === id);
    if (index === -1) return;

    const available = this.localCartItems[index].item.availableQuantity || 0;
    let newVal = parseInt(event.target.value, 10);

    if (isNaN(newVal) || newVal < 1) {
      newVal = 1;
    } else if (newVal > available) {
      newVal = available;
    }

    event.target.value = newVal;
    this.updateLocalQuantity(index, newVal);
  }

  handleDelete(event) {
    this.removeLocalItem(event.currentTarget.dataset.id);
  }

  updateLocalQuantity(index, newQuantity) {
    const updated = [...this.localCartItems];
    updated[index] = { ...updated[index], quantity: newQuantity };
    this.localCartItems = updated;

    this.dispatchEvent(
      new CustomEvent("updatequantity", {
        detail: { id: updated[index].id, newQuantity }
      })
    );
  }

  removeLocalItem(id) {
    this.localCartItems = this.localCartItems.filter((ci) => ci.id !== id);
    this.dispatchEvent(new CustomEvent("removeitem", { detail: { id } }));
  }

  handleCheckout() {
    this.close({ action: "checkout", cartItems: this.localCartItems });
  }

  handleClose() {
    this.close({ action: "close" });
  }
}
