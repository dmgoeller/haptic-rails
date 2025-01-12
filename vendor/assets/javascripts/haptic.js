
class HapticEventListeners {
  #listeners = new Map();

  add(target, type, listener) {
    let listenersForTarget = this.#listeners.get(target);
    if (typeof listenersForTarget === 'undefined') {
      listenersForTarget = new Map();
      this.#listeners.set(target, listenersForTarget);
    }
    let listeners = listenersForTarget.get(type);
    if (typeof listeners === 'undefined') {
      listeners = new Set();
      listenersForTarget.set(type, listeners);
    }
    listeners.add(listener);
    target.addEventListener(type, listener);
  }

  removeAll(target) {
    this.#listeners.get(target)?.forEach((listeners, type) => {
      for (let listener of listeners) {
        target.removeEventListener(type, listener);
      }
    });
    this.#listeners.delete(target);
  }
}

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
    return document.querySelector(
      'haptic-dialog-dropdown[popover-open],haptic-select-dropdown[popover-open]'
    );
  }

  toggleElement = null;
  popoverElement = null;
  backdropElement = null;

  constructor() {
    super();
  }

  isOpen() {
    return this.hasAttribute('popover-open');
  }

  showPopover() {
    if (this.popoverElement) {
      if (this.getBoundingClientRect().x > (window.innerWidth / 2)) {
        this.popoverElement.classList.add('auto-justify-right');
      } else {
        this.popoverElement.classList.remove('auto-justify-right');
      }
      this.setAttribute('popover-open', '');
    }
  }

  hidePopover(options = {}) {
    if (this.hasAttribute('popover-open')) {
      this.removeAttribute('popover-open');

      if (options.reset) {
        this.reset();
      }
    }
  }

  reset() {
  }

  connectedCallback() {
    this.addEventListener('keyup', this);

    new HapticMutationObserver({
      nodeAdded: node => {
        this.nodeAdded(node);
      },
      nodeRemoved: node => {
        this.nodeRemoved(node);
      }
    }).observe(this, { childList: true, subtree: true });
  }

  handleEvent(event) {
    switch (event.type) {
      case 'click':
        const openDropdown = HapticDropdownElement.openDropdown;
        if (openDropdown !== this) {
          openDropdown?.hidePopover({ reset: true });
          this.showPopover();
        } else {
          this.hidePopover({ reset: true });
        }
        event.preventDefault();
        break;
      case 'keyup':
        if (event.key === 'Escape') {
          this.hidePopover({ reset: true });
        }
    }
  }

  nodeAdded(node) {
    if (node instanceof HTMLElement) {
      const classList = node.classList;

      if (classList.contains('toggle')) {
        if (!this.toggleElement) {
          node.addEventListener('click', this);
          node.addEventListener('focusout', this);
          this.toggleElement = node;
        }
      } else
      if (classList.contains('popover')) {
        if (!this.popoverElement) {
          this.popoverElement = node;
        }
      } else
      if (classList.contains('backdrop')) {
        if (!this.backdropElement) {
          node.addEventListener('click', this);
          this.backdropElement = node;
        }
      }
    }   
  }

  nodeRemoved(node) {
    switch (node) {
      case this.toggleElement:
        node.removeEventListener('click', this);
        node.removeEventListener('focusout', this);
        this.toggleElement = null;
        break;
      case this.popoverElement:
        this.popoverElement = null;
        break;
      case this.backdropElement:
        node.removeEventListener('click', this);
        this.backdropElement = null;
    }
  }
}

class HapticDialogDropdownElement extends HapticDropdownElement {
  #fields = new Set();
  #resetButtons = new Set();

  constructor() {
    super();
  }

  reset() {
    for (let field of this.#fields) {
      field.reset();
    }
  }

  nodeAdded(node) {
    if (node instanceof HTMLElement) {
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
    super.nodeAdded(node);  
  }

  nodeRemoved(node) {
    if (this.#fields.has(node)) {
      this.#fields.remove(node);
    } else
    if (this.#resetButtons.has(node)) {
      node.removeEventListener('click', this);
      this.#resetButtons.remove(node);
    }
    super.nodeRemoved(node);
  }
}
customElements.define('haptic-dialog-dropdown', HapticDialogDropdownElement);

class HapticSelectDropdownElement extends HapticDropdownElement {
  #inputElement = null;
  #optionElements = [];

  constructor() {
    super();
  }

  get size() {
    if (this.hasAttribute('size')) {
      return parseInt(this.getAttribute('size'));
    } else {
      return null;
    }
  }

  get value() {
    return this.#inputElement?.value;
  }

  #setValue(value, dispatchChangeEvent = false) {
    for (let option of this.#optionElements) {
      if (option.value === value) {
        option.checked = true

        if (this.toggleElement) {
          this.toggleElement.innerHTML = option.innerHTML;
        }
        if (this.#inputElement) {
          const oldValue = this.#inputElement.value;
          this.#inputElement.value = value;

          if (value !== oldValue && dispatchChangeEvent === true) {
            this.#inputElement.dispatchEvent(new Event('change'));
            this.toggleElement?.dispatchEvent(new Event('change'));
          }
        }
      } else {
        option.checked = false;
      }
    }
  }

  get #highlightedIndex() {
    for (let i = 0; i < this.#optionElements.length; i++) {
      if (this.#optionElements[i].highlighted) {
        return i;
      }
    }
    return -1;
  }

  set #highlightedIndex(index) {
    for (let i = 0; i < this.#optionElements.length; i++) {
      this.#optionElements[i].highlighted = (i == index);
    }
  }

  get #highlightedOption() {
    for (let option of this.#optionElements) {
      if (option.highlighted) {
        return option;
      }
    }
    return null;
  }

  set #highlightedOption(option) {
    for (let opt of this.#optionElements) {
      opt.highlighted = (opt === option);
    }
  }

  connectedCallback() {
    this.addEventListener('keydown', event => {
      switch (event.key) {
        case 'ArrowDown':
        case 'ArrowUp':
          // Prevent page scrolling
          event.preventDefault();
      }
    });
    this.addEventListener('keyup', event => {
      if (this.isOpen()) {
        let index;

        switch (event.key) {
          case 'ArrowDown':
            index = this.#highlightedIndex;
            if (index < this.#optionElements.length - 1) {
              this.#highlightedIndex = index + 1;
            }
            event.preventDefault();
            break;
          case 'ArrowUp':
            index = this.#highlightedIndex;
            if (index > 0) {
              this.#highlightedIndex = index - 1;
            }
            event.preventDefault();
            break;
          case ' ':
            const option = this.#highlightedOption;
            if (option) {
              this.#setValue(option.value, true);
            }
            this.toggleElement?.focus();
            this.hidePopover();
            event.preventDefault();
        }
      } else {
        switch (event.key) {
          case 'ArrowDown':
          case 'ArrowUp':
            if (this.#optionElements.length > 0) {
              this.#highlightedIndex = 0;
            }
          case ' ':
            HapticDropdownElement.openDropdown?.hidePopover({ reset: true });
            this.showPopover();
            event.preventDefault();
        }
      }
    });
    super.connectedCallback();
  }

  nodeAdded(node) {
    super.nodeAdded(node);

    if (node instanceof HTMLElement) {
      if (node instanceof HTMLInputElement) {
        if (!this.#inputElement) {
          this.#inputElement = node;
        }
      } else
      if (node instanceof HapticOptionElement) {
        node.addEventListener('click', event => {
          this.#setValue(event.target.value, true)
          this.toggleElement?.focus();
          this.hidePopover();
        });
        node.addEventListener('mouseover', event => {
          this.#highlightedOption = event.target;
        });
        node.addEventListener('mouseout', event => {
          event.target.selected = false;
        });
        this.#optionElements.push(node);

        if (node.checked) {
          this.#setValue(node.value);
        }
      } else
      if (node.classList.contains('popover')) {
        const size = this.size;
        if (size) {
          node.style.maxHeight = `${1.5 * size + 0.5}rem`
        }
      } else
      if (node.classList.contains('backdrop')) {
        if (this.#optionElements.length > 0) {
          let hasCheckedOption = false;

          for (let option of this.#optionElements) {
            if (option.checked) {
              hasCheckedOption = true;
              break;
            }
          }
          if (!hasCheckedOption) {
            this.#setValue(this.#optionElements[0].value);
          }
        }
      }
    }
  }

  nodeRemoved(node) {
    switch (node) {
      case this.#inputElement:
        this.#inputElement = null;
        break;
      default:
        const index = this.#optionElements.indexOf(node);
        if (index >= 0) {
          this.#optionElements.splice(index, 1);
        }
    }
    super.nodeRemoved(node);
  }

  reset() {
    this.#highlightedOption = null;
  }
}
customElements.define('haptic-select-dropdown', HapticSelectDropdownElement);

class HapticOptionElement extends HTMLElement {
  constructor() {
    super();
  }

  get checked() {
    return this.hasAttribute('checked');
  }

  set checked(value) {
    if (value == true) {
      this.setAttribute('checked', '');
    } else {
      this.removeAttribute('checked');
    }
  }

  get highlighted() {
    return this.hasAttribute('highlighted');
  }

  set highlighted(value) {
    if (value == true) {
      this.setAttribute('highlighted', '');
    } else {
      this.removeAttribute('highlighted');
    }
  }

  get value() {
    return this.getAttribute('value');
  }

  set value(value) {
    if (value) {
      this.setAttribute('value', value);
    } else {
      this.removeAttribute('value');
    }
  }
}
customElements.define('haptic-option', HapticOptionElement);

class HapticFieldElement extends HTMLElement {
  static ICON_NAMES = ['error', 'leading', 'trailing'];

  control = null;
  label = null; // TODO: private?

  #listeners = new HapticEventListeners();
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
          if (this.hasAttribute('reset-and-close-dropdown-on-focus')) {
            HapticDropdownElement.openDropdown?.hidePopover({ reset: true });
          }
      }
    }
  }

  nodeAdded(node) {
    if (node instanceof HTMLElement &&
        node.closest('haptic-dropdown-field, haptic-text-field') === this) {
      if ((node instanceof HTMLInputElement && node.type !== 'hidden') ||
          node instanceof HTMLButtonElement ||
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
          this.#listeners.add(node, 'change', this);
          this.#listeners.add(node, 'input', this);
          this.#listeners.add(node, 'focusin', this);
          this.control = node;
        }
      } else
      if (node.classList.contains('haptic-field-label')) {
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
    if (node instanceof HTMLElement) {
      switch (node) {
        case this.control:
          node.classList.remove('embedded');
          this.removeAttribute('disabled');
          this.removeAttribute('invalid');
          this.removeAttribute('required');
          this.setAttribute('empty', '');
          this.#listeners.removeAll(node);
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
  #listeners = new HapticEventListeners();
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

  nodeAdded(node) {
    if (node instanceof HTMLElement &&
        node.classList.contains('clear-button')) {
      if (!this.#clearButton) {
        this.setAttribute('with-clear-button', '');
        this.#listeners.add(node, 'click', event => {
          this.clear();
          this.control?.focus();
          event.preventDefault();
        });
        this.#clearButton = node;
      }
    } else {
      super.nodeAdded(node);
    }
  }

  nodeRemoved(node) {
    if (node === this.#clearButton) {
      this.removeAttribute('with-clear-button');
      this.#listeners.removeAll(node);
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
        if (node instanceof HTMLButtonElement) {
          if (node.type == 'submit') {
            this.#submitButtons.add(node);
            this.#refresh();
          }
        } else
        if (node instanceof HTMLInputElement) {
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
        } else
        if (node instanceof HTMLTextAreaElement ||
            node instanceof HTMLSelectElement ||
            node instanceof HapticListElement) {
          if (node.hasAttribute('required')) {
            node.addEventListener('change', this);
            node.addEventListener('input', this);
            this.#requiredFields.add(node);
            this.#refresh();
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
    if (!this.classList.contains('haptic-field-label')) {
      this.classList.add('haptic-label');
    }
  }
}
customElements.define('haptic-label', HapticLabelElement, { extends: 'label' });

class HapticListElement extends HTMLElement {
  #listItemElements = new Set();

  constructor() {
    super();
  }

  get required() {
    this.hasAttribute('required');
  }

  get value() {
    for (let listItemElement of this.#listItemElements) {
      if (listItemElement.inputElement?.checked) {
        return listItemElement.inputElement.value;
      }
    }
    return null;
  }

  connectedCallback() {
    new HapticMutationObserver({
      nodeAdded: node => {
        if (node instanceof HapticListItemElement) {
          node.addEventListener('change', this);
          this.#listItemElements.add(node);
        }
      },
      nodeRemoved: node => {
        if (this.#listItemElements.has(node)) {
          node.removeEventListener('change', this);
          this.#listItemElements.remove(node);
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }

  handleEvent(event) {
    this.dispatchEvent(new Event('change'));
  }
}
customElements.define('haptic-list', HapticListElement);

class HapticListItemElement extends HTMLElement {
  inputElement = null;

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
    new HapticMutationObserver({
      nodeAdded: node => {
        if (node instanceof HTMLInputElement && !this.inputElement) {
          node.classList.add('embedded');
          this.#mutationObserver.observe(node, { attributes: true });
          this.inputElement = node;
        }
      },
      nodeRemoved: node => {
        if (node === this.inputElement) {
          node.classList.remove('embedded');
          this.#mutationObserver.disconnect();
          this.inputElement = null;
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }
}
customElements.define('haptic-list-item', HapticListItemElement);

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
