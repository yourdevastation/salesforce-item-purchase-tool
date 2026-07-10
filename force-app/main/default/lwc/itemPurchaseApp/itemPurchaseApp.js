import { LightningElement, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CartModal from "c/cartModal";
import ItemCreateModal from "c/itemCreateModal";

import checkout from "@salesforce/apex/ItemPurchaseController.checkout";
import createItemWithImage from "@salesforce/apex/ItemPurchaseController.createItemWithImage";

import USER_ID from "@salesforce/user/Id";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import IS_MANAGER_FIELD from "@salesforce/schema/User.IsManager__c";

export default class ItemPurchaseApp extends NavigationMixin(LightningElement) {
  accountId;
  cartItems = [];
  isManager = false;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference && currentPageReference.state) {
      this.accountId = currentPageReference.state.c__accountId;
    }
  }

  @wire(getRecord, { recordId: USER_ID, fields: [IS_MANAGER_FIELD] })
  wiredUser({ error, data }) {
    if (data) {
      this.isManager = getFieldValue(data, IS_MANAGER_FIELD);
    } else if (error) {
      console.error("Error fetching user data", error);
      this.showToast("Error", "Failed to verify user permissions", "error");
    }
  }

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

  async handleCreateItemClick() {
    const result = await ItemCreateModal.open({
      size: "medium",
      description: "Create New Item Modal"
    });

    if (result && result.action === "createitem") {
      this.processItemCreation(result.data);
    }
  }

  async processItemCreation(itemData) {
    try {
      this.showToast(
        "Processing",
        "Sending request to Unsplash and saving...",
        "info"
      );

      await createItemWithImage({ itemDto: itemData });

      this.showToast(
        "Success",
        `Item "${itemData.name}" created successfully!`,
        "success"
      );
      await this.template.querySelector("c-item-catalog").refreshList();
    } catch (error) {
      const errorMessage = error.body ? error.body.message : error.message;
      this.showToast("Create Failed", errorMessage, "error");
    }
  }
}
