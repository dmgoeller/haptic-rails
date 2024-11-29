
// ...
class HapticInputElement extends HTMLInputElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic');
  }
}
customElements.define("haptic-input", HapticInputElement, { extends: "input" });

// ...
class HapticTextAreaElement extends HTMLTextAreaElement {
  #resizer = () => { this.resize() };

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic');
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
customElements.define("haptic-textarea", HapticTextAreaElement, { extends: "textarea" });

// ...
class HapticTextFieldElement extends HTMLElement {
  #inputElement = null;

  #mutationObserver = new MutationObserver((mutationList) => {
    for (let mutationRecord of mutationList) {
      if (mutationRecord.attributeName == "disabled") {
        if (mutationRecord.target.disabled) {
          this.setAttribute("data-disabled", "");
        } else {
          this.removeAttribute("data-disabled");
        }
      }
    }
  });

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add("haptic");

    new MutationObserver((mutationList) => {
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
      if ((node instanceof HTMLInputElement) ||
          (node instanceof HTMLTextAreaElement) ||
          (node instanceof HTMLSelectElement)) {
        node.classList.add('haptic');
        node.addEventListener("focusin", () => {
          this.setAttribute("data-focus", "");
        });
        node.addEventListener("focusout", () => {
          this.removeAttribute("data-focus");
        });
        node.addEventListener("input", () => {
          this.#refresh();
        });
        if (node.required) {
          this.setAttribute("data-required", "");
        }
        if (node.disabled) {
          this.setAttribute("data-disabled", "");
        }
        if (node instanceof HapticTextAreaElement) {
          if (!node.hasAttribute("rows")) {
            node.setAttribute("rows", 1);
          }
        }
        this.#mutationObserver.observe(node, { attributes: true });
        this.#inputElement = node;
      } else
      if (node instanceof HTMLLabelElement) {
        this.setAttribute("data-with-label", "");
      } else
      if (node.classList.contains("clear-button")) {
        node.addEventListener("click", e => {
          this.#clear();
          e.preventDefault();
        });
        this.setAttribute("data-with-clear-button", "");
      } else
      if (node.classList.contains("leading-icon")) {
        this.setAttribute("data-with-leading-icon", "");
      } else
      if (node.classList.contains("trailing-icon")) {
        this.setAttribute("data-with-trailing-icon", "");
      }
    }
  }

  #clear() {
    if (this.#inputElement) {
      this.#inputElement.value = "";
      this.#refresh();
      this.#inputElement.focus();
    }
  }

  #refresh() {
    if (this.#inputElement) {
      const isEmpty = this.#inputElement.value.length == 0;
      if (isEmpty) {
        this.setAttribute("data-empty", "");
      } else {
        this.removeAttribute("data-empty");
      }
      if (this.#inputElement instanceof HapticTextAreaElement) {
        this.#inputElement.resize();
      }
    }
  }
}
customElements.define("haptic-text-field", HapticTextFieldElement);
