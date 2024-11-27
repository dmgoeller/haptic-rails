class HapticFieldContainerElement extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add("haptic");
  }
}
customElements.define("haptic-field-container", HapticFieldContainerElement);

// ...
class HapticTextFieldElement extends HTMLElement {
  #inputElement = null;
  #clearButton = null;

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add("haptic");

    new MutationObserver((mutationList, observer) => {
      for (let mutationRecord of mutationList) {
        for (let node of mutationRecord.addedNodes) {
          this.#nodeAdded(node);
        }
      }
      this.#refresh();
    }).observe(this, { childList: true, subtree: true });
  }

  #nodeAdded(node) {
    if (node instanceof HTMLElement) {
      node.classList.add("haptic");

      // Input element
      if ((node instanceof HTMLInputElement) ||
          (node instanceof HTMLTextAreaElement) ||
          (node instanceof HTMLSelectElement)) {
        node.addEventListener("focusin", (e) => {
          this.setAttribute("focus", "");
        });
        node.addEventListener("focusout", (e) => {
          this.removeAttribute("focus");
        });
        node.addEventListener("input", (e) => {
          this.#refresh();
        });
        if (node.required) {
          this.setAttribute("required", "");
        }
        if (node.disabled) {
          this.setAttribute("disabled", "");
        }
        if (node instanceof HapticTextAreaElement) {
          node.setAttribute("rows", 1);
        }
        this.#inputElement = node;
      } else
      // Clear button
      if (node instanceof HTMLButtonElement) {
        node.setAttribute("tabindex", -1);

        node.addEventListener("click", (e) => {
          this.#clear();
          e.target.disabled = true;
          e.preventDefault();
        });
        this.#clearButton = node;
        this.setAttribute("with-clear-button", "");
      } else
      // Label
      if (node instanceof HTMLLabelElement) {
        this.setAttribute("with-label", "");
      } else {
        // Other
        if (node.classList.contains("leading-icon")) {
          this.setAttribute("with-leading-icon", "");
        }
        if (node.classList.contains("trailing-icon")) {
          this.setAttribute("with-trailing-icon", "");
        }
        if (node.classList.contains("field_with_errors") ||
            node.classList.contains("field-with-errors")) {
          this.setAttribute("with-errors", "");
        }
      }
    }
  }

  #clear() {
    if (this.#inputElement && !(this.#inputElement instanceof HTMLSelectElement)) {
      this.#inputElement.value = "";
      this.#refresh();
      this.#inputElement.focus();
    }
  }

  #refresh() {
    if (this.#inputElement && !(this.#inputElement instanceof HTMLSelectElement)) {
      const isEmpty = this.#inputElement.value.length == 0;

      if (isEmpty) {
        this.setAttribute("empty", "");
      } else {
        this.removeAttribute("empty");
      }
      if (this.#inputElement instanceof HapticTextAreaElement) {
        this.#inputElement.resize();
      }
      if (this.#clearButton) {
        this.#clearButton.disabled = isEmpty || this.hasAttribute("disabled");
      }
    }
  }
}
customElements.define("haptic-text-field", HapticTextFieldElement);

// ...
class HapticTextAreaElement extends HTMLTextAreaElement {
  #resizer = () => { this.resize() };

  constructor() {
    super();
  }

  connectedCallback() {
    this.addEventListener("input", this.#resizer);
    window.addEventListener("resize", this.#resizer);
  }

  disconnectedCallback() {
    window.removeEventListener("resize", this.#resizer);
  }

  resize() {
    this.style.height = "auto";
    this.style.height = `${this.scrollHeight}px`;
  }
}
customElements.define("haptic-textarea", HapticTextAreaElement, { extends: 'textarea' });
