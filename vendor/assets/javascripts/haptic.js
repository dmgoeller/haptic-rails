
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
  #listens = null;
  #mutationObserver = null;
  #resetErrorsOnChange = null;

  constructor() {
    super();
    this.#listens = new Map();

    this.#mutationObserver = new MutationObserver((mutationList) => {
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
  }

  connectedCallback() {
    if (this.hasAttribute('reset-errors-on-change')) {
      const value = this.getAttribute('reset-errors-on-change');
      if (value == '' || value == 'reset-errors-on-change') {
        this.#resetErrorsOnChange = ['itself'];
      } else {
        this.#resetErrorsOnChange = value.split(/\s+/);
      }
    }
    new MutationObserver(mutationList => {
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

  handleEvent(event) {
    switch (event.target) {
      case this.#control:
        switch (event.type) {
          case 'change':
            this.#resetErrorsOnChange?.forEach(fieldId => {
              if (fieldId == 'itself') {
                this.resetErrors();
              } else {
                this.#control?.form?.querySelector(
                  `haptic-text-field[for="${fieldId}"]`
                )?.resetErrors();
              }
            })
          case 'input':
            this.#refresh();
            break;
          case 'focusin':
            this.setAttribute('focus', '');
            break;
          case 'focusout':
            this.removeAttribute('focus');
        }
        break;
      case this.#clearButton:
        if (event.type == 'click') {
          this.clear();
          this.#control?.focus();
          event.preventDefault();
        }
    }
  }

  clear() {
    if (this.#control && this.#control.value != '') {
      this.#control.value = '';
      this.#control.dispatchEvent(new Event('change'));
    }
  }

  resetErrors() {
    this.querySelectorAll('.error-icon, .error').forEach(element => {
      element.remove()
    });
    this.removeAttribute('with-errors');
  }

  #nodeAdded(node) {
    if (node instanceof HTMLElement) {
      if (node instanceof HTMLInputElement ||
          node instanceof HTMLTextAreaElement ||
          node instanceof HTMLSelectElement) {
        if (!this.#control) {
          node.setAttribute('data-embedded', '');

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
          this.#startListen(node, 'change');

          if (this.#clearButton) {
            this.#startListen(node, 'input');
          }
          if (this.hasAttribute('focus-indicator')) {
            this.#startListen(node, 'focusin');
            this.#startListen(node, 'focusout');
          }
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
          this.setAttribute('with-clear-button', '');
          this.#startListen(node, 'click');

          if (this.#control) {
            this.#startListen(this.#control, 'input');
          }
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
        this.#stopListen(node);
        this.#mutationObserver.disconnect();
        this.#control = null;
        break;
      case this.#clearButton:
        this.removeAttribute('with-clear-button');
        this.#stopListen(node);
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

  #startListen(target, type) {
    let types = this.#listens.get(target);
    if (typeof(types) == 'undefined') {
      types = new Set();
      this.#listens.set(target, types);
    }
    if (!types.has(type)) {
      target.addEventListener(type, this);
      types.add(type);
    }
  }

  #stopListen(target) {
    this.#listens.get(target)?.forEach(type => {
      target.removeEventListener(type, this);
    });
    this.#listens.delete(target);
  }
}
customElements.define('haptic-text-field', HapticTextFieldElement);
