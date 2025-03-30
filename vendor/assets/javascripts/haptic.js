
class HapticEventListeners {
  #listeners = new Map();

  add(eventTarget, type, listener, options = {}) {
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
    listeners.add({ listener: listener, options: options });
    eventTarget.addEventListener(type, listener, options);
  }

  remove(eventTarget) {
    this.#listeners.get(eventTarget)?.forEach((listeners, type) => {
      for (let l of listeners) {
        eventTarget.removeEventListener(type, l.listener, l.options);
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
}

class HapticButtonElement extends HTMLButtonElement {
  constructor() {
    super();
  }

  connectedCallback() {
    if (!this.classList.contains('haptic-icon-button')) {
      this.classList.add('haptic-button');
    }
  }
}
customElements.define('haptic-button', HapticButtonElement, { extends: 'button' });

class HapticDropdownElement extends HTMLElement {
  static observedAttributes = ['disabled'];

  #toggleElement = null;
  #toggleElementTabIndex = null;
  #popoverElement = null;
  #backdropElement = null;
  #eventListeners = new HapticEventListeners();

  constructor() {
    super();
  }

  get disabled() {
    return this.hasAttribute('disabled');
  }

  set disabled(value) {
    if (value) {
      this.setAttribute('disabled', 'disabled');
    } else {
      this.removeAttribute('disabled');
    }
    return value;
  }

  get toggleElement() {
    return this.#toggleElement;
  }

  get popoverElement() {
    return this.#popoverElement;
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'disabled') {
      this.tabIndex = (newValue === null ? 0 : -1);
    }
  }

  connectedCallback() {
    if (!this.disabled) {
      this.tabIndex = 0;
    }
    this.#eventListeners.add(this, 'focusout', event => {
      const relatedTarget = event.relatedTarget;

      if (relatedTarget && !this.contains(relatedTarget)) {
        this.hidePopover({ cancel: true });
      }
    });
    this.#eventListeners.add(this, 'keyup', event => {
      if (event.key === 'Escape') {
        this.hidePopover({ cancel: true });
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
    }).observe(this, { childList: true, subtree: true });
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
  }

  nodeAdded(node) {
    if (node instanceof HTMLElement) {
      const classList = node.classList;

      if (classList.contains('toggle')) {
        if (!this.#toggleElement) {
          this.#toggleElementTabIndex = node.tabIndex;
          node.tabIndex = -1;

          this.#eventListeners.add(node, 'click', event => {
            if (this.isOpen()) {
              this.hidePopover({ cancel: true });
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
            this.hidePopover({ cancel: true });
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
        node.tabIndex = this.#toggleElementTabIndex;
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

      if (options.cancel) {
        this.cancel();
      }
    }
  }

  cancel() {
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
      if ('reset' in node) {
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

  cancel() {
    for (let field of this.#fields) {
      field.reset();
    }
  }
}
customElements.define('haptic-dialog-dropdown', HapticDialogDropdownElement);

class HapticSelectDropdownElement extends HapticDropdownElement {
  #inputElement = null;
  #inputElementObserver = new HapticControlObserver(this);
  #optionListElement = null;
  #eventListeners = new HapticEventListeners();

  constructor() {
    super();
  }

  get form() {
    return this.closest('form');
  }

  get required() {
    return this.hasAttribute('required');
  }

  get value() {
    return this.#inputElement?.value;
  }

  connectedCallback() {
    this.#eventListeners.add(this, 'keydown', event => {
      if (!this.disabled) {
        if (this.#optionListElement.optionElements.length > 0) {
          switch (event.key) {
            case ' ':
            case 'Enter':
              if (this.isOpen()) {
                event.preventDefault();
              }
              break;
            case 'ArrowDown':
              if (this.isOpen()) {
                const index = this.#optionListElement.highlightedIndex;

                if (index === -1 && this.#optionListElement.size) {
                  this.#optionListElement.highlightedIndex =
                    this.#optionListElement.scrollOffset;
                } else
                if (index < this.#optionListElement.optionElements.length - 1) {
                  this.#optionListElement.highlightedIndex = index + 1;
                }
              } else {
                this.showPopover();

                if (this.#optionListElement.size) {
                  this.#optionListElement.highlightedIndex =
                    this.#optionListElement.scrollOffset;
                } else {
                  this.#optionListElement.highlightedIndex = 0;
                }
              }
              event.preventDefault();
              break;
            case 'ArrowUp':
              if (this.isOpen()) {
                const index = this.#optionListElement.highlightedIndex;

                if (index === -1 && this.#optionListElement.size) {
                  this.#optionListElement.highlightedIndex = Math.min(
                    this.#optionListElement.scrollOffset + this.#optionListElement.size,
                    this.#optionListElement.optionElements.length
                  ) - 1;
                } else
                if (index > 0) {
                  this.#optionListElement.highlightedIndex = index - 1;
                }
              } else {
                this.showPopover();

                if (this.#optionListElement.size) {
                  this.#optionListElement.highlightedIndex =
                    this.#optionListElement.scrollOffset + this.#optionListElement.size - 1;
                } else {
                  this.#optionListElement.highlightedIndex =
                    this.#optionListElement.optionElements.length - 1;
                }
              }
              event.preventDefault();
              break;
            case 'End':
              if (this.isOpen()) {
                this.#optionListElement.highlightedIndex =
                  this.#optionListElement.optionElements.length - 1;
                event.preventDefault();
              }
              break;
            case 'Home':
              if (this.isOpen()) {
                this.#optionListElement.highlightedIndex = 0;
                event.preventDefault();
              }
              break;
          }
        }
      }
    });
    this.#eventListeners.add(this, 'keyup', event => {
      if (!this.disabled) {
        const optionElements = this.#optionListElement?.optionElements;

        if (optionElements && optionElements.length > 0) {
          switch (event.key) {
            case ' ':
            case 'Enter':
              if (this.isOpen()) {
                for (let optionElement of optionElements) {
                  optionElement.checked = optionElement.highlighted;
                }
                if (this.#refresh()) {
                  this.dispatchEvent(new Event('change'));
                }
                this.focus();
                this.hidePopover();
              } else {
                this.showPopover();
              }
              event.preventDefault();
              break;
            default:
              if (event.key.length === 1) {
                const lowerCaseKey = event.key.toLowerCase();

                for (let i = 0; i < optionElements.length; i++) {
                  const text = optionElements[i].innerText;

                  if (text.length > 0 && text[0].toLowerCase() === lowerCaseKey) {
                    this.#optionListElement.highlightedIndex = i;
                    break;
                  }
                }
              }
          }
        }
      }
    });
    this.#eventListeners.add(document, 'DOMContentLoaded', () => {
      const optionElements = this.#optionListElement.optionElements;

      if (optionElements && optionElements.length > 0) {
        if (!this.#optionListElement.checkedOptionElement) {
          optionElements[0].setInitiallyChecked();
        }
        this.#refresh();
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
          this.#inputElementObserver.observe(node, { attributes: true });
          this.#inputElement = node;
        }
      } else
      if (node instanceof HapticOptionListElement) {
        if (!this.#optionListElement) {
          this.#eventListeners.add(node, 'change', () => {
            if (this.#refresh()) {
              this.dispatchEvent(new Event('change'));
            }
            this.focus();
            this.hidePopover();
          });
          this.#optionListElement = node;
        }
      }
    }
  }

  nodeRemoved(node) {
    switch (node) {
      case this.#inputElement:
        this.#inputElementObserver.disconnect();
        this.#inputElement = null;
        break;
      case this.#optionListElement:
        this.#eventListeners.remove(node);
        this.#optionListElement = null;
    }
    super.nodeRemoved(node);
  }

  showPopover() {
    const optionElements = this.#optionListElement?.optionElements;

    if (optionElements && optionElements.length > 0) {
      super.showPopover();

      for (let i = 0; i < optionElements.length; i++) {
        if (optionElements[i].checked) {
          this.#optionListElement.scrollTo(i);
          break;
        }
      }
    }
  }

  cancel() {
    const optionElements = this.#optionListElement?.optionElements;

    if (optionElements) {
      for (let optionElement of optionElements) {
        optionElement.highlighted = false;
      }
    }
  }

  reset() {
    this.#optionListElement.reset();
    this.#refresh();
  }

  #refresh() {
    const checkedOptionElement = this.#optionListElement?.checkedOptionElement
    const oldValue = this.#inputElement?.value || '';
    const newValue = checkedOptionElement?.value || '';

    if (this.#inputElement) {
      this.#inputElement.value = newValue;
    }
    if (this.toggleElement) {
      this.toggleElement.innerHTML = checkedOptionElement?.innerHTML;
    }
    return oldValue !== newValue;
  }
}
customElements.define('haptic-select-dropdown', HapticSelectDropdownElement);

class HapticOptionListElement extends HTMLElement {
  static observedAttributes = ['size'];

  optionElements = [];
  size = null;

  #eventListeners = new HapticEventListeners();

  constructor() {
    super();
  }

  get checkedOptionElement() {
    for (let optionElement of this.optionElements) {
      if (optionElement.checked) {
        return optionElement;
      }
    }
    return null;
  }

  get highlightedIndex() {
    for (let i = 0; i < this.optionElements.length; i++) {
      if (this.optionElements[i].highlighted) {
        return i;
      }
    }
    return -1;
  }

  set highlightedIndex(index) {
    for (let i = 0; i < this.optionElements.length; i++) {
      this.optionElements[i].highlighted = (i === index);
    }
    this.scrollTo(index);
    return index;
  }

  get scrollOffset() {
    return Math.floor(this.scrollTop / 24);
  }

  set scrollOffset(index) {
    this.scrollTop = 24 * index;
    return index;
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'size') {
      if (newValue === null) {
        this.size = null;
        this.style.maxHeight = null;
      } else {
        this.size = parseInt(newValue);
        this.style.maxHeight = `${24 * this.size}px`
      }
    }
  }

  connectedCallback() {
    new HapticChildNodesObserver({
      nodeAdded: node => {
        if (node instanceof HapticOptionElement) {
          this.#eventListeners.add(node, 'click', event => {
            for (let optionElement of this.optionElements) {
              optionElement.checked = optionElement === event.target;
            }
            this.dispatchEvent(new Event('change'));
          });
          this.#eventListeners.add(node, 'mouseover', event => {
            for (let optionElement of this.optionElements) {
              optionElement.highlighted = optionElement === event.target;
            }
          });
          this.#eventListeners.add(node, 'mouseout', event => {
            event.target.highlighted = false;
          });
          this.optionElements.push(node);
        }
      },
      nodeRemoved: node => {
        const index = this.optionElements.indexOf(node);

        if (index >= 0 && index < this.optionElements.length) {
          this.#eventListeners.remove(node);
          this.optionElements.splice(index, 1);
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
  }

  reset() {
    for (let optionElement of this.optionElements) {
      optionElement.reset();
    }
  }

  scrollTo(index) {
    if (this.size) {
      const offset = this.scrollOffset;

      if (index < offset) {
        this.scrollOffset = index;
      } else
      if (index > offset + this.size - 1) {
        this.scrollOffset = index - this.size + 1;
      }
    }
  }
}
customElements.define('haptic-option-list', HapticOptionListElement);

class HapticOptionElement extends HTMLElement {
  #initiallyChecked = false;

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
    return value;
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
    return value;
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
    return value
  }

  connectedCallback() {
    if (this.checked) {
      this.#initiallyChecked = true;
    }
  }

  reset() {
    this.checked = (this.#initiallyChecked === true);
  }

  setInitiallyChecked() {
    this.checked = true;
    this.#initiallyChecked = true;
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
    }).observe(this, { childList: true, subtree: true });
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
          this.#controlObserver.observe(node, { attributes: true });

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
      if (node.classList.contains('field-label')) {
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
  #eventListeners = new HapticEventListeners();
  #requiredElements = new Set();
  #submitButtons = new Set();

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
        if ((node instanceof HapticListElement ||
             node instanceof HapticSelectDropdownElement ||
             node instanceof HTMLInputElement ||
             node instanceof HTMLTextAreaElement ||
             node instanceof HTMLSelectElement) &&
            node.required) {
          this.#eventListeners.add(node, 'change', () => {
            this.#refresh();
          });
          this.#eventListeners.add(node, 'input', () => {
            this.#refresh();
          });
          this.#requiredElements.add(node);
          this.#refresh();
        }
      },
      nodeRemoved: node => {
        if (this.#requiredElements.has(node)) {
          this.#eventListeners.remove(node)
          this.#requiredElements.delete(node);
        } else
        if (this.#submitButtons.has(node)) {
          this.#submitButtons.delete(node);
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
  }

  #refresh() {
    if (this.#submitButtons.size > 0) {
      let submittable = true;

      for (let field of this.#requiredElements) {
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

class HapticAsyncErrorEvent extends Event {
  #message;

  constructor(message) {
    super('error');
    this.#message = message;
  }

  get message() {
    return this.#message;
  }
}

class HapticAsyncFormElement extends HapticFormElement {
  #eventListeners = new HapticEventListeners();
  #elements = new Set();

  constructor() {
    super();   
  }

  get accept() {
    return this.getAttribute('data-accept');
  }

  get redirect() {
    return this.getAttribute('data-redirect');
  }

  get submitOnChange() {
    return this.hasAttribute('data-submit-on-change');
  }

  connectedCallback() {
    super.connectedCallback();
    this.classList.add('haptic-async-form');

    this.addEventListener('submit', event => {
      this.submit();
      event.preventDefault();
    });

    new HapticChildNodesObserver({
      nodeAdded: node => {
        if (node instanceof HapticInputElement ||
            node instanceof HapticSelectElement ||
            node instanceof HapticSelectDropdownElement ||
            node instanceof HapticTextAreaElement) {
          this.#eventListeners.add(node, 'change', event => {
            if (event.intercepted) {
              delete event.intercepted;
            } else
            if (this.submitOnChange) {
              event.preventDefault();
              event.stopPropagation();
              event.intercepted = true;
              this.submit(event);
            }
          }, { capture: true });
          this.#elements.add(node);
        }
      },
      nodeRemoved: node => {
        this.#elements.delete(node);
        this.#eventListeners.remove(node);
      }
    }).observe(this, { childList: true, subtree: true });
  }

  submit(changeEvent = null) {
    const formData = new FormData(this);
    this.#setBusy(true);

    fetch(this.action, {
      method: this.method,
      headers: {
        'Accept': this.accept || 'application/json'
      },
      body: formData,
      redirect: this.redirect || 'follow'
    })
    .then(response => {
      if (response.ok) {
        this.#refresh();

        if (changeEvent) {
          changeEvent.target?.dispatchEvent(changeEvent);
        }
      } else {
        response.text().then(text => {
          this.#dispatchErrorEvent(text);
          this.reset();
        });
      }
    })
    .catch(error => {
      this.#dispatchErrorEvent(error.message);
      this.reset();
    })
    .finally(() => {
      this.#setBusy(false);
    });
  }

  reset() {
    for (let element of this.#elements) {
      element.reset({ silent: true });
    }
  }

  #dispatchErrorEvent(message) {
    try {
      this.dispatchEvent(new HapticAsyncErrorEvent(message));
    } catch (error) {
      console.error(error);
    }
  }

  #refresh() {
    for (let element of this.#elements) {
      element.refreshInitialValue();
    }
  }

  #setBusy(value) {
    if (value) {
      this.classList.add('busy');
    } else {
      this.classList.remove('busy');
    }
    for (let element of this.#elements) {
      element.disabled = value;
    }
  }
}
customElements.define('haptic-async-form', HapticAsyncFormElement, { extends: 'form' });

class HapticInputElement extends HTMLInputElement {
  static observedAttributes = ['disabled'];

  #initialValue = null;

  constructor() {
    super();
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'disabled') {
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
  }

  connectedCallback() {
    switch (this.type) {
      case 'submit':
        this.classList.add('haptic-button');
        break;
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
      default:
        this.classList.add('haptic-field');
        this.#initialValue = this.value;
    }
  }

  refreshInitialValue() {
    switch (this.type) {
      case 'submit':
        break;
      case 'checkbox':
      case 'radio':
        this.#initialValue = this.checked;
        break;
      default:
        this.#initialValue = this.value;
    }
  }

  reset(options = {}) {
    switch (this.type) {
      case 'submit':
        break;
      case 'checkbox':
      case 'radio':
        if (this.checked != this.#initialValue) {
          this.checked = this.#initialValue;
          if (!options.silent) {
            this.dispatchEvent(new Event('change'));
          }
        }
        break;
      default:
        if (this.value != this.#initialValue) {
          this.value = this.#initialValue;
          if (!options.silent) {
            this.dispatchEvent(new Event('change'));
          }
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
    if (!this.classList.contains('field-label')) {
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
    return this.hasAttribute('required');
  }

  get value() {
    for (let listItemElement of this.#listItemElements) {
      if (listItemElement.checked) {
        return listItemElement.value;
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
    }).observe(this, { childList: true, subtree: true });
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
  }
}
customElements.define('haptic-list', HapticListElement);

class HapticListItemElement extends HTMLElement {
  #control = null;
  #controlObserver = new HapticControlObserver(this);
  #eventListeners = new HapticEventListeners();

  constructor() {
    super();
  }

  get checked() {
    return this.#control?.checked;
  }

  get value() {
    return this.#control?.value;
  }

  connectedCallback() {
    new HapticChildNodesObserver({
      nodeAdded: node => {
        if (node instanceof HTMLInputElement && !this.#control) {
          node.classList.add('embedded');

          if (node.classList.contains('haptic-checkbox')) {
            this.setAttribute('control-type', 'checkbox');
          } else
          if (node.classList.contains('haptic-radio-button')) {
            this.setAttribute('control-type', 'radio-button');
          } else
          if (node.classList.contains('haptic-switch')) {
            this.setAttribute('control-type', 'switch');
          }
          this.#eventListeners.add(node, 'change', () => {
            this.dispatchEvent(new Event('change'));
          });
          this.#controlObserver.observe(node, { attributes: true });
          this.#control = node;
        }
      },
      nodeRemoved: node => {
        if (node === this.#control) {
          node.classList.remove('embedded');
          this.removeAttribute('control-type');
          this.#eventListeners.remove(node);
          this.#controlObserver.disconnect();
          this.#control = null;
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
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
        if (node instanceof HTMLInputElement && node.classList.contains('outlined')) {
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
    this.refreshInitialValue();
  }

  refreshInitialValue() {
    this.#initialValue = this.value;
  }

  reset(options = {}) {
    if (this.value != this.#initialValue) {
      this.value = this.#initialValue;
      if (!options.silent) {
        this.dispatchEvent(new Event('change'));
      }
    }
  }
}
customElements.define('haptic-select', HapticSelectElement, { extends: 'select' });

class HapticTextAreaElement extends HTMLTextAreaElement {
  #eventListeners = new HapticEventListeners();
  #initialValue = null;

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

  refreshInitialValue() {
    this.#initialValue = this.value;
  }

  reset(options = {}) {
    if (this.value != this.#initialValue) {
      this.value = this.#initialValue;
      if (!options.silent) {
        this.dispatchEvent(new Event('change'));
      }
    }
  }

  resize() {
    this.style.height = 'auto';
    this.style.height = `${this.scrollHeight}px`;
  }
}
customElements.define('haptic-textarea', HapticTextAreaElement, { extends: 'textarea' });
