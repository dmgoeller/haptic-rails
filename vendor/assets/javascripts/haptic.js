
class HapticEventListeners {
  #listeners = new Map();

  add(eventTarget, type, listener) {
    let listenersForEventTarget = this.#listeners.get(eventTarget);
    if (typeof listenersForEventTarget === 'undefined') {
      listenersForEventTarget = new Map();
      this.#listeners.set(eventTarget, listenersForEventTarget);
    }
    let listeners = listenersForEventTarget.get(type);
    if (typeof listeners === 'undefined') {
      listeners = new Set();
      listenersForEventTarget.set(type, listeners);
    }
    listeners.add(listener);
    eventTarget.addEventListener(type, listener);
  }

  remove(eventTarget) {
    this.#listeners.get(eventTarget)?.forEach((listeners, type) => {
      for (let listener of listeners) {
        eventTarget.removeEventListener(type, listener);
      }
    });
    this.#listeners.delete(eventTarget);
  }

  removeAll() {
    this.#listeners.forEach((listenersForEventTarget, eventTarget) => {
      listenersForEventTarget.forEach((listeners, type) => {
        for (let listener of listeners) {
          eventTarget.removeEventListener(type, listener);
        }
      });
    });
    this.#listeners.clear();
  }
}

class HapticChildNodesObserver extends MutationObserver {
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

  observe(node) {
    super.observe(node, { childList: true, subtree: true });
  }
}

class HapticControlObserver extends MutationObserver {
  constructor(owner) {
    super(mutationList => {
      for (let mutationRecord of mutationList) {
        for (let name of ['disabled', 'required']) {
          if (mutationRecord.attributeName == name) {
            if (mutationRecord.target.hasAttribute(name)) {
              owner.setAttribute(name, '');
            } else {
              owner.removeAttribute(name);
            }
          }
        }
      }
    });
  }

  observe(node) {
    super.observe(node, { attributes: true });
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
  #toggleElement = null;
  #popoverElement = null;
  #backdropElement = null;
  #previousToggleTabIndex = null;
  #eventListeners = new HapticEventListeners();

  constructor() {
    super();
  }

  get toggleElement() {
    return this.#toggleElement;
  }

  get popoverElement() {
    return this.#popoverElement;
  }

  connectedCallback() {
    if (this.tabIndex === -1) {
      this.tabIndex = 0;
    }
    this.#eventListeners.add(this, 'focusout', event => {
      const relatedTarget = event.relatedTarget;

      if (relatedTarget && !this.contains(relatedTarget)) {
        this.hidePopover({ reset: true });
      }
    });
    this.#eventListeners.add(this, 'keyup', event => {
      if (event.key === 'Escape') {
        this.hidePopover({ reset: true });
        event.preventDefault();
      }
    });
    new HapticChildNodesObserver({
      nodeAdded: node => {
        this.nodeAdded(node);
      },
      nodeRemoved: node => {
        this.nodeRemoved(node);
      }
    }).observe(this);
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
  }

  nodeAdded(node) {
    if (node instanceof HTMLElement) {
      const classList = node.classList;

      if (classList.contains('toggle')) {
        if (!this.#toggleElement) {
          this.#previousToggleTabIndex = node.tabIndex;
          node.tabIndex = -1;

          this.#eventListeners.add(node, 'click', event => {
            if (this.isOpen()) {
              this.hidePopover({ reset: true });
            } else {
              this.showPopover();
            }
            event.preventDefault();
          });
          this.#toggleElement = node;
        }
      } else
      if (classList.contains('popover')) {
        if (!this.#popoverElement) {
          this.#popoverElement = node;
        }
      } else
      if (classList.contains('backdrop')) {
        if (!this.#backdropElement) {
          this.#eventListeners.add(node, 'click', event => {
            this.hidePopover({ reset: true });
            event.preventDefault();
          });
          this.#backdropElement = node;
        }
      }
    }   
  }

  nodeRemoved(node) {
    switch (node) {
      case this.#toggleElement:
        node.tabIndex = this.#previousToggleTabIndex;
        this.#eventListeners.remove(node);
        this.#toggleElement = null;
        break;
      case this.#popoverElement:
        this.#popoverElement = null;
        break;
      case this.#backdropElement:
        this.#eventListeners.remove(node);
        this.#backdropElement = null;
    }
  }

  isOpen() {
    return this.hasAttribute('popover-open');
  }

  showPopover() {
    if (this.popoverElement) {
      if (this.getBoundingClientRect().x > (window.innerWidth / 2)) {
        this.#popoverElement.classList.add('auto-justify-right');
      } else {
        this.#popoverElement.classList.remove('auto-justify-right');
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
}

class HapticDialogDropdownElement extends HapticDropdownElement {
  #fields = new Set();
  #resetButtons = new Set();
  #eventListeners = new HapticEventListeners();

  constructor() {
    super();
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
    super.disconnectedCallback();
  }

  nodeAdded(node) {
    super.nodeAdded(node);  

    if (node instanceof HTMLElement) {
      if ('resetValue' in node) {
        this.#fields.add(node);
      } else
      if (node.type === 'reset') {
        this.#eventListeners.add(node, 'click', event => {
          this.hidePopover({ reset: true });
          event.preventDefault();
        });
        this.#resetButtons.add(node);
      }
    } 
  }

  nodeRemoved(node) {
    if (this.#fields.has(node)) {
      this.#fields.remove(node);
    } else
    if (this.#resetButtons.has(node)) {
      this.#eventListeners.remove(node);
      this.#resetButtons.remove(node);
    }
    super.nodeRemoved(node);
  }

  reset() {
    for (let field of this.#fields) {
      field.resetValue();
    }
  }
}
customElements.define('haptic-dialog-dropdown', HapticDialogDropdownElement);

class HapticSelectDropdownElement extends HapticDropdownElement {
  static observedAttributes = ['size'];

  #size = null;
  #inputElement = null;
  #inputElementObserver = new HapticControlObserver(this);
  #optionElements = [];
  #eventListeners = new HapticEventListeners();

  constructor() {
    super();
  }

  get form() {
    return this.closest('form');
  }

  get disabled() {
    return this.hasAttribute('disabled');
  }

  get required() {
    return this.hasAttribute('required');
  }

  get value() {
    return this.#inputElement?.value;
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
    this.#scrollTo(index);
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

  get #scrollOffset() {
    if (this.popoverElement) {
      return Math.floor(this.popoverElement.scrollTop / 24);
    } else {
      return null;
    }
  }

  set #scrollOffset(index) {
    this.popoverElement.scrollTop = 24 * index + 1;
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'size') {
      this.#size = parseInt(newValue);
    }
  }

  connectedCallback() {
    this.#eventListeners.add(this, 'keydown', event => {
      if (this.#optionElements.length > 0) {
        switch (event.key) {
          case 'ArrowDown':
            if (this.isOpen()) {
              const index = this.#highlightedIndex;

              if (index === -1 && this.#size) {
                this.#highlightedIndex = this.#scrollOffset;
              } else
              if (index < this.#optionElements.length - 1) {
                this.#highlightedIndex = index + 1;
              }
            } else {
              this.showPopover();

              if (this.#size) {
                this.#highlightedIndex = this.#scrollOffset;
              } else {
                this.#highlightedIndex = 0;
              }
            }
            event.preventDefault();
            break;
          case 'ArrowUp':
            if (this.isOpen()) {
              const index = this.#highlightedIndex;

              if (index === -1 && this.#size) {
                this.#highlightedIndex = Math.min(
                  this.#scrollOffset + this.#size,
                  this.#optionElements.length
                ) - 1;
              } else
              if (index > 0) {
                this.#highlightedIndex = index - 1;
              }
            } else {
              this.showPopover();

              if (this.#size) {
                this.#highlightedIndex = this.#scrollOffset + this.#size - 1;
              } else {
                this.#highlightedIndex = this.#optionElements.length - 1;
              }
            }
            event.preventDefault();
            break;
          case 'End':
            if (this.isOpen()) {
              this.#highlightedIndex = this.#optionElements.length - 1;
              event.preventDefault();
            }
            break;
          case 'Home':
            if (this.isOpen()) {
              this.#highlightedIndex = 0;
              event.preventDefault();
            }
            break;
        }
      }
    });
    this.#eventListeners.add(this, 'keyup', event => {
      if (this.#optionElements.length > 0) {
        switch (event.key) {
          case ' ':
          case 'Enter':
            if (this.isOpen()) {
              const option = this.#highlightedOption;
              if (option) {
                this.#setValue(option.value, true);
              }
              this.focus();
              this.hidePopover();
              event.preventDefault();
            } else {
              this.showPopover();
              event.preventDefault();
              break;
            }
            break;
          default:
            if (event.key.length === 1) {
              const lowerCaseKey = event.key.toLowerCase();

              for (let i = 0; i < this.#optionElements.length; i++) {
                const text = this.#optionElements[i].innerText;

                if (text.length > 0 && text[0].toLowerCase() === lowerCaseKey) {
                  this.#highlightedIndex = i;
                  break;
                }
              }
            }
        }
      }
    });
    super.connectedCallback();
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
    super.disconnectedCallback();
  }

  nodeAdded(node) {
    super.nodeAdded(node);

    if (node instanceof HTMLElement) {
      if (node instanceof HTMLInputElement) {
        if (!this.#inputElement) {
          node.classList.add('embedded');

          if (node.required) {
            this.setAttribute('required', '');
          }
          if (node.disabled) {
            this.setAttribute('disabled', '');
          }
          this.#inputElementObserver.observe(node);
          this.#inputElement = node;
        }
      } else
      if (node instanceof HapticOptionElement) {
        this.#eventListeners.add(node, 'click', event => {
          this.#setValue(event.target.value, true)
          this.focus();
          this.hidePopover();
        });
        this.#eventListeners.add(node, 'mouseover', event => {
          this.#highlightedOption = event.target;
        });
        this.#eventListeners.add(node, 'mouseout', event => {
          event.target.selected = false;
        });
        this.#optionElements.push(node);

        if (node.checked) {
          this.#setValue(node.value);
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
    if (node === this.#inputElement) {
      this.#inputElement = null;
      this.#inputElementObserver.disconnect();
    } else
    if (node instanceof HapticOptionElement) {
      this.#eventListeners.remove(node);

      const index = this.#optionElements.indexOf(node);
      if (index >= 0 && index < this.#optionElements.length) {
        this.#optionElements.splice(index, 1);
      }
    }
    super.nodeRemoved(node);
  }

  showPopover() {
    if (this.#optionElements.length > 0) {
      if (this.popoverElement && this.#size) {
        this.popoverElement.style.maxHeight = `calc(${24 * this.#size}px + 0.5rem)`
      }
      super.showPopover();

      for (let i = 0; i < this.#optionElements.length; i++) {
        if (this.#optionElements[i].checked) {
          this.#scrollTo(i);
          break;
        }
      }
    }
  }

  reset() {
    this.#highlightedOption = null;
  }

  #setValue(value, dispatchChangeEvent = false) {
    for (let option of this.#optionElements) {
      if (option.value === value) {
        option.checked = true

        if (this.toggleElement) {
          this.toggleElement.innerHTML = option.innerHTML;
        }
        if (this.#inputElement) {
          if (this.#inputElement.value !== value) {
            this.#inputElement.value = value;

            if (dispatchChangeEvent === true) {
              this.dispatchEvent(new Event('change'));
            }
          }
        }
      } else {
        option.checked = false;
      }
    }
  }

  #scrollTo(index) {
    if (this.#size && this.popoverElement) {
      const offset = this.#scrollOffset;

      if (index < offset) {
        this.#scrollOffset = index;
      } else
      if (index > offset + this.#size - 1) {
        this.#scrollOffset = index - this.#size + 1;
      }
    }
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

  #setValidOnChange = null;
  #control = null;
  #controlObserver = new HapticControlObserver(this);
  #label = null;
  #eventListeners = new HapticEventListeners();

  constructor() {
    super();
  }

  get control() {
    return this.#control;
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
    new HapticChildNodesObserver({
      nodeAdded: node => {
        this.nodeAdded(node);
        this.#refresh();
      },
      nodeRemoved: node => {
        this.nodeRemoved(node);
        this.#refresh();
      }
    }).observe(this);
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
  }

  nodeAdded(node) {
    if (node instanceof HTMLElement && this.#isParentFieldOf(node)) {
      if (node instanceof HapticSelectDropdownElement ||
          node instanceof HTMLInputElement ||
          node instanceof HTMLButtonElement ||
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
          /*if (!node.validity.valid) {
            this.setAttribute('invalid', '');
          }*/
          if (node instanceof HapticTextAreaElement) {
            if (!node.hasAttribute('rows')) {
              node.setAttribute('rows', 1);
            }
          }
          this.#controlObserver.observe(node);

          this.#eventListeners.add(node, 'change', () => {
            this.#setValidOnChange?.forEach(fieldId => {
              const field = fieldId == 'itself' ? this :
                this.#control?.form?.querySelector(`[for="${fieldId}"]`);

              if (field && 'valid' in field) {
                field.valid = true;
              }
            });
            this.#refresh();
          });
          this.#eventListeners.add(node, 'input', () => {
            this.#refresh();
          });
          this.#control = node;
        }
      } else
      if (node.classList.contains('haptic-field-label')) {
        if (!this.#label) {
          this.setAttribute('with-label', '');
          this.#label = node;
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
        case this.#control:
          node.classList.remove('embedded');
          this.removeAttribute('disabled');
          this.removeAttribute('invalid');
          this.removeAttribute('required');
          this.setAttribute('empty', '');
          this.#eventListeners.remove(node);
          this.#controlObserver.disconnect();
          this.#control = null;
          break;
        case this.#label:
          this.removeAttribute('with-label');
          this.#label = null;
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
    if (this.#control) {
      const value = this.#control.value;

      if (value == null || value.length == 0) {
        this.setAttribute('empty', '');
      } else {
        this.removeAttribute('empty');
      }
      if (this.#control instanceof HapticTextAreaElement) {
        this.#control.resize();
      }
    }
  }

  #isParentFieldOf(node) {
    for (let n = node; n; n = n.parentElement) {
      if (n instanceof HapticFieldElement) {
        return n === this;
      }
    }
    return false;
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
  #eventListeners = new HapticEventListeners();

  constructor() {
    super();
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
    super.disconnectedCallback();
  }

  nodeAdded(node) {
    if (node instanceof HTMLElement && node.classList.contains('clear-button')) {
      if (!this.#clearButton) {
        this.setAttribute('with-clear-button', '');
        this.#eventListeners.add(node, 'click', event => {
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
      this.#eventListeners.remove(node);
      this.#clearButton = null;
    } else {
      super.nodeRemoved(node);
    }
  }

  clear() {
    if (this.control && this.control.value != '') {
      this.control.value = '';
      this.control.dispatchEvent(new Event('change'));
    }
  }
}
customElements.define('haptic-text-field', HapticTextFieldElement);

class HapticFormElement extends HTMLFormElement {
  #requiredFields = new Set();
  #submitButtons = new Set();
  #eventListeners = new HapticEventListeners();

  constructor() {
    super();   
  }

  connectedCallback() {
    new HapticChildNodesObserver({
      nodeAdded: node => {
        if ((node instanceof HTMLButtonElement ||
             node instanceof HTMLInputElement) &&
            node.type === 'submit') {
          this.#submitButtons.add(node);
          this.#refresh();
        } else
        if ((node instanceof HTMLInputElement ||
             node instanceof HTMLTextAreaElement ||
             node instanceof HTMLSelectElement ||
             node instanceof HapticListElement) &&
            node.required) {
          this.#eventListeners.add(node, 'change', this);
          this.#eventListeners.add(node, 'input', this);
          this.#requiredFields.add(node);
          this.#refresh();
        }
      },
      nodeRemoved: node => {
        if (this.#requiredFields.has(node)) {
          this.#eventListeners.remove(node)
          this.#requiredFields.delete(node);
        } else
        if (this.#submitButtons.has(node)) {
          this.#submitButtons.delete(node);
        }
      }
    }).observe(this);
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
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
      for (let submitButton of this.#submitButtons) {
          submitButton.disabled = !submittable;
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

  resetValue() {
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
  #eventListeners = new HapticEventListeners();

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
    new HapticChildNodesObserver({
      nodeAdded: node => {
        if (node instanceof HapticListItemElement) {
          this.#eventListeners.add(node, 'change', () => {
            this.dispatchEvent(new Event('change'));
          });
          this.#listItemElements.add(node);
        }
      },
      nodeRemoved: node => {
        if (this.#listItemElements.has(node)) {
          this.#eventListeners.remove(node);
          this.#listItemElements.remove(node);
        }
      }
    }).observe(this);
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
  }
}
customElements.define('haptic-list', HapticListElement);

class HapticListItemElement extends HTMLElement {
  #inputElement = null;
  #inputElementObserver = new HapticControlObserver(this);

  constructor() {
    super();
  }

  connectedCallback() {
    new HapticChildNodesObserver({
      nodeAdded: node => {
        if (node instanceof HTMLInputElement && !this.#inputElement) {
          node.classList.add('embedded');
          this.#inputElementObserver.observe(node);
          this.#inputElement = node;
        }
      },
      nodeRemoved: node => {
        if (node === this.#inputElement) {
          node.classList.remove('embedded');
          this.#inputElementObserver.disconnect();
          this.#inputElement = null;
        }
      }
    }).observe(this);
  }
}
customElements.define('haptic-list-item', HapticListItemElement);

class HapticSegmentedButtonElement extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    new HapticChildNodesObserver({
      nodeAdded: node => {
        if (node instanceof HTMLInputElement &&
            node.classList.contains('outlined')) {
          this.classList.add('outlined');
        }
      }
    }).observe(this);
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

  resetValue() {
    if (this.value != this.#initialValue) {
      this.value = this.#initialValue;
      this.dispatchEvent(new Event('change'));
    }
  }
}
customElements.define('haptic-select', HapticSelectElement, { extends: 'select' });

class HapticTextAreaElement extends HTMLTextAreaElement {
  #initialValue = null;
  #eventListeners = new HapticEventListeners();

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-field');
    this.#initialValue = this.value;

    this.#eventListeners.add(this, 'input', () => {
      this.resize();
    });
    this.#eventListeners.add(window, 'resize', () => {
      this.resize();
    });
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
  }

  resetValue() {
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
