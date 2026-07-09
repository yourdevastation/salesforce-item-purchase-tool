import { LightningElement, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CartModal from "c/cartModal";

import checkout from "@salesforce/apex/ItemPurchaseController.checkout";

export default class ItemPurchaseApp extends NavigationMixin(LightningElement) {
  accountId;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference && currentPageReference.state) {
      this.accountId = currentPageReference.state.c__accountId;
    }
  }

  cartItems = [];

  get cartItemCount() {
    return this.cartItems.reduce(
      (total, cartItem) => total + cartItem.quantity,
      0
    );
  }

  get cartButtonLabel() {
    return this.cartItemCount > 0 ? `Cart (${this.cartItemCount})` : "Cart";
  }

  handleAddToCart(event) {
    const newItem = event.detail.item;

    const existingItemIndex = this.cartItems.findIndex(
      (ci) => ci.id === newItem.id
    );

    if (existingItemIndex !== -1) {
      const existingItem = this.cartItems[existingItemIndex];

      if (existingItem.quantity < newItem.availableQuantity) {
        const updatedCart = [...this.cartItems];
        updatedCart[existingItemIndex] = {
          ...existingItem,
          quantity: existingItem.quantity + 1
        };

        this.cartItems = updatedCart;
        this.showToast(
          "Success",
          `Increased quantity of ${newItem.name} to ${existingItem.quantity + 1}`,
          "success"
        );
      } else {
        this.showToast(
          "Out of Stock",
          `You cannot add more ${newItem.name}. Only ${newItem.availableQuantity} available.`,
          "error"
        );
      }
    } else {
      if (newItem.availableQuantity > 0) {
        this.cartItems = [
          ...this.cartItems,
          {
            id: newItem.id,
            item: newItem,
            quantity: 1
          }
        ];
        this.showToast("Success", `${newItem.name} added to cart!`, "success");
      } else {
        this.showToast(
          "Out of Stock",
          `${newItem.name} is currently unavailable.`,
          "error"
        );
      }
    }
  }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }

  async openCartModal() {
    const result = await CartModal.open({
      size: "medium",
      description: "Shopping Cart Modal",
      cartItems: this.cartItems,

      onremoveitem: (event) => {
        const idToRemove = event.detail.id;
        this.cartItems = this.cartItems.filter((ci) => ci.id !== idToRemove);
      },

      onupdatequantity: (event) => {
        const { id, newQuantity } = event.detail;
        const itemIndex = this.cartItems.findIndex((ci) => ci.id === id);

        if (itemIndex !== -1) {
          const updatedCart = [...this.cartItems];
          updatedCart[itemIndex] = {
            ...updatedCart[itemIndex],
            quantity: newQuantity
          };
          this.cartItems = updatedCart;
        }
      }
    });

    if (result && result.action === "checkout") {
      this.processCheckout(result.cartItems);
    }
  }

  async processCheckout(itemsToCheckout) {
    try {
      const cartLinesDto = itemsToCheckout.map((cartObj) => ({
        id: cartObj.id,
        quantity: cartObj.quantity
      }));

      const purchaseId = await checkout({
        accountId: this.accountId,
        cartLines: cartLinesDto
      });

      this.showToast("Success", "Order placed successfully!", "success");
      this.cartItems = [];

      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: purchaseId,
          objectApiName: "Purchase__c",
          actionName: "view"
        }
      });
    } catch (error) {
      const errorMessage = error.body ? error.body.message : error.message;
      this.showToast("Checkout Failed", errorMessage, "error");
    }
  }
}
