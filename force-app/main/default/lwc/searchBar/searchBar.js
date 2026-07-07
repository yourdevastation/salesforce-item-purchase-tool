import { LightningElement } from "lwc";
import { debounce } from "c/debounceUtil";

export default class SearchBar extends LightningElement {
  debouncedSearch = debounce((searchTerm) => {
    this.dispatchEvent(new CustomEvent("search", { detail: { searchTerm } }));
  }, 300);

  handleSearch(event) {
    this.debouncedSearch(event.target.value);
  }

  disconnectedCallback() {
    this.debouncedSearch.cancel();
  }
}
