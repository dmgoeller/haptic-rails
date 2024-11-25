// ...
class HapticTextFieldElement extends HTMLElement {
  #_resizeObserver;

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

  get #resizeObserver() {
    if (!this.#_resizeObserver) {
      this.#_resizeObserver = new ResizeObserver((entries) => {
        let maxHeight = parseInt(getComputedStyle(this).minHeight || 0);

        for (const entry of entries) {
          const height = entry.contentRect.height +
            parseInt(getComputedStyle(entry.target).paddingTop) +
            parseInt(getComputedStyle(entry.target).paddingBottom);

          maxHeight = Math.max(height, maxHeight);
        }
        this.style.height = `${maxHeight}px`;
      });
    }
    return this.#_resizeObserver;
  }

  #nodeAdded(node) {
    // Input
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
        this.#resizeObserver.observe(node);
      }
      this.inputElement = node;
    } else
    // Clear button
    if (node instanceof HTMLButtonElement) {
      node.setAttribute("tabindex", -1);
      node.addEventListener("click", (e) => {
        if (this.inputElement) {
          this.inputElement.value = "";
          this.#refresh();
          this.inputElement.focus();
        }
        e.target.disabled = true;
        e.preventDefault();
      });
      this.clearButton = node;
      this.setAttribute("with-trailing-icon", "");
    } else
    // Label
    if (node instanceof HTMLLabelElement) {
      this.setAttribute("with-label", "");
    } else
    if (node instanceof HTMLElement) {
      if (node.classList.contains("leading-icon")) {
        this.setAttribute("with-leading-icon", "");
      }
      if (node.classList.contains("trailing-icon")) {
        this.setAttribute("with-trailing-icon", "");
      }
      if (node.classList.contains("field_with_errors")) {
        this.setAttribute("with-errors", "");
      }
    }
  }

  #refresh() {
    if (this.inputElement) {
      const isEmpty = this.inputElement.value.length == 0;

      if (isEmpty) {
        this.setAttribute("empty", "");
      } else {
        this.removeAttribute("empty");
      }
      if (this.inputElement instanceof HapticTextAreaElement) {
        this.inputElement.resize();
      }
      if (this.clearButton) {
        this.clearButton.disabled = isEmpty || this.hasAttribute("disabled");
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
    this.classList.add("haptic");
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
