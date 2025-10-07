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
  #owner = null;
  #observedAttributes = null;
  #observedClassNames = null;

  constructor(owner, observedAttributes = [], observedClassNames = []) {
    super(mutationList => {
      for (let mutationRecord of mutationList) {
        if (mutationRecord.attributeName == 'class') {
          for (let className of observedClassNames) {
            if (mutationRecord.target.classList.contains(className)) {
              owner.classList.add(className);
            } else {
              owner.classList.remove(className);
            }
          }
        } else {
          for (let name of observedAttributes) {
            if (mutationRecord.attributeName == name) {
              if (mutationRecord.target.hasAttribute(name)) {
                owner.setAttribute(name, '');
              } else {
                owner.removeAttribute(name);
              }
            }
          }
        }
      }
    });
    this.#owner = owner;
    this.#observedAttributes = observedAttributes;
    this.#observedClassNames = observedClassNames;
  }

  observeAttributes(control) {
    for (let className of this.#observedClassNames) {
      if (control.classList.contains(className)) {
        this.#owner.classList.add(className);
      } else {
        this.#owner.classList.remove(className);
      }
    }
    for (let name of this.#observedAttributes) {
      if (control.hasAttribute(name)) {
        this.#owner.setAttribute(name, '');
      } else {
        this.#owner.removeAttribute(name);
      }
    }
    this.observe(control, { attributes: true });
  }
}

class HapticLock {
  static EVENT_TYPES_TO_BLOCK = ['keydown', 'keyup'];

  #control;
  #eventListener;

  constructor(control) {
    this.#control = control;
    this.#eventListener = event => event.preventDefault();
  }

  get activated() {
    return this.#control.hasAttribute('locked');
  }

  set activated(value) {
    if (value) {
      if (!this.#control.hasAttribute('locked')) {
        for (let eventType of HapticLock.EVENT_TYPES_TO_BLOCK) {
          this.#control.addEventListener(eventType, this.#eventListener);
        }
        this.#control.setAttribute('locked', 'locked');
      }
    } else {
      if (this.#control.hasAttribute('locked')) {
        for (let eventType of HapticLock.EVENT_TYPES_TO_BLOCK) {
          this.#control.removeEventListener(eventType, this.#eventListener);
        }
        this.#control.removeAttribute('locked');
      }
    }
    return value;
  }
}

class HapticButtonElement extends HTMLButtonElement {
  #lock = new HapticLock(this);

  constructor() {
    super();
  }

  get locked() {
    return this.#lock.activated;
  }

  set locked(value) {
    return this.#lock.activated = value;
  }

  connectedCallback() {
    if (!this.classList.contains('haptic-icon-button')) {
      this.classList.add('haptic-button');
    }
    if (this.form instanceof HapticFormElement) {
      this.form.controlAdded(this);
    }
  }

  disconnectedCallback() {
    if (this.form instanceof HapticFormElement) {
      this.form.controlRemoved(this);
    }
  }
}
customElements.define('haptic-button', HapticButtonElement, { extends: 'button' });

class HapticSegmentedButtonElement extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    new HapticChildNodesObserver({
      nodeAdded: node => {
        if (node instanceof HapticInputElement) {
          if (node.classList.contains('outlined')) {
            this.classList.add('outlined');
          }
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }
}
customElements.define('haptic-segmented-button', HapticSegmentedButtonElement);

class HapticButtonSegmentElement extends HTMLElement {
  #control = null;
  #controlObserver = new HapticControlObserver(this, ['disabled']);

  constructor() {
    super();
  }

  connectedCallback() {
    new HapticChildNodesObserver({
      nodeAdded: node => {
        if (node instanceof HapticInputElement) {
          node.classList.remove('haptic-radio-button');
          this.#control = node;
          this.#controlObserver.observeAttributes(node);
        } else
        if (node instanceof HapticLabelElement) {
          node.classList.remove('haptic-label');
        }
      },
      nodeRemoved: node => {
        if (node === this.#control) {
          this.#controlObserver.disconnect();
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }
}
customElements.define('haptic-button-segment', HapticButtonSegmentElement);

class HapticChipElement extends HTMLElement {
  #control = null;
  #controlObserver = new HapticControlObserver(this, ['disabled']);

  constructor() {
    super();
  }

  connectedCallback() {
    new HapticChildNodesObserver({
      nodeAdded: node => {
        if (node instanceof HapticInputElement) {
          node.classList.remove('haptic-checkbox');
          this.#control = node;
          this.#controlObserver.observeAttributes(node);
        } else
        if (node instanceof HapticLabelElement) {
          node.classList.remove('haptic-label');
        }
      },
      nodeRemoved: node => {
        if (node === this.#control) {
          this.#controlObserver.disconnect();
        }
      }
    }).observe(this, { childList: true, subtree: true });
  }
}
customElements.define('haptic-chip', HapticChipElement);

class HapticDropdownElement extends HTMLElement {
  static observedAttributes = ['disabled'];

  #tabIndex = null;
  #toggleElement = null;
  #popoverElement = null;
  #backdropElement = null;
  #eventListeners = new HapticEventListeners();
  #lock = new HapticLock(this);

  #toggleObserver = new HapticControlObserver(this, [], ['inline']);

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

  get locked() {
    return this.#lock.activated;
  }

  set locked(value) {
    return this.#lock.activated = value;
  }

  get toggleElement() {
    return this.#toggleElement;
  }

  get popoverElement() {
    return this.#popoverElement;
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'disabled') {
      if (newValue !== null) {
        this.hidePopover();
        this.tabIndex = -1;
      } else {
        this.tabIndex = this.#tabIndex;
      }
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
          this.#tabIndex = node.tabIndex;
          node.tabIndex = -1;

          this.#eventListeners.add(node, 'click', event => {
            if (!this.disabled && !this.locked) {
              if (this.isOpen()) {
                this.hidePopover({ cancel: true });
              } else {
                this.showPopover();
              }
            }
            event.preventDefault();
          });
          this.#toggleObserver.observeAttributes(node);
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
        node.tabIndex = this.#tabIndex;
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
    if (!this.disabled && this.popoverElement) {
      if (this.getBoundingClientRect().x > (window.innerWidth / 2)) {
        this.#popoverElement.classList.add('auto-justify-right');
      } else {
        this.#popoverElement.classList.remove('auto-justify-right');
      }
      this.setAttribute('popover-open', 'popover-open');
    }
  }

  hidePopover(options = {}) {
    if (!this.disabled && this.hasAttribute('popover-open')) {
      this.removeAttribute('popover-open');

      if (options.cancel) {
        this.cancel();
      }
    }
  }

  cancel() {
  }
}
customElements.define('haptic-dropdown', HapticDropdownElement);

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
          if (!this.disabled && !this.locked) {
            this.hidePopover({ reset: true });
            event.preventDefault();
          }
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
  #inputElementObserver = new HapticControlObserver(this, ['disabled', 'locked', 'required']);
  #optionListElement = null;
  #eventListeners = new HapticEventListeners();
  #preventMousover = false;
  #keyboardInput = '';
  #keyboardInputTimeoutId = null;

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
      const optionListElement = this.#optionListElement;

      if (optionListElement && !this.disabled && !this.locked) {
        if (event.key === 'Enter' || event.key === ' ') {
          if (this.isOpen()) {
            event.preventDefault();
          }
        } else {
          const optionElements = optionListElement.optionElements;

          if (optionElements.length > 0) {
            const size = optionListElement.size;

            let newHighlightedIndex = null;
            let backward = false;

            switch (event.key) {
              case 'ArrowDown':
                if (this.isOpen()) {
                  if (optionListElement.highlightedIndex >= 0) {
                    newHighlightedIndex = optionListElement.highlightedIndex + 1;
                  }
                } else {
                  this.showPopover();
                }
                if (newHighlightedIndex === null) {
                  if (size) {
                    newHighlightedIndex = optionListElement.scrollOffset;
                  } else {
                    newHighlightedIndex = 0;
                  }
                }
                event.preventDefault();
                break;
              case 'ArrowUp':
                if (this.isOpen()) {
                  if (optionListElement.highlightedIndex >= 0) {
                    newHighlightedIndex = optionListElement.highlightedIndex - 1;
                  }
                } else {
                  this.showPopover();
                }
                if (newHighlightedIndex === null) {
                  if (size) {
                    newHighlightedIndex = Math.min(
                      optionListElement.scrollOffset + size,
                      optionElements.length
                    ) - 1;
                  } else {
                    newHighlightedIndex = optionElements.length - 1;
                  }
                }
                backward = true;
                event.preventDefault();
                break;
              case 'End':
                if (this.isOpen()) {
                  newHighlightedIndex = optionElements.length - 1;
                  backward = true;
                  event.preventDefault();
                }
                break;
              case 'Home':
                if (this.isOpen()) {
                  newHighlightedIndex = 0;
                  event.preventDefault();
                }
                break;
              case 'PageDown':
                if (size && this.isOpen()) {
                  if (optionListElement.highlightedIndex >= 0 &&
                      optionListElement.scrollOffset + size >= optionElements.length) {
                    newHighlightedIndex = optionElements.length - 1;
                    backward = true;
                  } else {
                    const highlightedOffset = optionListElement.highlightedOffset;

                    optionListElement.scrollBy(size);

                    if (highlightedOffset >= 0) {
                      newHighlightedIndex = optionListElement.scrollOffset + highlightedOffset;
                    }
                    this.#preventMousover = true;
                  }
                  event.preventDefault();
                }
                break;
              case 'PageUp':
                if (size && this.isOpen()) {
                  if (optionListElement.highlightedIndex >= 0 &&
                      optionListElement.scrollOffset === 0) {
                    newHighlightedIndex = 0;
                  } else {
                    const highlightedOffset = optionListElement.highlightedOffset;

                    optionListElement.scrollBy(size * -1);

                    if (highlightedOffset >= 0) {
                      newHighlightedIndex = optionListElement.scrollOffset + highlightedOffset;
                    }
                    this.#preventMousover = true;
                  }
                  event.preventDefault();
                }
                break;
            }
            if (newHighlightedIndex !== null) {
              while (newHighlightedIndex >= 0 && newHighlightedIndex < optionElements.length) {
                if (optionElements[newHighlightedIndex]?.disabled) {
                  newHighlightedIndex = newHighlightedIndex + (backward ? -1 : 1);
                } else {
                  optionListElement.highlightedIndex = newHighlightedIndex;
                  break;
                }
              }
            }
          }
        }
      }
    });
    this.#eventListeners.add(this, 'keyup', event => {
      const optionListElement = this.#optionListElement;

      if (optionListElement && !this.disabled && !this.locked) {
        switch (event.key) {
          case ' ':
          case 'Enter':
            if (this.isOpen()) {
              for (let optionElement of optionListElement.optionElements) {
                optionElement.checked = optionElement.highlighted;
              }
              if (this.#refresh()) {
                this.dispatchEvent(new Event('change'));
              }
              this.focus();
              this.hidePopover();
            } else
            if (optionListElement.optionElements.length() > 0) {
              this.showPopover();
            }
            event.preventDefault();
            break;
          default:
            if (this.isOpen() && event.key.length === 1) {
              if (this.#keyboardInputTimeoutId) {
                clearTimeout(this.#keyboardInputTimeoutId);
                this.#keyboardInputTimeoutId = null;
              }
              this.#keyboardInput = this.#keyboardInput + event.key;
              const searchString = this.#keyboardInput.toLowerCase();

              if (!optionListElement.highlightedOptionElement?.textStartsWith(searchString)) {
                const optionElements = optionListElement.optionElements;

                for (let i = 0; i <optionElements.length; i++) {
                  const optionElement = optionElements[i];

                  if (!optionElement.disabled && optionElement.textStartsWith(searchString)) {
                    optionListElement.highlightedIndex = i;
                    break;
                  }
                }
              }
              this.#keyboardInputTimeoutId = setTimeout(() => {
                this.#keyboardInput = '';
                this.#keyboardInputTimeoutId = null;
              }, 1000);
              event.preventDefault();
            }
        }
      }
    });
    this.#eventListeners.add(document, 'DOMContentLoaded', () => {
      const optionElements = this.#optionListElement.optionElements;

      if (optionElements && optionElements.length > 0) {
        if (!this.#optionListElement.checkedOptionElement) {
          for (let optionElement of optionElements) {
            if (!optionElement.disabled) {
              optionElement.checked = true;
              optionElement.initiallyChecked = true;
              break;
            }
          }
        }
        this.#refresh();
      }
    });
    if (this.form instanceof HapticFormElement) {
      this.form.controlAdded(this);
    }
    super.connectedCallback();
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
    super.disconnectedCallback();

    if (this.form instanceof HapticFormElement) {
      this.form.controlRemoved(this);
    }
  }

  nodeAdded(node) {
    super.nodeAdded(node);

    if (node instanceof HTMLElement) {
      if (node instanceof HTMLInputElement) {
        if (!this.#inputElement) {
          node.classList.add('embedded');
          this.#inputElementObserver.observeAttributes(node);
          this.#inputElement = node;
        }
      } else
      if (node instanceof HapticOptionListElement) {
        if (!this.#optionListElement) {
          this.#optionListElement = node;
        }
      } else
      if (node instanceof HapticOptionElement) {
        this.#eventListeners.add(node, 'click', event => {
          if (!event.target.disabled) {
            this.#optionListElement?.optionElements?.forEach(optionElement => {
              optionElement.checked = optionElement === event.target;
            });
            this.focus();
            this.hidePopover();

            if (this.#refresh()) {
              this.dispatchEvent(new Event('change'));
            }
          }
        });
        this.#eventListeners.add(node, 'mouseover', event => {
          if (!event.target.disabled) {
            if (this.#preventMousover) {
              this.#preventMousover = false;
            } else {
              this.#optionListElement?.optionElements?.forEach(optionElement => {
                optionElement.highlighted = optionElement === event.target;
              });
            }
          }
        });
        this.#eventListeners.add(node, 'mouseout', event => {
          if (!event.target.disabled) {
            event.target.highlighted = false;
          }
        });
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
        this.#optionListElement = null;
        break;
      default:
        this.#eventListeners.remove(node);
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
    this.#optionListElement?.optionElements?.forEach(optionElement => {
      optionElement.highlighted = false;
    });
  }

  reset() {
    this.#optionListElement?.optionElements?.forEach(optionElement => {
      optionElement.reset();
    });
    this.#refresh();
  }

  refreshInitialValue() {
    this.#optionListElement?.optionElements?.forEach(optionElement => {
      optionElement.initiallyChecked = optionElement.checked;
    });
  }

  #refresh() {
    const checkedOptionElement = this.#optionListElement?.checkedOptionElement
    const oldValue = this.#inputElement?.value || '';
    const newValue = checkedOptionElement?.value || '';

    if (this.#inputElement) {
      this.#inputElement.value = newValue;
    }
    if (this.toggleElement) {
      this.toggleElement.innerHTML = checkedOptionElement?.innerHTML || '';
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

  get highlightedOptionElement() {
    for (let optionElement of this.optionElements) {
      if (optionElement.highlighted) {
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
      if (!this.optionElements[i].disabled) {
        this.optionElements[i].highlighted = (i === index);
      }
    }
    this.scrollTo(index);
    return index;
  }

  get highlightedOffset() {
    return Math.max(this.highlightedIndex - this.scrollOffset, -1);
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

  scrollBy(delta) {
    if (delta !== null && this.size) {
      this.scrollOffset = this.scrollOffset + delta;
    }
  }

  scrollTo(index) {
    if (index !== null && this.size) {
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

  get disabled() {
    return this.hasAttribute('disabled');
  }

  set disabled(value) {
    if (value == true) {
      this.setAttribute('disabled', '');
    } else {
      this.removeAttribute('disabled');
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

  get initiallyChecked() {
    return this.#initiallyChecked;
  }

  set initiallyChecked(value) {
    return this.#initiallyChecked = value;
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
      this.initiallyChecked = true;
    }
  }

  reset() {
    this.checked = (this.initiallyChecked === true);
  }

  textStartsWith(searchString) {
    return this.innerText.toLowerCase().startsWith(searchString);
  }
}
customElements.define('haptic-option', HapticOptionElement);

class HapticFieldElement extends HTMLElement {
  static ICON_NAMES = ['error', 'leading', 'trailing'];

  #setValidOnChange = null;
  #control = null;
  #label = null;
  #eventListeners = new HapticEventListeners();

  #controlObserver = new HapticControlObserver(
    this,
    ['disabled', 'locked', 'required'],
    ['inline']
  );

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

          /*if (!node.validity.valid) {
            this.setAttribute('invalid', '');
          }*/
          if (node instanceof HapticTextAreaElement) {
            if (!node.hasAttribute('rows')) {
              node.setAttribute('rows', 1);
            }
          }
          this.#controlObserver.observeAttributes(node);

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
          node.classList.add('embedded');
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
          node.classList.remove('embedded');
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
  #controls = new Set();
  #requiredFields = new Set();
  #submitButtons = new Set();
  #isSubmitting = false;

  constructor() {
    super();   
  }

  get busy() {
    this.classList.contains('busy');
  }

  set busy(value) {
    if (value) {
      this.classList.add('busy')
    } else {
      this.classList.remove('busy');
    }
    return value;
  }

  get controls() {
    return this.#controls.values();
  }

  connectedCallback() {
    this.classList.add('haptic-form');

    this.addEventListener('submit', event => {
      this.submit();
      event.preventDefault();
    });
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
    super.disconnectedCallback();
  }

  controlAdded(control) {
    this.#controls.add(control);

    if ((control instanceof HapticButtonElement ||
         control instanceof HapticInputElement) &&
        control.type === 'submit') {
    this.#submitButtons.add(control);
    this.#refresh();
    } else
    if ((control instanceof HapticListElement ||
         control instanceof HapticSelectDropdownElement ||
         control instanceof HapticInputElement ||
         control instanceof HapticTextAreaElement ||
         control instanceof HapticSelectElement) &&
        control.required) {
      this.#eventListeners.add(control, 'change', () => {
        this.#refresh();
      });
      this.#eventListeners.add(control, 'input', () => {
        this.#refresh();
      });
      this.#requiredFields.add(control);
      this.#refresh();
    }
  }

  controlRemoved(control) {
    this.#controls.delete(control);

    if (this.#requiredFields.has(control)) {
      this.#eventListeners.remove(control)
      this.#requiredFields.delete(control);
    } else
    if (this.#submitButtons.has(control)) {
      this.#submitButtons.delete(control);
    }
  }

  reset() {
    for (let control of this.#controls) {
      if ('reset' in control) {
        control.reset({ silent: true });
      }
    }
  }

  submit() {
    this.trySubmit(() => {
      setTimeout(() => { this.busy = true }, 400);
      super.submit();
    });
  }

  trySubmit(func) {
    if (!this.#isSubmitting) {
      this.#isSubmitting = true;

      for (let control of this.#controls) {
        if ('locked' in control) {
          control.locked = true;
        }
      }
      func(() => {
        for (let control of this.#controls) {
          if ('locked' in control) {
            control.locked = false;
          }
        }
        this.#isSubmitting = false;
      });
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

  constructor() {
    super();   
  }

  get accept() {
    return this.getAttribute('data-accept');
  }

  set accept(value) {
    if (value) {
      this.setAttribute('data-accept', '');
    } else {
      this.removeAttribute('data-accept');
    }
    return value;
  }

  get redirect() {
    return this.getAttribute('data-redirect');
  }

  set redirect(value) {
    if (value) {
      this.setAttribute('data-redirect', '');
    } else {
      this.removeAttribute('data-redirect');
    }
    return value;
  }

  get submitOnChange() {
    return this.hasAttribute('data-submit-on-change');
  }

  set submitOnChange(value) {
    if (value) {
      this.setAttribute('data-submit-on-change', '');
    } else {
      this.removeAttribute('data-submit-on-change');
    }
    return value;
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
    super.disconnectedCallback();
  }

  controlAdded(control) {
    super.controlAdded(control);

    this.#eventListeners.add(control, 'change', event => {
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
  }

  controlRemoved(control) {
    this.#eventListeners.remove(control);
    super.controlRemoved(control);
  }

  submit(changeEvent = null) {
    this.trySubmit(submittingFinished => {
      this.busy = true;

      const formData = new FormData(this);

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
        this.busy = false;
        submittingFinished();
      });
    });
  }

  #dispatchErrorEvent(message) {
    try {
      this.dispatchEvent(new HapticAsyncErrorEvent(message));
    } catch (error) {
      console.error(error);
    }
  }

  #refresh() {
    for (let control of this.controls) {
      if ('refreshInitialValue' in control) {
        control.refreshInitialValue();
      }
    }
  }
}
customElements.define('haptic-async-form', HapticAsyncFormElement, { extends: 'form' });

class HapticInputElement extends HTMLInputElement {
  static observedAttributes = ['disabled'];

  #lock = new HapticLock(this);
  #initialValue = null;

  constructor() {
    super();
  }

  get locked() {
    return this.#lock.activated;
  }

  set locked(value) {
    return this.#lock.activated = value;
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'disabled') {
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
    if (this.form instanceof HapticFormElement) {
      this.form.controlAdded(this);
    }
  }

  disconnectedCallback() {
    if (this.form instanceof HapticFormElement) {
      this.form.controlRemoved(this);
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
  static observedAttributes = ['for'];

  constructor() {
    super();
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'for') {
      if (this.control?.disabled) {
        this.classList.add('grayed');
      } else {
        this.classList.remove('grayed');
      }
    }
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

  get form() {
    return this.closest('form');
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

    if (this.form instanceof HapticFormElement) {
      this.form.controlAdded(this);
    }
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();

    if (this.form instanceof HapticFormElement) {
      this.form.controlRemoved(this);
    }
  }
}
customElements.define('haptic-list', HapticListElement);

class HapticListItemElement extends HTMLElement {
  #control = null;
  #controlObserver = new HapticControlObserver(this, ['disabled']);
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
          this.#controlObserver.observeAttributes(node);
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

class HapticSelectElement extends HTMLSelectElement {
  static observedAttributes = ['disabled'];

  #lock = new HapticLock(this);
  #initialValue = null;

  constructor() {
    super();
  }

  get locked() {
    return this.#lock.activated;
  }

  set locked(value) {
    return this.#lock.activated = value;
  }

  connectedCallback() {
    this.classList.add('haptic-field');
    this.refreshInitialValue();

    if (this.form instanceof HapticFormElement) {
      this.form.controlAdded(this);
    }
  }

  disconnectedCallback() {
    if (this.form instanceof HapticFormElement) {
      this.form.controlRemoved(this);
    }
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
  #lock = new HapticLock(this);
  #initialValue = null;

  constructor() {
    super();
  }

  get locked() {
    return this.#lock.activated;
  }

  set locked(value) {
    return this.#lock.activated = value;
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
    if (this.form instanceof HapticFormElement) {
      this.form.controlAdded(this);
    }
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();

    if (this.form instanceof HapticFormElement) {
      this.form.controlRemoved(this);
    }
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
