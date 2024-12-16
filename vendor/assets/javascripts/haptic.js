
class HapticButtonElement extends HTMLButtonElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-button');
  }
}
customElements.define('haptic-button', HapticButtonElement, { extends: 'button' });

class HapticInputElement extends HTMLInputElement {
  static observedAttributes = ['disabled'];

  constructor() {
    super();
  }

  connectedCallback() {
    switch (this.type) {
      case 'checkbox':
        if (!this.classList.contains('haptic-switch')) {
          this.classList.add('haptic-checkbox');
        }
        break;
      case 'radio':
        this.classList.add('haptic-radio-button');
        break;
      case 'submit':
        this.classList.add('haptic-button');
        break;
      default:
        this.classList.add('haptic-field');
    }
  }

  attributeChangedCallback(name, oldValue, newValue) {
    for (let label of this.labels) {
      if (this.disabled) {
        label.classList.add('grayed');
      } else {
        label.classList.remove('grayed');
      }
    }
  }
}
customElements.define('haptic-input', HapticInputElement, { extends: 'input' });

class HapticLabelElement extends HTMLLabelElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-label');
  }
}
customElements.define('haptic-label', HapticLabelElement, { extends: 'label' });

class HapticSelectElement extends HTMLSelectElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-field');
  }
}
customElements.define('haptic-select', HapticSelectElement, { extends: 'select' });

class HapticTextAreaElement extends HTMLTextAreaElement {
  #resizer = () => { this.resize() };

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-field');
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

class HapticTextFieldElement extends HTMLElement {
  static ICON_NAMES = ['error', 'leading', 'trailing'];

  #control = null;
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
    if (this.#control) {
      this.#control.value = '';
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
        if (!this.#control) {
          node.setAttribute('data-embedded', '');
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
          this.#control = node;
        }
      } else
      if (node instanceof HTMLLabelElement) {
        if (!this.#label) {
          this.setAttribute('with-label', '');
          this.#label = node;
        }
      } else
      if (node.classList.contains('clear-button')) {
        if (!this.#clearButton) {
          node.addEventListener('click', e => {
            this.clear();
            this.#control?.focus();
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
      case this.#control:
        node.removeAttribute('data-embedded');
        this.removeAttribute('disabled');
        this.removeAttribute('required');
        this.removeAttribute('auto-growing');
        this.setAttribute('empty', '');
        this.#mutationObserver.disconnect();
        this.#control = null;
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
    if (this.#control) {
      const isEmpty = this.#control.value.length == 0;
      if (isEmpty) {
        this.setAttribute('empty', '');
      } else {
        this.removeAttribute('empty');
      }
      if (this.#control instanceof HapticTextAreaElement) {
        this.#control.resize();
      }
    }
  }
}
customElements.define('haptic-text-field', HapticTextFieldElement);
