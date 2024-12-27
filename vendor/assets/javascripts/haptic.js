
class HapticButtonElement extends HTMLButtonElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-button');
  }
}
customElements.define('haptic-button', HapticButtonElement, { extends: 'button' });

class HapticFormElement extends HTMLFormElement {
  #requiredFields;
  #submitButtons;

  constructor() {
    super();
    this.#requiredFields = new Set();
    this.#submitButtons = new Set();
  }

  connectedCallback() {
    new MutationObserver(mutationList => {
      for (let mutationRecord of mutationList) {
        for (let node of mutationRecord.addedNodes) {
          this.#nodeAdded(node);
        }
        for (let node of mutationRecord.removedNodes) {
          this.#nodeRemoved(node);
         }
      }
    }).observe(this, { childList: true, subtree: true });
  }

  handleEvent(event) {
    this.#refresh();
  }

  #nodeAdded(node) {
    if (node instanceof HTMLInputElement ||
        node instanceof HTMLTextAreaElement ||
        node instanceof HTMLSelectElement) {
      switch (node.type) {
        case 'submit':
          this.#submitButtons.add(node);
          this.#refresh();
        case 'hidden':
          break;
        default:
          if (node.hasAttribute('required')) {
            node.addEventListener('change', this);
            node.addEventListener('input', this);
            this.#requiredFields.add(node);
            this.#refresh();
          }
      }
    }
  }

  #nodeRemoved(node) {
    if (this.#requiredFields.has(node)) {
      node.removeEventListener('change', this);
      node.removeEventListener('input', this);
      this.#requiredFields.delete(node);
    } else
    if (this.#submitButtons.has(node)) {
      this.#submitButtons.delete(node);
    }
  }

  #refresh() {
    if (this.#submitButtons.size > 0) {
      let submittable = true;
      for (let field of this.#requiredFields) {
        if (!field.value) {
          submittable = false;
          break;
        }
      }
      for (let control of this.#submitButtons) {
        control.disabled = !submittable;
      }
    }
  }
}
customElements.define('haptic-form', HapticFormElement, { extends: 'form' });

class HapticInputElement extends HTMLInputElement {
  static observedAttributes = ['disabled'];

  #initialValue = null;

  constructor() {
    super();
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (!this.classList.contains('embedded')) {
      for (let label of this.labels) {
        if (this.disabled) {
          label.classList.add('grayed');
        } else {
          label.classList.remove('grayed');
        }
      }
    }
  }

  connectedCallback() {
    switch (this.type) {
      case 'checkbox':
        if (!this.classList.contains('haptic-switch')) {
          this.classList.add('haptic-checkbox');
        }
        this.#initialValue = this.checked;
        break;
      case 'radio':
        this.classList.add('haptic-radio-button');
        this.#initialValue = this.checked;
        break;
      case 'submit':
        this.classList.add('haptic-button');
        break;
      default:
        this.classList.add('haptic-field');
        this.#initialValue = this.value;
    }
  }

  reset() {
    switch (this.type) {
      case 'checkbox':
      case 'radio':
        if (this.checked != this.#initialValue) {
          this.checked = this.#initialValue;
          this.dispatchEvent(new Event('change'));
        }
        break;
      default:
        if (this.value != this.#initialValue) {
          this.value = this.#initialValue;
          this.dispatchEvent(new Event('change'));
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

class HapticListItemElement extends HTMLLIElement {
  #checkbox = null;
  #mutationObserver = null;

  constructor() {
    super();
    this.#mutationObserver = new MutationObserver((mutationList) => {
      for (let mutationRecord of mutationList) {
        if (mutationRecord.attributeName == 'disabled') {
          if (mutationRecord.target.disabled) {
            this.setAttribute('disabled', '');
          } else {
            this.removeAttribute('disabled');
          }
        }
      }
    });
  }

  connectedCallback() {
    this.classList.add('haptic-list-item');

    new MutationObserver(mutationList => {
      for (let mutationRecord of mutationList) {
        for (let node of mutationRecord.addedNodes) {
          if (node instanceof HTMLInputElement &&
              node.type == 'checkbox' &&
              !this.#checkbox) {
            node.classList.add('embedded');
            this.#mutationObserver.observe(node, { attributes: true });
            this.#checkbox = node;
          }
        }
        for (let node of mutationRecord.removedNodes) {
          if (node === this.#checkbox) {
            node.classList.remove('embedded');
            this.#mutationObserver.disconnect();
            this.#checkbox = null;
          }
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }
}
customElements.define('haptic-list-item', HapticListItemElement, { extends: 'li' });

class HapticSelectElement extends HTMLSelectElement {
  #initialValue = null;

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-field');
    this.#initialValue = this.value;
  }

  reset() {
    if (this.value != this.#initialValue) {
      this.value = this.#initialValue;
      this.dispatchEvent(new Event('change'));
    }
  }
}
customElements.define('haptic-select', HapticSelectElement, { extends: 'select' });

class HapticTextAreaElement extends HTMLTextAreaElement {
  #initialValue = null;
  #resizer = () => { this.resize() };

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-field');
    this.#initialValue = this.value;
    this.addEventListener('input', this.#resizer);
    window.addEventListener('resize', this.#resizer);
  }

  disconnectedCallback() {
    window.removeEventListener('resize', this.#resizer);
  }

  reset() {
    if (this.value != this.#initialValue) {
      this.value = this.#initialValue;
      this.dispatchEvent(new Event('change'));
    }
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
  #resetErrorOnChange = null;

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
    if (this.hasAttribute('reset-error-on-change')) {
      const value = this.getAttribute('reset-error-on-change');
      if (value == '' || value == 'reset-error-on-change') {
        this.#resetErrorOnChange = ['itself'];
      } else {
        this.#resetErrorOnChange = value.split(/\s+/);
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
            this.#resetErrorOnChange?.forEach(fieldId => {
              if (fieldId == 'itself') {
                this.resetError();
              } else {
                this.#control?.form?.querySelector(
                  `haptic-text-field[for="${fieldId}"]`
                )?.resetError();
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

  resetError() {
    if (this.hasAttribute('invalid')) {
      if (this.hasAttribute('with-error-icon')) {
        setTimeout(() => {
          this.querySelectorAll('.error-icon').forEach(
            element => { element.remove() }
          );
        }, 400);
      }
      this.removeAttribute('invalid');
    }
  }

  #nodeAdded(node) {
    if (node instanceof HTMLElement) {
      if (node instanceof HTMLInputElement ||
          node instanceof HTMLTextAreaElement ||
          node instanceof HTMLSelectElement) {
        if (!this.#control) {
          node.classList.add('embedded');

          if (node.required) {
            this.setAttribute('required', '');
          }
          if (node.disabled) {
            this.setAttribute('disabled', '');
          }
          if (!node.validity.valid) {
            this.setAttribute('invalid', '');
          }
          if (node instanceof HapticTextAreaElement) {
            if (!node.hasAttribute('rows')) {
              node.setAttribute('rows', 1);
            }
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
        node.classList.remove('embedded');
        this.removeAttribute('disabled');
        this.removeAttribute('invalid');
        this.removeAttribute('required');
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
      if (this.#control.value.length == 0) {
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
