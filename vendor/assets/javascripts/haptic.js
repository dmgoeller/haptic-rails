
class HapticMutationObserver extends MutationObserver {
  constructor(callbacks = {}) {
    super(mutationList => {
      for (let mutationRecord of mutationList) {
        for (let node of mutationRecord.addedNodes) {
          if (callbacks.nodeAdded) {
            callbacks.nodeAdded(node);
          }
        }
        for (let node of mutationRecord.removedNodes) {
          if (callbacks.nodeRemoved) {
            callbacks.nodeRemoved(node);
          }
        }
      }
    });
  }
}

class HapticButtonElement extends HTMLButtonElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-button');
  }
}
customElements.define('haptic-button', HapticButtonElement, { extends: 'button' });

class HapticDropdownElement extends HTMLElement {
  static get openDropdown() {
    return document.querySelector('haptic-dropdown[popover-open]');
  }

  #toggle = null;
  #popover = null;
  #backdrop = null;
  #fields = new Set();
  #resetButtons = new Set();

  constructor() {
    super();
  }

  connectedCallback() {
    this.addEventListener('keyup', this);

    new HapticMutationObserver({
      nodeAdded: node => {
        if (node instanceof HTMLElement) {
          const classList = node.classList;

          if (classList.contains('toggle')) {
            if (!this.#toggle) {
              node.addEventListener('click', this);
              this.#toggle = node;
            }
          } else
          if (classList.contains('popover')) {
            if (!this.#popover) {
              this.#popover = node;
            }
          } else
          if (classList.contains('backdrop')) {
            if (!this.#backdrop) {
              node.addEventListener('click', this);
              this.#backdrop = node;
            }
          } else
          if (node.type == 'reset') {
            node.addEventListener('click', this);
            this.#resetButtons.add(node);
          } else
          if (node instanceof HapticInputElement ||
              node instanceof HapticSelectElement ||
              node instanceof HapticTextAreaElement) {
            this.#fields.add(node);
          }
        }   
      },
      nodeRemoved: node => {
        switch (node) {
          case this.#toggle:
            node.removeEventListener('click', this);
            this.#toggle = null;
            break;
          case this.#popover:
            this.#popover = null;
            break;
          case this.#backdrop:
            node.removeEventListener('click', this);
            this.#backdrop = null;
            break;
          default:
            if (this.#fields.contains(node)) {
              this.#fields.remove(node);
            } else
            if (this.#resetButtons.contains(node)) {
              node.removeEventListener('click', this);
              this.#resetButtons.remove(node);
            }
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }

  get isOpen() {
    return this.hasAttribute('popover-open');
  }

  showPopover() {
    this.setAttribute('popover-open', '');
  }

  hidePopover() {
    this.removeAttribute('popover-open');
  }

  resetAndClose() {
    if (this.hasAttribute('popover-open')) {
      this.hidePopover();
      for (let field of this.#fields) {
        field.reset();
      }
    }
  }

  handleEvent(event) {
    switch (event.type) {
      case 'click':
        if (!this.isOpen) {
          HapticDropdownElement.openDropdown?.resetAndClose();
          this.showPopover();
        } else {
          this.resetAndClose();
        }
        event.preventDefault();
        break;
      case 'keyup':
        if (event.key === 'Escape') {
          this.resetAndClose();
        }
    }
  }
}
customElements.define('haptic-dropdown', HapticDropdownElement);

class HapticFieldElement extends HTMLElement {
  static ICON_NAMES = ['error', 'leading', 'trailing'];

  control = null;
  label = null;

  #listens = new Map();
  #setValidOnChange = null;

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

  get valid() {
    return !this.hasAttribute('invalid');
  }

  set valid(value) {
    switch (value) {
      case true:
        if (this.hasAttribute('invalid')) {
          this.removeAttribute('invalid');
        }
        if (this.hasAttribute('with-error-icon')) {
          setTimeout(
            () => { this.removeAttribute('with-error-icon') },
            400
          );
        }
        return true;

      case false:
        if (!this.hasAttribute('with-error-icon')) {
          this.setAttribute('with-error-icon', '');
        }
        if (!this.hasAttribute('invalid')) {
          setTimeout(
            () => { this.setAttribute('invalid', '') },
            this.hasAttribute('with-clear-button') ? 200 : 0
          );
        }
        return false;
    }
  }

  connectedCallback() {
    if (this.hasAttribute('set-valid-on-change')) {
      const value = this.getAttribute('set-valid-on-change');
      if (value == '' || value == 'set-valid-on-change') {
        this.#setValidOnChange = ['itself'];
      } else {
        this.#setValidOnChange = value.split(/\s+/);
      }
    }
    new HapticMutationObserver({
      nodeAdded: node => {
        this.nodeAdded(node);
        this.#refresh();
      },
      nodeRemoved: node => {
        this.nodeRemoved(node);
        this.#refresh();
      }
    }).observe(this, { childList: true, subtree: true });
  }

  handleEvent(event) {
    if (event.target === this.control) {
      switch (event.type) {
        case 'change':
          this.#setValidOnChange?.forEach(fieldId => {
            const textField = fieldId == 'itself' ? this :
              this.control?.form?.querySelector(
                `haptic-text-field[for="${fieldId}"]`
              );
            if (textField) {
              textField.valid = true;
            }
          });
        case 'input':
          this.#refresh();
          break;
        case 'focusin':
          this.setAttribute('focus', '');
          break;
        case 'focusout':
          this.removeAttribute('focus');
      }
    }
  }

  nodeAdded(node) {
    if (node instanceof HTMLElement) {
      if (node instanceof HTMLButtonElement ||
          node instanceof HTMLInputElement ||
          node instanceof HTMLTextAreaElement ||
          node instanceof HTMLSelectElement) {
        if (!this.control) {
          node.classList.add('embedded');

          if (node.required) {
            this.setAttribute('required', '');
          }
          if (node.disabled) {
            this.setAttribute('disabled', '');
          }
          /*if (!node.validity.valid) {
            this.setAttribute('invalid', '');
          }*/
          if (node instanceof HapticTextAreaElement) {
            if (!node.hasAttribute('rows')) {
              node.setAttribute('rows', 1);
            }
          }
          this.#mutationObserver.observe(node, { attributes: true });
          this.startListen(node, 'change');
          this.startListen(node, 'input');

          if (this.hasAttribute('focus-indicator')) {
            this.startListen(node, 'focusin');
            this.startListen(node, 'focusout');
          }
          this.control = node;
        }
      } else
      if (node instanceof HTMLLabelElement) {
        if (!this.label) {
          this.setAttribute('with-label', '');
          this.label = node;
        }
      } else {
        for (let iconName of HapticTextFieldElement.ICON_NAMES) {
          if (node.classList.contains(`${iconName}-icon`)) {
            if (iconName != 'error' || !this.valid) {
              this.setAttribute(`with-${iconName}-icon`, '');
            }
          }
        }
      }
    }
  }

  nodeRemoved(node) {
    switch (node) {
      case this.control:
        node.classList.remove('embedded');
        this.removeAttribute('disabled');
        this.removeAttribute('invalid');
        this.removeAttribute('required');
        this.setAttribute('empty', '');
        this.stopListen(node);
        this.#mutationObserver.disconnect();
        this.control = null;
        break;
      case this.label:
        this.removeAttribute('with-label');
        this.label = null;
        break;
      default:
        for (let iconName of HapticFieldElement.ICON_NAMES) {
          if (node.classList.contains(`${iconName}-icon`)) {
            if (!this.querySelector(`${iconName}-icon`)) {
              this.removeAttribute(`with-${iconName}-icon`);
            }
          }
        }
    }
  }

  startListen(target, type) {
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

  stopListen(target) {
    this.#listens.get(target)?.forEach(type => {
      target.removeEventListener(type, this);
    });
    this.#listens.delete(target);
  }

  #refresh() {
    if (this.control) {
      if (this.control.value.length == 0) {
        this.setAttribute('empty', '');
      } else {
        this.removeAttribute('empty');
      }
      if (this.control instanceof HapticTextAreaElement) {
        this.control.resize();
      }
    }
  }
}

class HapticDropdownFieldElement extends HapticFieldElement {
  constructor() {
    super();
  }
}
customElements.define('haptic-dropdown-field', HapticDropdownFieldElement);

class HapticTextFieldElement extends HapticFieldElement {
  #clearButton = null;

  constructor() {
    super();
  }

  clear() {
    if (this.control && this.control.value != '') {
      this.control.value = '';
      this.control.dispatchEvent(new Event('change'));
    }
  }

  handleEvent(event) {
    if (event.target === this.#clearButton) {
      if (event.type == 'click') {
        this.clear();
        this.control?.focus();
        event.preventDefault();
      }
    } else {
      super.handleEvent(event);
    }
  }

  nodeAdded(node) {
    if (node instanceof HTMLElement &&
        node.classList.contains('clear-button')) {
      if (!this.#clearButton) {
        this.setAttribute('with-clear-button', '');
        this.startListen(node, 'click');

        this.#clearButton = node;
      }
    } else {
      super.nodeAdded(node);
    }
  }

  nodeRemoved(node) {
    if (node === this.#clearButton) {
      this.removeAttribute('with-clear-button');
      this.stopListen(node);
      this.#clearButton = null;
    } else {
      super.nodeRemoved(node);
    }
  }
}
customElements.define('haptic-text-field', HapticTextFieldElement);

class HapticFormElement extends HTMLFormElement {
  #requiredFields = new Set();
  #submitButtons = new Set();

  constructor() {
    super();   
  }

  connectedCallback() {
    new HapticMutationObserver({
      nodeAdded: node => {
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
      },
      nodeRemoved: node => {
        if (this.#requiredFields.has(node)) {
          node.removeEventListener('change', this);
          node.removeEventListener('input', this);
          this.#requiredFields.delete(node);
        } else
        if (this.#submitButtons.has(node)) {
          this.#submitButtons.delete(node);
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }

  handleEvent(event) {
    this.#refresh();
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

  #mutationObserver = new MutationObserver((mutationList) => {
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

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-list-item');

    new HapticMutationObserver({
      nodeAdded: node => {
        if (node instanceof HTMLInputElement && node.type == 'checkbox' && !this.#checkbox) {
          node.classList.add('embedded');
          this.#mutationObserver.observe(node, { attributes: true });
          this.#checkbox = node;
        }
      },
      nodeRemoved: node => {
        if (node === this.#checkbox) {
          node.classList.remove('embedded');
          this.#mutationObserver.disconnect();
          this.#checkbox = null;
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }
}
customElements.define('haptic-list-item', HapticListItemElement, { extends: 'li' });

class HapticSegmentedButtonElement extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    new HapticMutationObserver({
      nodeAdded: node => {
        if (node instanceof HTMLInputElement &&
            node.classList.contains('outlined')) {
          this.classList.add('outlined');
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }
}
customElements.define('haptic-segmented-button', HapticSegmentedButtonElement);

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
