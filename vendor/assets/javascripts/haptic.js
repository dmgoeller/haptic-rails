
// ...
class HapticInputElement extends HTMLInputElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic');

    if (this.type == 'submit') {
      this.classList.add('button');
    }
  }
}
customElements.define('haptic-input', HapticInputElement, { extends: 'input' });

// ...
class HapticTextAreaElement extends HTMLTextAreaElement {
  #resizer = () => { this.resize() };

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic');
    this.addEventListener('input', this.#resizer);
    window.addEventListener('resize', this.#resizer);
  }

  disconnectedCallback() {
    window.removeEventListener('resize', this.#resizer);
  }

  resize() {
    this.style.height = 'auto';
    this.style.height = `${this.scrollHeight}px`;
  }
}
customElements.define('haptic-textarea', HapticTextAreaElement, { extends: 'textarea' });

// ...
class HapticTextFieldElement extends HTMLElement {
  static ICON_NAMES = ['error', 'leading', 'trailing'];

  #inputElement = null;
  #clearButton = null;
  #label = null;

  #mutationObserver = new MutationObserver((mutationList) => {
    for (let mutationRecord of mutationList) {
      if (mutationRecord.attributeName == 'disabled') {
        if (mutationRecord.target.disabled) {
          this.setAttribute('disabled', '');
        } else {
          this.removeAttribute('disabled');
        }
      } else
      if (mutationRecord.attributeName == 'required') {
        if (mutationRecord.target.required) {
          this.setAttribute('required', '');
        } else {
          this.removeAttribute('required');
        }
      }
    }
  });

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic');

    new MutationObserver((mutationList) => {
      for (let mutationRecord of mutationList) {
        for (let node of mutationRecord.addedNodes) {
          this.#nodeAdded(node);
        }
        for (let node of mutationRecord.removedNodes) {
          this.#nodeRemoved(node);
        }
      }
      this.#refresh();
    }).observe(this, { childList: true, subtree: true });
  }

  clear() {
    if (this.#inputElement) {
      this.#inputElement.value = '';
      this.#refresh();
    }
  }

  resetErrors() {
    this.querySelectorAll('.error-icon, .error').forEach(element => {
      element.remove();
    });
    this.removeAttribute('with-errors');
  }

  #nodeAdded(node) {
    if (node instanceof HTMLElement) {
      if ((node instanceof HTMLInputElement) ||
          (node instanceof HTMLTextAreaElement) ||
          (node instanceof HTMLSelectElement)) {
        if (!this.#inputElement) {
          node.classList.add('haptic');
          node.addEventListener('focusin', () => {
            this.setAttribute('focus', '');
          });
          node.addEventListener('focusout', () => {
            this.removeAttribute('focus');
          });
          node.addEventListener('input', () => {
            this.#refresh();
          });
          if (node.required) {
            this.setAttribute('required', '');
          }
          if (node.disabled) {
            this.setAttribute('disabled', '');
          }
          if (node instanceof HapticTextAreaElement) {
            if (!node.hasAttribute('rows')) {
              node.setAttribute('rows', 1);
            }
            this.setAttribute('auto-growing', '');
          }
          this.#mutationObserver.observe(node, { attributes: true });
          this.#inputElement = node;
        }
      } else
      if (node instanceof HTMLLabelElement) {
        if (!this.#label) {
          this.setAttribute('with-label', '');
          this.#label = node;
        }
      } else
      if (node.classList.contains('toolbutton')) {
        if (!this.#clearButton) {
          node.addEventListener('click', e => {
            this.clear();
            this.#inputElement?.focus();
            e.preventDefault();
          });
          this.setAttribute('with-clear-button', '');
          this.#clearButton = node;
        }
      } else {
        for (let iconName of HapticTextFieldElement.ICON_NAMES) {
          if (node.classList.contains(`${iconName}-icon`)) {
            this.setAttribute(`with-${iconName}-icon`, '');
          }
        }
      }
    }
  }

  #nodeRemoved(node) {
    switch (node) {
      case this.#inputElement:
        this.removeAttribute('disabled');
        this.removeAttribute('required');
        this.removeAttribute('auto-growing');
        this.setAttribute('empty', '');
        this.#mutationObserver.disconnect();
        this.#inputElement = null;
        break;
      case this.#clearButton:
        this.removeAttribute('with-clear-button');
        this.#clearButton = null;
        break;
      case this.#label:
        this.removeAttribute('with-label');
        this.#label = null;
        break;
      default:
        for (let iconName of HapticTextFieldElement.ICON_NAMES) {
          if (node.classList.contains(`${iconName}-icon`)) {
            if (!this.querySelector(`${iconName}-icon`)) {
              this.removeAttribute(`with-${iconName}-icon`);
            }
          }
        }
    }
  }

  #refresh() {
    if (this.#inputElement) {
      const isEmpty = this.#inputElement.value.length == 0;
      if (isEmpty) {
        this.setAttribute('empty', '');
      } else {
        this.removeAttribute('empty');
      }
      if (this.#inputElement instanceof HapticTextAreaElement) {
        this.#inputElement.resize();
      }
    }
  }
}
customElements.define('haptic-text-field', HapticTextFieldElement);
