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

class HapticAttributesObserver {
  #owner = null;
  #observedAttributes = null;
  #observedClassNames = null;
  #mutationObserver = null;

  constructor(owner, observedAttributes = [], observedClassNames = []) {
    this.#owner = owner;
    this.#observedAttributes = observedAttributes;
    this.#observedClassNames = observedClassNames;

    this.#mutationObserver = new MutationObserver(mutationList => {
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
  }

  observe(target) {
    for (let className of this.#observedClassNames) {
      if (target.classList.contains(className)) {
        this.#owner.classList.add(className);
      } else {
        this.#owner.classList.remove(className);
      }
    }
    for (let name of this.#observedAttributes) {
      if (target.hasAttribute(name)) {
        this.#owner.setAttribute(name, '');
      } else {
        this.#owner.removeAttribute(name);
      }
    }
    this.#mutationObserver.observe(target, { attributes: true });
  }

  disconnect() {
    this.#mutationObserver.disconnect();
  }
}

class HapticChildNodesObserver {
  #callbacks = null;
  #mutationObserver = null;

  constructor(callbacks = {}) {
    this.#mutationObserver = new MutationObserver(mutationList => {
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
    this.#callbacks = callbacks;
  }

  observe(target) {
    this.#triggerNodeAddedCallback(target.children);
    this.#mutationObserver.observe(target, { childList: true, subtree: true });
  }

  disconnect() {
    this.#mutationObserver.disconnect();
  }

  #triggerNodeAddedCallback(elements) {
    for (let element of elements) {
      this.#callbacks.nodeAdded(element);
      this.#triggerNodeAddedCallback(element.children);
    }
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

class HapticActivatable {
  #target;

  get target() {
    return this.#target;
  }

  constructor(target) {
    this.#target = target;
  }

  get active() {
    return this.#target.classList.contains('active');
  }

  set active(value) {
    const classList = this.#target.classList;

    if (value && !classList.contains('active')) {
      classList.add('active');
    } else
    if (!value && classList.contains('active')) {
      classList.remove('active');
    }
    return value;
  }
}

class HapticFocusable {
  #target;
  #originalTabIndex = null;

  #mutationObserver = new MutationObserver(mutationList => {
    for (let mutationRecord of mutationList) {
      if (mutationRecord.attributeName == 'disabled') {
        if (this.disabled) {
          this.focused = false;
        }
      }
    }
  });

  get target() {
    return this.#target;
  }

  constructor(target) {
    this.#mutationObserver.observe(target, { attributes: true });
    this.#originalTabIndex = target.tabIndex;
    target.tabIndex = -1;
    this.#target = target;
  }

  get active() {
    const target = this.#target;

    if (target instanceof HTMLInputElement) {
      return target.type === 'radio' && target.checked;
    } else {
      return target.classList.contains('active');
    }
  }

  get disabled() {
    return this.#target.disabled ? true : false;
  }

  get focused() {
    return this.#target.classList.contains('focused');
  }

  set focused(value) {
    const classList = this.#target.classList;

    if (value && !classList.contains('focused')) {
      classList.add('focused');
    } else
    if (!value && classList.contains('focused')) {
      classList.remove('focused');
    }
    return value;
  }

  disconnect() {
    this.#mutationObserver?.disconnect();
    this.#target.tabIndex = this.#originalTabIndex;
    this.#target = null;
  }
}

class HapticNavigationController {
  #mouse = false;
  #vertical = false;
  #target = null;
  #elements = [];
  #focused = false;
  #suspended = false;
  #skipNextMouseEvent = false;
  #eventListeners = new HapticEventListeners();

  get connected() {
    return this.#target !== null;
  }

  get #focusedElement() {
    for (let element of this.#elements) {
      if (element.focused && !element.disabled) {
        return element;
      }
    }
    return null;
  }

  set #focusedElement(element) {
    for (let e of this.#elements) {
      e.focused = (e.target === element && !e.disabled);
    }
    return element;
  }

  get #scrollContainer() {
    for (let element = this.#target; element; element = element.parentElement) {
      const style = getComputedStyle(element);
      const overflow = this.#vertical ? style.overflowY : style.overflowX;

      if (overflow !== 'visible' || element.tagName === 'BODY') {
        return element;
      }
    }
    return null;
  }

  constructor(options = {}) {
    this.#vertical = options.vertical === true;
    this.#mouse = options.mouse === true;
  }

  connect(target) {
    this.#eventListeners.add(target, 'focusin', () => {
      if (!this.#suspended && !this.#focusedElement) {
        let elementToBeFocused = null;

        for (let i = this.#elements.length - 1; i >= 0; i--) {
          const element = this.#elements[i];

          if (!element.disabled) {
            elementToBeFocused = element;

            if (element.active) {
              break;
            }
          }
        }
        if (elementToBeFocused) {
          elementToBeFocused.focused = true;
        }
      }
      this.#focused = true;
    });
    this.#eventListeners.add(target, 'focusout', event => {
      if (!this.#target.contains(event.relatedTarget)) {
        if (!this.#suspended) {
          this.reset();
        }
        this.#focused = false;
      }
    });
    this.#eventListeners.add(target, 'keydown', event => {
      if (!this.#suspended) {
        const elements = this.#elements;
        const size = elements.length;

        if (size > 0 && this.#focused) {
          const key = event.key;
          let focusedElement = null, form = null;

          switch (key) {
            case 'Enter':
              if (form = this.#target.form) {
                form.requestSubmit();
                event.preventDefault();
                break;
              }
            case ' ':
              if (focusedElement = this.#focusedElement) {
                focusedElement.target.click();
                event.preventDefault();
              }
              break;
            case 'ArrowDown':
            case 'ArrowLeft':
            case 'ArrowRight':
            case 'ArrowUp':
              if ((this.#vertical && key === 'ArrowUp') ||
                (!this.#vertical && key === 'ArrowLeft')) {
                let elementToBeFocused = null;

                for (let i = 0; i < size; i++) {
                  const element = this.#elements[i];

                  if (!element.disabled) {
                    if (element.focused) {
                      focusedElement = element;
                      elementToBeFocused ||= element;
                      break;
                    }
                    elementToBeFocused = element;
                  }
                }
                if (focusedElement !== elementToBeFocused) {
                  if (focusedElement !== null) {
                    focusedElement.focused = false;
                  }
                  if (elementToBeFocused) {
                    elementToBeFocused.focused = true;
                    this.#scrollIntoView(elementToBeFocused.target);
                  }
                }
                event.preventDefault();
                event.stopPropagation();
              } else
              if ((this.#vertical && key === 'ArrowDown') ||
                (!this.#vertical && key === 'ArrowRight')) {
                let focusedElement = null;
                let elementToBeFocused = null;

                for (let i = size - 1; i >= 0; i--) {
                  const element = this.#elements[i];

                  if (!element.disabled) {
                    if (element.focused) {
                      focusedElement = element;
                      elementToBeFocused ||= element;
                      break;
                    }
                    elementToBeFocused = element;
                  }
                }
                if (focusedElement !== elementToBeFocused) {
                  if (focusedElement !== null) {
                    focusedElement.focused = false;
                  }
                  if (elementToBeFocused) {
                    elementToBeFocused.focused = true;
                    this.#scrollIntoView(elementToBeFocused.target);
                  }
                }
                event.preventDefault();
                event.stopPropagation();
              }
          }
        }
      }
    });
    this.#eventListeners.add(target, 'keyup', event => {
      if (!this.#suspended) {
        const key = event.key;

        if ((this.#vertical &&
            (key === 'ArrowUp' ||
            key === 'ArrowDown')) ||
          (!this.#vertical &&
            (key === 'ArrowLeft' ||
            key === 'ArrowRight'))) {
          event.preventDefault();
          event.stopPropagation();
        }
      }
    });
    this.#target = target;
  }

  disconnect() {
    this.#eventListeners.removeAll();

    for (let element of this.#elements) {
      element.disconnect();
    }
    this.#elements = [];
    this.#target = null;
    this.#focused = false;
    this.#suspended = false;
    this.#skipNextMouseEvent = false;
  }

  add(element) {
    this.#eventListeners.add(element, 'click', event => {
      if (!this.#suspended) {
        this.#focusedElement = event.target;
      }
    });
    if (this.#mouse) {
      this.#eventListeners.add(element, 'mouseover', event => {
        if (this.#skipNextMouseEvent) {
          this.#skipNextMouseEvent = false;
        } else
        if (!this.#suspended) {
          this.#focusedElement = event.target;

          if (!this.#target.focused) {
            this.#target.focus();
          }
          this.#scrollIntoView(event.target);
        }
      });
      this.#eventListeners.add(element, 'mouseout', () => {
        if (!this.#suspended) {
          this.#focusedElement = null;
        }
      });
    }
    this.#elements.push(new HapticFocusable(element));
    return this;
  }

  remove(element) {
    for (let i = 0; i < this.#elements.length; i++) {
      if (this.#elements[i].target === element) {
        this.#eventListeners.remove(element);
        this.#elements[i].disconnect();
        this.#elements.splice(i, 1);
        return true;
      }
    }
    return false;
  }

  focusFirst() {
    if (!this.#suspended) {
      let focusSet = false;

      for (let i = 0; i < this.#elements.length; i++) {
        const element = this.#elements[i];

        if (element.focused = (!focusSet && !element.disabled)) {
          this.#scrollIntoView(element.target);
          focusSet = true;
        }
      }
    }
  }

  focusLast() {
    if (!this.#suspended) {
      let focusSet = false;

      for (let i = this.#elements.length - 1; i >= 0; i--) {
        const element = this.#elements[i];

        if (element.focused = (!focusSet && !element.disabled)) {
          this.#scrollIntoView(element.target);
          focusSet = true;
        }
      }
    }
  }

  suspend() {
    this.#suspended = true;
  }

  resume() {
    this.#suspended = false;
    this.#scrollIntoView(this.#focusedElement?.target);
  }

  skipNextMouseEvent() {
    this.#skipNextMouseEvent = true;
  }

  reset() {
    this.#focusedElement = null;
    this.#skipNextMouseEvent = false;
  }

  #scrollIntoView(element) {
    const container = this.#scrollContainer;

    if (element && container) {
      const elementRect = element.getBoundingClientRect();
      const targetRect = this.#target.getBoundingClientRect();
      const containerRect = container.getBoundingClientRect();

      if (this.#vertical) {
        if (elementRect.top < containerRect.top) {
          container.scrollTop -= containerRect.top - (
            element === this.#elements[0].target ?
              targetRect: elementRect
          ).top;
        } else
        if (elementRect.bottom > containerRect.bottom) {
          container.scrollTop += (
            element === this.#elements[this.#elements.length - 1].target ?
              targetRect : elementRect
          ).bottom - containerRect.bottom
        }
      } else {
        if (elementRect.left < containerRect.left) {
          container.scrollLeft -= containerRect.left - (
            element === this.#elements[0].target ?
              targetRect: elementRect
          ).left;
        } else
        if (elementRect.right > containerRect.right) {
          container.scrollLeft += (
            element === this.#elements[this.#elements.length - 1].target ?
              targetRect : elementRect
          ).right - containerRect.right;
        }
      }
    }
  }
}

class HapticButtonElement extends HTMLButtonElement {
  static observedAttributes = ['data-haptic-confirm'];

  #confirmed = null;
  #lock = new HapticLock(this);
  #eventListeners = new HapticEventListeners();

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
    if (newValue) {
      this.#confirmed = false;

      this.#eventListeners.add(this, 'click', event => {
        if (!this.#confirmed) {
          Haptic.confirm.show(newValue).then(confirmed => {
            if (confirmed) {
              this.#confirmed = true;
              this.dispatchEvent(
                new event.constructor(event.type, event)
              );
            }
          }).finally(() => {
            this.#confirmed = false;
          });
          event.preventDefault();
          event.stopPropagation();
        }
      });
    } else {
      this.#eventListeners.remove(this);
    }
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
    this.#eventListeners.removeAll();

    if (this.form instanceof HapticFormElement) {
      this.form.controlRemoved(this);
    }
  }
}
customElements.define('haptic-button', HapticButtonElement, { extends: 'button' });

class HapticSegmentedButtonElement extends HTMLElement {
  #navigationController = new HapticNavigationController();

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HapticInputElement) {
        if (node.classList.contains('outlined')) {
          this.classList.add('outlined');
        }
        this.#navigationController.add(node);
      }
    },
    nodeRemoved: node => {
      if (node instanceof HapticInputElement) {
        this.#navigationController.remove(node);
      }
    }
  });

  constructor() {
    super();
  }

  connectedCallback() {
    this.tabIndex = Math.max(this.tabIndex, 0);
    this.#navigationController.connect(this);
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();
    this.#navigationController.disconnect();
  }
}
customElements.define('haptic-segmented-button', HapticSegmentedButtonElement);

class HapticButtonSegmentElement extends HTMLElement {
  #control = null;
  #label = null;

  #controlObserver = new HapticAttributesObserver(this, ['disabled']);

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HapticInputElement && !this.#control) {
        node.classList.remove('haptic-radio-button');
        node.classList.add('button-segment-radio-button');
        this.#control = node;
        this.#controlObserver.observe(node);
      } else
      if (node instanceof HapticLabelElement && !this.#label) {
        node.classList.remove('haptic-label');
        node.classList.add('button-segment-label');
        this.#label = node;
      }
    },
    nodeRemoved: node => {
      switch (node) {
        case this.#control:
          this.#controlObserver.disconnect();
          this.#control = null;
          break;
        case this.#label:
          this.#label = null;
      }
    }
  })

  constructor() {
    super();
  }

  connectedCallback() {
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();
  }
}
customElements.define('haptic-button-segment', HapticButtonSegmentElement);

class HapticChipElement extends HTMLElement {
  #control = null;
  #label = null;

  #controlObserver = new HapticAttributesObserver(this, ['disabled']);

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HapticInputElement && !this.control) {
        node.classList.remove('haptic-checkbox');
        node.classList.add('chip-checkbox');
        this.#control = node;
        this.#controlObserver.observe(node);
      } else
      if (node instanceof HapticLabelElement && !this.label) {
        node.classList.remove('haptic-label');
        node.classList.add('chip-label');
        this.#label = node;
      }
    },
    nodeRemoved: node => {
      switch (node) {
        case this.#control:
          this.#controlObserver.disconnect();
          this.#control = null;
          break;
        case this.#label:
          this.#label = null;
      }
    }
  });

  constructor() {
    super();
  }

  connectedCallback() {
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();
  }
}
customElements.define('haptic-chip', HapticChipElement);

class HapticDialogElement extends HTMLDialogElement {
  #form = null;
  #eventListeners = new HapticEventListeners();

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HapticFormElement) {
        if (!this.#form) {
          this.#form = node;
        }
      }
    },
    nodeRemoved: node => {
      switch (node) {
        case this.#form:
          this.#form = null;
      }
    }
  })

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-dialog');

    // command="request-close"
    this.#eventListeners.add(this, 'cancel', () => {
      this.#form?.reset();
    })
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();
    this.#eventListeners.removeAll();
  }
}
customElements.define('haptic-dialog', HapticDialogElement, { extends: 'dialog' });

class HapticDropdownElement extends HTMLElement {
  static observedAttributes = ['disabled'];

  #toggleElement = null;
  #popoverElement = null;
  #backdropElement = null;
  #scrollContainer = null;
  #preventFocusVisible = false;
  #lock = new HapticLock(this);
  #eventListeners = new HapticEventListeners();

  #toggleElementObserver = new HapticAttributesObserver(
    this, ['disabled'], ['inline']
  );

  #scrollContainerObserver = new ResizeObserver(
    (entries) => {
      if (this.isOpen()) {
        this.hidePopover({ cancel: true });
      }
    }
  );

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HTMLElement) {
        this.elementAddedCallback(node);
      }
    },
    nodeRemoved: node => {
      if (node instanceof HTMLElement) {
        this.elementRemovedCallback(node);
      }
    }
  });

  constructor() {
    super();
  }

  get disabled() {
    return this.hasAttribute('disabled');
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

  get scrollContainer() {
    return this.#scrollContainer;
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === 'disabled' && newValue !== null) {
      this.removeAttribute('focused');
      this.hidePopover();
    }
  }

  connectedCallback() {
    if (this.#scrollContainer = this.#closestScrollContainer()) {
      this.#scrollContainerObserver.observe(this.#scrollContainer);
    }
    this.#eventListeners.add(this, 'focusout', event => {
      // Cancel popover if the related target isn't contained in this element.
      // When the focus is leaving the page, the popover keeps open.
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
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();
    this.#scrollContainerObserver.disconnect();
    this.#eventListeners.removeAll();
  }

  elementAddedCallback(element) {
    const classList = element.classList;

    if (classList.contains('toggle')) {
      if (!this.#toggleElement) {
        element.classList.add('embedded');

        this.#eventListeners.add(element, 'mousedown', () => {
          this.#preventFocusVisible = true;
        });
        this.#eventListeners.add(element, 'mouseup', () => {
          this.#preventFocusVisible = false;
        });
        this.#eventListeners.add(element, 'focusin', () => {
          if (!this.#preventFocusVisible) {
            this.setAttribute('focused', 'focused');
          }
        });
        this.#eventListeners.add(element, 'focusout', () => {
          this.removeAttribute('focused');
        });
        this.#eventListeners.add(element, 'click', event => {
          if (!this.disabled && !this.locked) {
            if (this.isOpen()) {
              this.hidePopover({ cancel: true });
            } else {
              this.showPopover();
            }
          }
          event.preventDefault();
        });
        this.#toggleElementObserver.observe(element);
        this.#toggleElement = element;
      }
    } else
    if (classList.contains('popover')) {
      if (!this.#popoverElement) {
        this.#popoverElement = element;
      }
    } else
    if (classList.contains('backdrop')) {
      if (!this.#backdropElement) {
        this.#eventListeners.add(element, 'click', event => {
          this.hidePopover({ cancel: true });
          event.preventDefault();
        });
        this.#backdropElement = element;
      }
    }
  }

  elementRemovedCallback(element) {
    switch (element) {
      case this.#toggleElement:
        this.#eventListeners.remove(element);
        this.#toggleElementObserver.disconnect();
        this.#toggleElement = null;
        break;
      case this.#popoverElement:
        this.#popoverElement = null;
        break;
      case this.#backdropElement:
        this.#eventListeners.remove(element);
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

  focus(options = {}) {
    if (this.toggleElement) {
      if (options.focusVisible === false) {
        this.#preventFocusVisible = true;
        this.toggleElement.focus();
        this.#preventFocusVisible = false;
      } else {
        this.toggleElement.focus();
        this.setAttribute('focused', 'focused');
      }
    }
  }

  cancel() {
  }

  #closestScrollContainer() {
    let element = this;
    while (true) {
      if (element = element.parentElement) {
        if (element.tagName === 'BODY' ||
            getComputedStyle(element).overflowY !== 'visible') {
          return element;
        }
      } else {
        return null;
      }
    }
  }
}
customElements.define('haptic-dropdown', HapticDropdownElement);

class HapticDropdownDialogElement extends HapticDropdownElement {
  #fields = new Set();
  #resetButtons = new Set();
  #eventListeners = new HapticEventListeners();

  constructor() {
    super();
  }

  get openToTop() {
    return this.hasAttribute('open-to-top');
  }

  set openToTop(value) {
    if (value) {
      this.setAttribute('open-to-top', 'open-to-top');
    } else {
      this.removeAttribute('open-to-top');
    }
    return value;
  }

  connectedCallback() {
    super.connectedCallback();

    this.#eventListeners.add(this, 'keydown', event => {
      if (!this.disabled && !this.locked && !this.isOpen()) {
        if (event.key === 'ArrowDown') {
          event.preventDefault();
        }
      }
    });
    this.#eventListeners.add(this, 'keyup', event => {
      if (!this.disabled && !this.locked && !this.isOpen()) {
        if (event.key === 'ArrowDown') {
          this.showPopover();
          event.preventDefault();
        }
      }
    });
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    this.#eventListeners.removeAll();
  }

  elementAddedCallback(element) {
    super.elementAddedCallback(element);

    if ('reset' in element) {
      this.#fields.add(element);
    } else
    if (element.type === 'reset') {
      this.#eventListeners.add(element, 'click', event => {
        if (!this.disabled && !this.locked) {
          this.hidePopover({ reset: true });
          event.preventDefault();
          event.stopPropagation();
        }
      });
      this.#resetButtons.add(element);
    }
  }

  elementRemovedCallback(element) {
    if (this.#fields.has(element)) {
      this.#fields.remove(element);
    } else
    if (this.#resetButtons.has(element)) {
      this.#eventListeners.remove(element);
      this.#resetButtons.remove(element);
    }
    super.elementRemovedCallback(element);
  }

  cancel() {
    for (let field of this.#fields) {
      field.reset();
    }
  }
}
customElements.define('haptic-dropdown-dialog', HapticDropdownDialogElement);

class HapticDropdownMenuElement extends HapticDropdownElement {
  #menuElement = null;
  #eventListeners = new HapticEventListeners();

  constructor() {
    super()
  }

  connectedCallback() {
    super.connectedCallback();

    this.#eventListeners.add(this, 'keydown', event => {
      if (this.#menuElement && !this.disabled && !this.locked) {
        const key = event.key;

        if (key === 'ArrowDown' || key === 'ArrowUp') {
          event.preventDefault();
        }
      }
    });
    this.#eventListeners.add(this, 'keyup', event => {
      if (this.#menuElement && !this.disabled && !this.locked) {
        const key = event.key;

        if (key === 'ArrowDown' || key === 'ArrowUp') {
          if (!this.isOpen()) {
            this.showPopover();
          }
          if (!this.#menuElement.focused) {
            if (key === 'ArrowDown') {
              this.#menuElement.focusFirst();
            } else
            if (key === 'ArrowUp') {
              this.#menuElement.focusLast();
            }
            this.#menuElement.skipNextMouseEvent();
          }
          event.preventDefault();
        }
      }
    });
  }

  disconnectedCallback() {
    super.disconnectedCallback();
    this.#eventListeners.removeAll();
  }

  showPopover() {
    this.#menuElement.reset();
    super.showPopover();
  }

  elementAddedCallback(element) {
    super.elementAddedCallback(element);

    if (element instanceof HapticMenuElement) {
      if (!this.#menuElement) {
        this.#menuElement = element;
      }
    } else
    if (element instanceof HapticMenuItemElement) {
      this.#eventListeners.add(element, 'click', () => {
        this.hidePopover();
      });
    }
  }

  elementRemovedCallback(element) {
    if (element === this.#menuElement) {
      this.#menuElement = null;
    } else
    if (element instanceof HapticMenuItemElement) {
      this.#eventListeners.remove(element);
    }
    super.elementRemovedCallback(element);
  }
}
customElements.define('haptic-dropdown-menu', HapticDropdownMenuElement);

class HapticSelectDropdownElement extends HapticDropdownElement {
  #inputElement = null;
  #popoverScrollContainer = null;
  #optionElements = [];
  #skipNextMouseEvent = false;
  #keyboardInput = '';
  #keyboardInputTimeoutId = null;
  #maxSize = null;
  #optionHeight = null;
  #eventListeners = new HapticEventListeners();

  #inputElementObserver = new HapticAttributesObserver(
    this, ['disabled', 'locked', 'required']
  );

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
      if (!this.disabled && !this.locked) {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
        } else
        if (this.#optionElements.length > 0) {
          let newHighlightedIndex = null;
          let backward = false;

          switch (event.key) {
            case 'ArrowDown':
              if (this.isOpen()) {
                if (this.#highlightedIndex >= 0) {
                  newHighlightedIndex = this.#highlightedIndex + 1;
                }
              } else {
                this.showPopover();
              }
              if (newHighlightedIndex === null) {
                newHighlightedIndex = this.#maxSize ? this.#scrollOffset : 0;
                this.#skipNextMouseEvent = true;
              }
              event.preventDefault();
              break;
            case 'ArrowUp':
              if (this.isOpen()) {
                if (this.#highlightedIndex >= 0) {
                  newHighlightedIndex = this.#highlightedIndex - 1;
                  this.#skipNextMouseEvent = true;
                }
              } else {
                this.showPopover();
              }
              if (newHighlightedIndex === null) {
                newHighlightedIndex = (
                  this.#maxSize ? Math.min(
                    this.#scrollOffset + this.#maxSize,
                    this.#optionElements.length
                  ) : this.#optionElements.length
                ) - 1;
              }
              backward = true;
              event.preventDefault();
              break;
            case 'End':
              if (this.isOpen()) {
                newHighlightedIndex = this.#optionElements.length - 1;
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
              if (this.#popoverScrollContainer && this.isOpen()) {
                let scrollOffset = this.#scrollOffset;

                if (scrollOffset + this.#maxSize >= this.#optionElements.length) {
                  if (this.#highlightedIndex >= 0) {
                    newHighlightedIndex = this.#optionElements.length - 1;
                    backward = true;
                  }
                } else {
                  const highlightedOffset = this.#highlightedIndex - scrollOffset;

                  scrollOffset = this.#scrollOffset = scrollOffset + this.#maxSize;

                  if (highlightedOffset >= 0) {
                    newHighlightedIndex = scrollOffset + highlightedOffset;
                  }
                  this.#skipNextMouseEvent = true;
                }
                event.preventDefault();
              }
              break;
            case 'PageUp':
              if (this.#popoverScrollContainer && this.isOpen()) {
                let scrollOffset = this.#scrollOffset;

                if (scrollOffset === 0) {
                  if (this.#highlightedIndex >= 0) {
                    newHighlightedIndex = 0;
                  }
                } else {
                  const highlightedOffset = this.#highlightedIndex - scrollOffset;

                  scrollOffset = this.#scrollOffset = this.#scrollOffset - this.#maxSize;

                  if (highlightedOffset >= 0) {
                    newHighlightedIndex = scrollOffset + highlightedOffset;
                  }
                  this.#skipNextMouseEvent = true;
                }
                event.preventDefault();
              }
              break;
          }
          if (newHighlightedIndex !== null) {
            while (newHighlightedIndex >= 0 && newHighlightedIndex < this.#optionElements.length) {
              if (this.#optionElements[newHighlightedIndex]?.disabled) {
                newHighlightedIndex = newHighlightedIndex + (backward ? -1 : 1);
              } else {
                this.#highlightedIndex = newHighlightedIndex;
                this.#scrollTo(newHighlightedIndex);
                break;
              }
            }
          }
        }
      }
    });
    this.#eventListeners.add(this, 'keyup', event => {
      if (!this.disabled && !this.locked) {
        if (event.key === 'Enter' || event.key === ' ') {
          if (this.isOpen()) {
            if (event.key === ' ' && this.#keyboardInput.length >= 1) {
              this.#appendToKeyboardInput(event.key);
            } else {
              if (this.#highlightedOptionElement) {
                for (let optionElement of this.#optionElements) {
                  optionElement.checked = optionElement.highlighted;
                }
                if (this.#refresh()) {
                  this.dispatchEvent(new Event('change'));
                }
              }
              this.focus();
              this.hidePopover();
            }
          } else
          if (this.#optionElements.length > 0) {
            this.showPopover();
            this.#skipNextMouseEvent = true;
          }
          event.preventDefault();
        } else {
          if (this.isOpen() && event.key.length === 1) {
            this.#appendToKeyboardInput(event.key);
            event.preventDefault();
          }
        }
      }
    });
    if (this.form instanceof HapticFormElement) {
      this.form.controlAdded(this);
    }
    super.connectedCallback();
  }

  disconnectedCallback() {
    if (this.form instanceof HapticFormElement) {
      this.form.controlRemoved(this);
    }
    super.disconnectedCallback();
    this.#eventListeners.removeAll();
  }

  elementAddedCallback(element) {
    super.elementAddedCallback(element);

    if (element instanceof HTMLInputElement) {
      if (!this.#inputElement) {
        element.classList.add('embedded');
        this.#inputElementObserver.observe(element);
        this.#inputElement = element;
      }
    } else
    if (element instanceof HapticOptionElement) {
      this.#eventListeners.add(element, 'click', event => {
        if (!event.target.disabled) {
          this.#optionElements.forEach(optionElement => {
            optionElement.checked = optionElement === event.target;
          });
          this.focus({ focusVisible: false });
          this.hidePopover();

          if (this.#refresh()) {
            this.dispatchEvent(new Event('change'));
          }
        }
      });
      this.#eventListeners.add(element, 'mouseover', event => {
        if (!event.target.disabled) {
          if (this.#skipNextMouseEvent) {
            this.#skipNextMouseEvent = false;
          } else {
            this.#optionElements.forEach(optionElement => {
              optionElement.highlighted = optionElement === event.target;
            });
          }
        }
      });
      this.#eventListeners.add(element, 'mouseout', event => {
        if (!event.target.disabled) {
          event.target.highlighted = false;
        }
      });
      this.#optionElements.push(element);
    } else
    if (element.classList.contains('scroll-container')) {
      if (!this.#popoverScrollContainer) {
        // Explicitly set tabIndex to -1 to prevent focussing the scroller
        // in Chrome.
        element.tabIndex = -1;
        this.#popoverScrollContainer = element;
      }
    } else
    if (element.classList.contains('backdrop')) {
      if (this.#optionElements.length > 0) {
        if (!this.#checkedOptionElement) {
          for (let optionElement of this.#optionElements) {
            if (!optionElement.disabled) {
              optionElement.checked = true;
              optionElement.initiallyChecked = true;
              break;
            }
          }
        }
        this.#refresh();
      }
    }
  }

  elementRemovedCallback(element) {
    if (element === this.#inputElement) {
      this.#inputElementObserver.disconnect();
      this.#inputElement = null;
    } else
    if (element === this.#popoverScrollContainer) {
      this.#popoverScrollContainer = null;
    } else
    if (element instanceof HapticOptionElement) {
      const index = this.#optionElements.indexOf(element);

      if (index >= 0 && index < this.optionElements.length) {
        this.#eventListeners.remove(element);
        this.#optionElements.splice(index, 1);
      }
    }
    super.elementRemovedCallback(element);
  }

  showPopover() {
    if (this.#optionElements.length > 0) {
      super.showPopover();

      this.#optionHeight = Math.max(
        this.#optionElements[0].getBoundingClientRect().height, 24
      );
      if (this.toggleElement && this.scrollContainer) {
        const toggleRect = this.toggleElement.getBoundingClientRect();
        const scrollRect = this.scrollContainer.getBoundingClientRect();

        const spaceBefore = toggleRect.top - scrollRect.top;
        const spaceAfter = scrollRect.bottom - toggleRect.bottom;

        this.#openToTop = spaceBefore > spaceAfter &&
          this.#optionElements.length * this.#optionHeight + 12 > spaceAfter;

        const space = (this.#openToTop ? spaceBefore : spaceAfter) - 12;
        this.#maxSize = Math.max(Math.floor(space / this.#optionHeight, 0));
      } else {
        this.#openToTop = false;
        this.#maxSize = null;
      }
      if (this.#popoverScrollContainer) {
        this.#popoverScrollContainer.style.maxHeight = this.#maxSize !== null ?
          `${this.#maxSize * this.#optionHeight}px` : null;
      }
      for (let i = 0; i < this.#optionElements.length; i++) {
        if (this.#optionElements[i].checked) {
          this.#scrollTo(i);
          break;
        }
      }
    }
  }

  cancel() {
    this.#optionElements.forEach(optionElement => {
      optionElement.highlighted = false;
    });
  }

  reset() {
    this.#optionElements.forEach(optionElement => {
      optionElement.reset();
    });
    this.#refresh();
  }

  refreshInitialValue() {
    this.#optionElements?.forEach(optionElement => {
      optionElement.initiallyChecked = optionElement.checked;
    });
  }

  get #checkedOptionElement() {
    for (let optionElement of this.#optionElements) {
      if (optionElement.checked) {
        return optionElement;
      }
    }
    return null;
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
      if (!this.#optionElements[i].disabled) {
        this.#optionElements[i].highlighted = (i === index);
      }
    }
    return index;
  }

  get #highlightedOptionElement() {
    for (let optionElement of this.#optionElements) {
      if (optionElement.highlighted) {
        return optionElement;
      }
    }
    return null;
  }

  get #openToTop() {
    return this.hasAttribute('open-to-top');
  }

  set #openToTop(value) {
    if (value) {
      this.setAttribute('open-to-top', 'open-to-top');
    } else {
      this.removeAttribute('open-to-top');
    }
    return value;
  }

  get #scrollOffset() {
    if (this.#popoverScrollContainer) {
      return Math.floor(this.#popoverScrollContainer.scrollTop / this.#optionHeight);
    } else {
      return 0;
    }
  }

  set #scrollOffset(value) {
    if (this.#popoverScrollContainer) {
      value = Math.min(value, this.#optionElements.length - this.#maxSize);
      value = Math.max(value, 0);

      this.#popoverScrollContainer.scrollTop = value * this.#optionHeight;
      return value;
    } else {
      return 0;
    }
  }

  #appendToKeyboardInput(str) {
    if (this.#optionElements.length > 0) {
      if (this.#keyboardInputTimeoutId) {
        clearTimeout(this.#keyboardInputTimeoutId);
        this.#keyboardInputTimeoutId = null;
      }
      this.#keyboardInput = this.#keyboardInput + str.toLowerCase();
      const keyboardInput = this.#keyboardInput;

      if (!this.#highlightedOptionElement?.textStartsWith(keyboardInput)) {
        for (let i = 0; i < this.#optionElements.length; i++) {
          const optionElement = this.#optionElements[i];

          if (!optionElement.disabled && optionElement.textStartsWith(keyboardInput)) {
            this.#highlightedIndex = i;
            break;
          }
        }
      }
      this.#keyboardInputTimeoutId = setTimeout(
        () => {
          this.#keyboardInput = '';
          this.#keyboardInputTimeoutId = null;
        },
        1000
      );
    }
  }

  #refresh() {
    const checkedOptionElement = this.#checkedOptionElement;
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

  #scrollTo(index) {
    if (this.#popoverScrollContainer) {
      const scrollOffset = this.#scrollOffset;
      let newScrollOffset = null;

      if (index < scrollOffset) {
        newScrollOffset = index;
      } else
      if (index > scrollOffset + this.#maxSize - 1) {
        newScrollOffset = index - this.#maxSize + 1;
      }
      if (newScrollOffset !== null) {
        this.#scrollOffset = newScrollOffset;
      }
      return newScrollOffset;
    } else {
      return 0;
    }
  }
}
customElements.define('haptic-select-dropdown', HapticSelectDropdownElement);

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

  textStartsWith(str) {
    return this.innerText.toLowerCase().startsWith(str);
  }
}
customElements.define('haptic-option', HapticOptionElement);

class HapticFieldElement extends HTMLElement {
  static ICON_NAMES = ['error', 'leading', 'trailing'];

  #control = null;
  #label = null;
  #setValidOnChange = null;
  #preventFocusVisible = false;
  #eventListeners = new HapticEventListeners();

  #controlObserver = new HapticAttributesObserver(
    this,
    ['disabled', 'focused', 'locked', 'required'],
    ['inline']
  );

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HTMLElement && this.#isParentFieldOf(node)) {
        this.elementAddedCallback(node);
      }
    },
    nodeRemoved: node => {
      if (node instanceof HTMLElement) {
        this.elementRemovedCallback(node);
      }
    }
  });

  constructor() {
    super();
  }

  get control() {
    return this.#control;
  }

  set control(element) {
    if (this.#control) {
      this.removeAttribute('disabled');
      this.removeAttribute('invalid');
      this.removeAttribute('required');
      this.#eventListeners.remove(this.#control);
      this.#controlObserver.disconnect();
      this.#control = null;
    }
    if (element) {
      if (element instanceof HTMLButtonElement ||
          element instanceof HTMLInputElement ||
          element instanceof HTMLTextAreaElement ||
          element instanceof HTMLSelectElement) {
        this.#eventListeners.add(element, 'focusin', event => {
          if (this.#focusIndicator === 'focus' ||
              (this.#focusIndicator === 'focus-visible' &&
              !this.#preventFocusVisible)) {
            this.focusinCallback(event);
          }
        });
        this.#eventListeners.add(element, 'focusout', event => {
          this.focusoutCallback(event);
        });
        this.#eventListeners.add(element, 'mousedown', () => {
          this.#preventFocusVisible = true;
        });
        this.#eventListeners.add(element, 'mouseup', () => {
          this.#preventFocusVisible = false;
        });
      }
      this.#eventListeners.add(element, 'change', () => {
        this.#setValidOnChange?.forEach(fieldId => {
          const field = fieldId == 'itself' ? this :
            this.#control?.form?.querySelector(`[for="${fieldId}"]`);

          if (field && 'valid' in field) {
            field.valid = true;
          }
        });
      });
      this.#controlObserver.observe(element);
      this.#control = element;
    }
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

  get #focusIndicator() {
    return this.getAttribute('focus-indicator');
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
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();
    this.#controlObserver.disconnect();
    this.#eventListeners.removeAll();
  }

  elementAddedCallback(element) {
    const classList = element.classList;

    if (classList.contains('haptic-field')) {
      if (!this.control) {
        this.control = element;
      }
    } else
    if (classList.contains('field-label')) {
      if (!this.#label) {
        classList.add('embedded');
        this.setAttribute('with-label', '');
        this.#label = element;
      }
    } else
    for (let iconName of HapticTextFieldElement.ICON_NAMES) {
      if (classList.contains(`${iconName}-icon`)) {
        if (iconName != 'error' || !this.valid) {
          this.setAttribute(`with-${iconName}-icon`, '');
        }
      }
    }
  }

  elementRemovedCallback(element) {
    switch (element) {
      case this.control:
        this.control = null;
        break;
      case this.#label:
        element.classList.remove('embedded');
        this.removeAttribute('with-label');
        this.#label = null;
        break;
      default:
        for (let iconName of HapticFieldElement.ICON_NAMES) {
          if (element.classList.contains(`${iconName}-icon`)) {
            if (!this.querySelector(`${iconName}-icon`)) {
              this.removeAttribute(`with-${iconName}-icon`);
            }
          }
        }
    }
  }

  focusinCallback(event) {
    this.setAttribute('focused', '');
  }

  focusoutCallback(event) {
    this.removeAttribute('focused');
  }

  focus(options = {}) {
    if (this.#control) {
      if (options.focusVisible === false ) {
        this.#preventFocusVisible = true;
        try {
          this.#control.focus();
        } finally {
          this.#preventFocusVisible = false;
        }
      } else {
        this.#control.focus(options);
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

  elementAddedCallback(element) {
    if (element instanceof HapticDropdownElement ||
        element instanceof HTMLSelectElement) {
      this.control ||= element;
    }
    super.elementAddedCallback(element);
  }
}
customElements.define('haptic-dropdown-field', HapticDropdownFieldElement);

class HapticTextFieldElement extends HapticFieldElement {
  #clearButton = null;
  #clearButtonPressed = false;
  #eventListeners = new HapticEventListeners();

  constructor() {
    super([]);
  }

  connectedCallback() {
    this.setAttribute('empty', '');
    super.connectedCallback();
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
    super.disconnectedCallback();
  }

  elementAddedCallback(element) {
    if (element instanceof HTMLInputElement ||
        element instanceof HTMLTextAreaElement) {
      if (!this.control) {
        this.#eventListeners.add(element, 'change', event => {
          if (this.#clearButtonPressed) {
            event.preventDefault();
            event.stopPropagation();
          }
        }, { capture: true });

        this.#eventListeners.add(element, 'change', () => {
          this.#refresh();
        });
        this.#eventListeners.add(element, 'input', () => {
          this.#refresh();
        });

        if (element instanceof HapticTextAreaElement) {
          if (!element.hasAttribute('rows')) {
            element.setAttribute('rows', 1);
          }
        }
        this.control = element;
        this.#refresh();
      }
    } else
    if (element.classList.contains('clear-button')) {
      if (!this.#clearButton) {
        element.tabIndex = -1;
        this.setAttribute('with-clear-button', '');

        this.#eventListeners.add(element, 'click', event => {
          const control = this.control;
          if (control) {
            if (control.value != '') {
              control.value = '';
              control.dispatchEvent(new Event('input'));
            }
            this.focus({ focusVisible: false });
          }
          event.preventDefault();
        });
        this.#eventListeners.add(element, 'mousedown', () => {
          this.#clearButtonPressed = true;
        });
        this.#eventListeners.add(element, 'mouseup', () => {
          this.#clearButtonPressed = false;
        });
        this.#clearButton = element;
      }
    }
    super.elementAddedCallback(element);
  }

  elementRemovedCallback(element) {
    switch (element) {
      case this.control:
        this.#eventListeners.remove(element);
        this.setAttribute('empty', '');
        break;
      case this.#clearButton:
        this.#eventListeners.remove(element);
        this.removeAttribute('with-clear-button');
        this.#clearButton = null;
    }
    super.elementRemovedCallback(element);
  }

  focusoutCallback(event) {
    if (event.relatedTarget !== this.#clearButton) {
      this.removeAttribute('focused');
    }
  }

  #refresh() {
    const control = this.control;

    if (control) {
      const value = control.value;

      if (value == null || value.length == 0) {
        this.setAttribute('empty', '');
      } else {
        this.removeAttribute('empty');
      }
      if (control instanceof HapticTextAreaElement) {
        control.resize();
      }
    }
  }
}
customElements.define('haptic-text-field', HapticTextFieldElement);

class HapticFormElement extends HTMLFormElement {
  #controls = new Set();
  #requiredFields = new Set();
  #resetButtons = new Set();
  #submitButtons = new Set();
  #isSubmitting = false;
  #eventListeners = new HapticEventListeners();

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

  set #locked(value) {
    for (let control of this.#controls) {
      if ('locked' in control) {
        control.locked = value;
      }
    }
    return value;
  }

  connectedCallback() {
    this.classList.add('haptic-form');

    this.addEventListener('submit', event => {
      if (this.getAttribute('data-turbo') === 'true') {
        this.startSubmitting({ submit: false });

        const listener = () => {
          document.removeEventListener('turbo:submit-end', listener);
          this.#locked = false;
          this.#isSubmitting = false;
        }
        document.addEventListener('turbo:submit-end', listener);
      } else {
        this.startSubmitting({ submit: true });
        event.preventDefault();
      }
    });
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
  }

  controlAdded(control) {
    this.#controls.add(control);

    if ((control instanceof HapticButtonElement ||
         control instanceof HapticInputElement)) {
      switch (control.type) {
        case 'reset':
          this.#eventListeners.add(control, 'click', () => {
            this.reset();
          });
          this.#resetButtons.add(control);
          break;
        case 'submit':
          this.#submitButtons.add(control);
          this.#refresh();
      }
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
    if (this.#resetButtons.has(control)) {
      this.#eventListeners.remove(control);
      this.#resetButtons.delete(control);
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
    this.startSubmitting({ submit: true });
  }

  startSubmitting(options = {}) {
    this.tryStartSubmitting(() => {
      setTimeout(() => {
        if (this.#isSubmitting) {
          this.busy = true;
        }
      }, 400);

      if (options.submit) {
        super.submit();
      }
    });
  }


  tryStartSubmitting(func) {
    if (!this.#isSubmitting) {
      this.#isSubmitting = true;
      this.#locked = true;

      func(() => {
        this.#locked = false;
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
        this.startSubmitting({ submit: true, changeEvent: event });
      }
    }, { capture: true });
  }

  controlRemoved(control) {
    this.#eventListeners.remove(control);
    super.controlRemoved(control);
  }

  startSubmitting(options = {}) {
    this.tryStartSubmitting(submittingFinished => {
      this.busy = true;

      if (options.submit) {
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
            options.changeEvent?.target?.dispatchEvent(changeEvent);
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
      }
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

class HapticGridElement extends HTMLElement {
  #elements = [];
  #eventListeners = new HapticEventListeners();

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HapticButtonElement ||
          node instanceof HapticInputElement) {
        this.#elements.push(new HapticFocusable(node));
      }
    },
    nodeRemoved: node => {
      for (let i = 0; i < this.#elements.length; i++) {
        if (this.#elements[i].target === element) {
          this.#elements[i].disconnect();
          this.#elements.splice(i, 1);
          break;
        }
      }
    }
  });

  get #focusedIndex() {
    for (let i = 0; i < this.#elements.length; i++) {
      if (this.#elements[i].focused) {
        return i;
      }
    }
    return -1;
  }

  set #focusedIndex(index) {
    for (let i = 0; i < this.#elements.length; i++) {
      const element = this.#elements[i];

      if (i != index) {
        element.focused = false;
      } else
      if (!element.focused) {
        element.focused = true;
        this.#scrollIntoView(element.target);
      }
    }
    return index;
  }

  get #scrollContainers() {
    let scrollContainerX = null, scrollContainerY = null;

    for (let element = this; element; element = element.parentElement) {
      const style = getComputedStyle(element);

      if (style.overflowX !== 'visible' || element.tagName === 'BODY') {
        scrollContainerX ||= element;
      }
      if (style.overflowY !== 'visible' || element.tagName === 'BODY') {
        scrollContainerY ||= element;
      }
      if (scrollContainerX !== null && scrollContainerY !== null) {
        break;
      }
    }
    return { x: scrollContainerX, y: scrollContainerY }
  }

  get #size() {
    const columns = window.getComputedStyle(this)
      .gridTemplateColumns.split(' ').length;

    return {
      columns: columns,
      rows: Math.ceil(this.#elements.length / columns)
    };
  }

  constructor() {
    super();
  }

  connectedCallback() {
    this.tabIndex = Math.max(this.tabIndex, 0);

    this.#eventListeners.add(this, 'keydown', event => {
      let focusedIndex = null, form = null;

      switch(event.key) {
        case 'Enter':
          if (form = this.closest('form')) {
            form.requestSubmit();
            event.preventDefault();
            break;
          }
        case ' ':
          focusedIndex = this.#focusedIndex;

          if (focusedIndex >= 0 && focusedIndex < this.#elements.length) {
            this.#elements[focusedIndex].target.click();
            event.preventDefault();
          }
          break;
        case 'ArrowDown':
        case 'ArrowLeft':
        case 'ArrowRight':
        case 'ArrowUp': {
          focusedIndex = this.#focusedIndex;
          const size = this.#size;

          switch(event.key) {
            case 'ArrowLeft': {
              const firstElementInRowIndex = Math.floor(
                focusedIndex / size.columns
              ) * size.columns;

              for (let i = focusedIndex - 1; i >= firstElementInRowIndex; i--) {
                if (!this.#elements[i].disabled) {
                  focusedIndex = i;
                  break;
                }
              }
              break;
            }
            case 'ArrowRight': {
              const lastElementInRowIndex = Math.min(
                (Math.floor(focusedIndex / size.columns) + 1) * size.columns - 1,
                this.#elements.length - 1
              );
              for (let i = focusedIndex + 1; i <= lastElementInRowIndex; i++) {
                if (!this.#elements[i].disabled) {
                  focusedIndex = i;
                  break;
                }
              }
              break;
            }
            case 'ArrowUp': {
              for (let i = focusedIndex - size.columns; i >= 0; i -= size.columns) {
                if (!this.#elements[i].disabled) {
                  focusedIndex = i;
                  break;
                }
              }
              break;
            }
            case 'ArrowDown': {
              for (let i = focusedIndex + size.columns;
                   i < this.#elements.length;
                   i += size.columns) {
                if (!this.#elements[i].disabled) {
                  focusedIndex = i;
                  break;
                }
              }
            }
          }
          if (focusedIndex >= 0 && focusedIndex < this.#elements.length) {
            this.#focusedIndex = focusedIndex;
          }
          event.preventDefault();
        }
      }
    });
    this.#eventListeners.add(this, 'focusin', () => {
      if (this.#focusedIndex == -1) {
        for (let i = 0; i < this.#elements.length; i++) {
          const element = this.#elements[i];

          if (!element.disabled) {
            element.focused = true;
            break;
          }
        }
      }
    });
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();
    this.#eventListeners.removeAll();

    for (let element of this.#elements) {
      element.disconnect();
    }
  }

  #scrollIntoView(element) {
    const scrollContainers = this.#scrollContainers;

    if (element && (scrollContainers.x || scrollContainers.y)) {
      const elementRect = element.getBoundingClientRect();
      let container = null, containerRect = null;

      if (container = scrollContainers.x) {
        containerRect = container.getBoundingClientRect();

        if (elementRect.left < containerRect.left) {
          container.scrollLeft -= containerRect.left - elementRect.left;
        } else
        if (elementRect.right > containerRect.right) {
          container.scrollLeft += containerRect.right - scrollRect.right;
        }
      }
      if (container = scrollContainers.y) {
        containerRect = container.getBoundingClientRect();

        if (elementRect.top < containerRect.top) {
          container.scrollTop -= containerRect.top - elementRect.top;
        } else
        if (elementRect.bottom > containerRect.bottom) {
          container.scrollTop += elementRect.bottom - containerRect.bottom;
        }
      }
    }
  }
}
customElements.define('haptic-grid', HapticGridElement);

class HapticInputElement extends HTMLInputElement {
  static observedAttributes = ['disabled'];

  #initialValue = null;
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
    const classList = this.classList;

    switch (this.type) {
      case 'submit':
        classList.add('haptic-button');
        break;
      case 'checkbox':
        if (!classList.contains('haptic-switch') &&
            !classList.contains('chip-checkbox')) {
          classList.add('haptic-checkbox');
        }
        this.#initialValue = this.checked;
        break;
      case 'radio':
        if (!classList.contains('button-segment-radio-button')) {
          classList.add('haptic-radio-button');
        }
        this.#initialValue = this.checked;
        break;
      default:
        classList.add('haptic-field');
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
    const classList = this.classList;

    if (!classList.contains('button-segment-label') &&
        !classList.contains('chip-label') &&
        !classList.contains('field-label')) {
      classList.add('haptic-label');
    }
  }
}
customElements.define('haptic-label', HapticLabelElement, { extends: 'label' });

class HapticListElement extends HTMLElement {
  #listItemElements = new Set();
  #eventListeners = new HapticEventListeners();
  #navigationController = new HapticNavigationController({ vertical: true });

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HapticListItemElement) {
        this.#eventListeners.add(node, 'change', () => {
          this.dispatchEvent(new Event('change'));
        });
        this.#listItemElements.add(node);
      } else
      if (node instanceof HTMLInputElement) {
        this.#navigationController.add(node);
      }
    },
    nodeRemoved: node => {
      if (this.#listItemElements.has(node)) {
        this.#eventListeners.remove(node);
        this.#listItemElements.remove(node);
      } else
      if (node instanceof HTMLInputElement) {
        this.#navigationController.remove(node);
      }
    }
  });

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
    this.tabIndex = Math.max(this.tabIndex, 0);
    this.#navigationController.connect(this);
    this.#childNodesObserver.observe(this);

    if (this.form instanceof HapticFormElement) {
      this.form.controlAdded(this);
    }
  }

  disconnectedCallback() {
    if (this.form instanceof HapticFormElement) {
      this.form.controlRemoved(this);
    }
    this.#childNodesObserver.disconnect();
    this.#navigationController.disconnect();
    this.#eventListeners.removeAll();
  }
}
customElements.define('haptic-list', HapticListElement);

class HapticListItemElement extends HTMLElement {
  #control = null;
  #eventListeners = new HapticEventListeners();

  #controlObserver = new HapticAttributesObserver(this, ['disabled']);

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HTMLInputElement && !this.#control) {
        node.classList.add('embedded');

        if (node.classList.contains('haptic-switch')) {
          this.setAttribute('control-type', 'switch');
        } else
        if (node.type === 'checkbox') {
          this.setAttribute('control-type', 'checkbox');
        } else
        if (node.type === 'radio') {
          this.setAttribute('control-type', 'radio-button');
        }
        this.#eventListeners.add(node, 'change', () => {
          this.dispatchEvent(new Event('change'));
        });
        this.#controlObserver.observe(node);
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
  });

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
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();
    this.#eventListeners.removeAll();
  }
}
customElements.define('haptic-list-item', HapticListItemElement);

class HapticMenuElement extends HTMLElement {
  #navigationController = new HapticNavigationController({
    mouse: true,
    vertical: true
  });

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HTMLElement) {
        if (node instanceof HapticMenuItemElement) {
          this.#navigationController.add(node);
        } else
        if (node.classList.contains('leading-icon')) {
          this.setAttribute('with-leading-icons', '');
        } else
        if (node.classList.contains('trailing-icon')) {
          this.setAttribute('with-trailing-icons', '');
        }
      }
    },
    nodeRemoved: node => {
      if (node instanceof HapticMenuItemElement) {
        this.#navigationController.remove(node);
      }
    }
  });

  constructor() {
    super();
  }

  connectedCallback() {
    this.tabIndex = Math.max(this.tabIndex, 0);
    this.classList.add('haptic-menu');

    this.#navigationController.connect(this);
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#navigationController.disconnect();
    this.#childNodesObserver.disconnect();
  }

  focusFirst() {
    this.#navigationController.focusFirst();
    this.focus();
  }

  focusLast() {
    this.#navigationController.focusLast();
    this.focus();
  }

  skipNextMouseEvent() {
    this.#navigationController.skipNextMouseEvent();
  }

  reset() {
    this.#navigationController.reset();
  }
}
customElements.define('haptic-menu', HapticMenuElement);

class HapticMenuItemElement extends HTMLAnchorElement {
  constructor() {
    super();
  }

  get disabled() {
    return this.hasAttribute('data-disabled');
  }

  set disabled(value) {
    if (value) {
      this.setAttribute('data-disabled', '');
    } else {
      this.removeAttribute('data-disabled');
    }
    return value;
  }

  connectedCallback() {
    this.classList.add('menu-item');
  }
}
customElements.define('haptic-menu-item', HapticMenuItemElement, { extends: 'a' });

class HapticNavElement extends HTMLElement {
  #navItemElements = new Set();
  #eventListeners = new HapticEventListeners();
  #navigationController = new HapticNavigationController({ vertical: true });

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HTMLElement) {
        if (node instanceof HapticNavItemElement) {
          this.#navigationController.add(node);
          this.#navItemElements.add(node);
        } else
        if (node.classList.contains('leading-icon')) {
          this.setAttribute('with-leading-icons', '');
        }
      }
    },
    nodeRemoved: node => {
      if (node instanceof HapticNavItemElement) {
        this.#navItemElements.delete(node);
        this.#navigationController.remove(node);
      }
    }
  });

  constructor() {
    super();
  }

  connectedCallback() {
    this.tabIndex = Math.max(this.tabIndex, 0);
    this.classList.add('haptic-nav');

    this.#navigationController.connect(this);
    this.#childNodesObserver.observe(this);

    this.#eventListeners.add(document, 'popstate', () => {
      this.#refresh();
    });
    this.#eventListeners.add(document, 'turbo:visit', event => {
      this.#refresh((new URL(event.detail.url)).pathname);
    });
  }

  disconnectedCallback() {
    this.#eventListeners.removeAll();
    this.#childNodesObserver.disconnect();
    this.#navigationController.disconnect();
  }

  #refresh(pathname = null) {
    for (let navItemElement of this.#navItemElements) {
      navItemElement.refresh(pathname);
    }
  }
}
customElements.define('haptic-nav', HapticNavElement, { extends: 'nav' });

class HapticNavItemElement extends HTMLAnchorElement {
  static observedAttributes = ['active-on', 'href'];

  #regexp = null;

  constructor() {
    super();
  }

  get active() {
    return this.classList.contains('active');
  }

  set active(value) {
    const classList = this.classList;

    if (value && !classList.contains('active')) {
      classList.add('active');
    } else
    if (!value && classList.contains('active')) {
      classList.remove('active');
    }
    return value;
  }

  get activeOn() {
    return this.getAttribute('active-on');
  }

  set activeOn(value) {
    return this.setAttribute('active-on', value);
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue !== null) {
      this.#regexp = null;
      this.refresh();
    }
  }

  connectedCallback() {
    this.classList.add('nav-item');
    this.refresh();
  }

  refresh(pathname = null) {
    if (this.#regexp === null) {
      let regexp = this.activeOn;

      if (regexp === '_pathname') {
        regexp = `^${this.pathname}`;
      }
      this.#regexp = new RegExp(regexp);
    }
    this.active = this.#regexp.test(pathname || window.location.pathname);
  }
}
customElements.define('haptic-nav-item', HapticNavItemElement, { extends: 'a' });

class HapticSelectElement extends HTMLSelectElement {
  static observedAttributes = ['disabled'];

  #initialValue = null;
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

class HapticTableElement extends HTMLTableElement {
  static isInteractiveElement(node) {
    return node instanceof HapticButtonElement ||
      node instanceof HapticInputElement ||
      node instanceof HapticSelectElement ||
      node instanceof HapticSelectDropdownElement;
  }

  #eventListeners = new HapticEventListeners();
  #navigationController = new HapticNavigationController({ vertical: true });

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HapticTableRowElement) {
        if (node.hasAttribute('data-href')) {
          this.tabIndex = Math.max(this.tabIndex, 0);

          if (!this.#navigationController.connected) {
            this.#navigationController.connect(this);
          }
          this.#navigationController.add(node);
        }
      } else
      if (HapticTableElement.isInteractiveElement(node)) {
        this.#eventListeners.add(node, 'focusin', () => {
          this.#navigationController.suspend();
        });
        this.#eventListeners.add(node, 'focusout', () => {
          this.#navigationController.resume();
        });
      }
    },
    nodeRemoved: node => {
      if (node instanceof HTMLTableRowElement) {
        if (this.#navigationController.connected) {
          this.#navigationController.remove(node);
        }
      } else
      if (HapticTableElement.isInteractiveElement(node)) {
        this.#eventListeners.remove(node);
      }
    }
  });

  constructor() {
    super();
  }

  connectedCallback() {
    this.classList.add('haptic-table');
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();

    if (this.#navigationController.connected) {
      this.#navigationController.disconnect();
    }
  }
}
customElements.define('haptic-table', HapticTableElement, { extends: 'table' });

class HapticTableRowElement extends HTMLTableRowElement {
  static observedAttributes = ['data-href'];

  #eventListeners = new HapticEventListeners();

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (HapticTableElement.isInteractiveElement(node)) {
        this.#eventListeners.add(node, 'click', event => {
          event.hapticTableRowHandlerPrevented = true;
        }, { capture: true });
      }
    },
    nodeRemoved: node => {
      if (HapticTableElement.isInteractiveElement(node)) {
        this.#eventListeners.remove(node);
      }
    }
  });

  constructor() {
    super();
  }

  attributeChangedCallback(name, oldValue, newValue) {
    this.#eventListeners.remove(this);

    if (newValue !== null) {
      this.#eventListeners.add(this, 'click', event => {
        if (!event.hapticTableRowHandlerPrevented) {
          if (typeof Turbo !== 'undefined') {
            const options = {};

            const action = this.getAttribute('data-turbo-action');
            if (action) options.action = action;

            const frame = this.getAttribute('data-turbo-frame');
            if (frame) options.frame = frame;

            Turbo.visit(newValue, options);
          } else {
            window.location.href = newValue;
          }
        }
      });
    }
  }

  connectedCallback() {
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();
    this.#eventListeners.removeAll();
  }
}
customElements.define('haptic-table-row', HapticTableRowElement, { extends: 'tr' });

class HapticTableLikeElement extends HTMLElement {
  #navigationController = new HapticNavigationController({ vertical: true });

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HTMLAnchorElement && node.classList.contains('table-row')) {
        this.tabIndex = Math.max(this.tabIndex, 0);

        if (!this.#navigationController.connected) {
          this.#navigationController.connect(this);
        }
        this.#navigationController.add(node);
      }
    },
    nodeRemoved: node => {
      if (node instanceof HTMLAnchorElement) {
        if (this.#navigationController.connected) {
          this.#navigationController.remove(node);
        }
      }
    }
  });

  constructor() {
    super();
  }

  connectedCallback() {
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();

    if (this.#navigationController.connected) {
      this.#navigationController.disconnect();
    }
  }
}
customElements.define('haptic-table-like', HapticTableLikeElement);

class HapticTabsElement extends HTMLElement {
  #tabs = [];
  #tabContents = [];
  #mutationObservers = new Map();
  #eventListeners = new HapticEventListeners();

  #mutationObserverCallback = mutationList => {
    const length = Math.min(this.#tabs.length, this.#tabContents.length);

    for (let mutationRecord of mutationList) {
      for (let i = 0; i < length; i++) {
        if (this.#tabs[i].target === mutationRecord.target) {
          this.#tabContents[i].active = this.#tabs[i].active;
          break;
        }
      }
    }
  }

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HTMLElement) {
        if (node.classList.contains('haptic-tab')) {
          this.#eventListeners.add(node, 'click', event => {
            event.preventDefault();
          });
          const mutationObserver = new MutationObserver(this.#mutationObserverCallback);
          mutationObserver.observe(node, { attributeFilter: ['class'] });
          this.#mutationObservers.set(node, mutationObserver);

          const tab = new HapticActivatable(node);
          const index = this.#tabs.push(tab) - 1;

          if (this.#tabContents.length > index) {
            this.#tabContents[index].active = tab.active;
          }
        } else
        if (node.classList.contains('haptic-tab-content')) {
          const tabContent = new HapticActivatable(node);
          const index = this.#tabContents.push(tabContent) - 1;

          if (this.#tabs.length > index) {
            tabContent.active = this.#tabs[index].active;
          }
        }
      }
    },
    nodeRemoved: node => {
      if (node instanceof HTMLElement) {
        for (let i = 0; i < this.#tabs.length; i++) {
          if (this.#tabs[i] === node) {
            this.#mutationObservers.get(node).disconnect();
            this.#mutationObservers.delete(node);
            this.#eventListeners.remove(node);
            this.#tabs.splice(index, 1);
            return;
          }
        }
        for (let i = 0; i < this.#tabContents.length; i++) {
          if (this.#tabContents[i] === node) {
            this.#tabContents.splice(index, 1);
            return;
          }
        }
      }
    }
  });

  constructor() {
    super();
  }

  connectedCallback() {
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();

    for (let entry of this.#childNodesObserver.entries()) {
      entry.value.disconnect();
    }
    this.#eventListeners.removeAll();
  }
}
customElements.define('haptic-tabs', HapticTabsElement);

class HapticTabBarElement extends HTMLElement {
  #tabElements = new Set();
  #eventListeners = new HapticEventListeners();
  #navigationController = new HapticNavigationController(this);

  #childNodesObserver = new HapticChildNodesObserver({
    nodeAdded: node => {
      if (node instanceof HTMLElement && node.classList.contains('haptic-tab')) {
        this.#eventListeners.add(node, 'click', event => {
          for (let tabElement of this.#tabElements) {
            if (tabElement === event.target) {
              if (!tabElement.classList.contains('active')) {
                tabElement.classList.add('active');
              }
            } else
            if (tabElement.classList.contains('active')) {
              tabElement.classList.remove('active');
            }
          }
        });
        this.#navigationController.add(node);
        this.#tabElements.add(node);
        this.#refresh();
      }
    },
    nodeRemoved: node => {
      if (node instanceof HTMLElement) {
        if (this.#tabElements.remove(node)) {
          this.#navigationController.remove(node);
          this.#eventListeners.remove(node);
          this.#refresh();
        }
      }
    }
  });

  constructor() {
    super();
  }

  connectedCallback() {
    this.tabIndex = Math.max(this.tabIndex, 0);
    this.classList.add('haptic-tab-bar');

    this.#navigationController.connect(this);
    this.#childNodesObserver.observe(this);
  }

  disconnectedCallback() {
    this.#childNodesObserver.disconnect();
    this.#navigationController.disconnect();
    this.#eventListeners.removeAll();
  }

  #refresh() {
    this.style.gridTemplateColumns = `repeat(${this.#tabElements.size}, 1fr)`;
  }
}
customElements.define('haptic-tab-bar', HapticTabBarElement);

class HapticTextAreaElement extends HTMLTextAreaElement {
  #initialValue = null;
  #lock = new HapticLock(this);
  #eventListeners = new HapticEventListeners();

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

Haptic = {
  confirm: {
    cancel: 'Cancel',
    ok: 'Ok',
    show: function(message) {
      return new Promise(resolve => {
        const dialog = document.createElement('dialog');
        dialog.classList.add('haptic-dialog');

        const messageSegment = document.createElement('div');
        messageSegment.classList.add('dialog-segment', 'message');
        messageSegment.appendChild(document.createTextNode(message));
        dialog.appendChild(messageSegment);

        const buttonsSegment = document.createElement('div');
        buttonsSegment.classList.add('dialog-segment', 'buttons');
        dialog.appendChild(buttonsSegment);

        for (let value of [false, true]) {
          const button = document.createElement('button');
          button.classList.add('haptic-button');
          button.value = value ? 'ok' : 'cancel';

          button.appendChild(document.createTextNode(value ? this.ok : this.cancel));
          button.addEventListener('mouseover', () => {
            button.focus();
          });
          button.addEventListener('click', () => {
            dialog.close();
            dialog.remove();
            resolve(value);
          });
          buttonsSegment.appendChild(button);
        }
        document.body.appendChild(dialog);
        dialog.showModal();
        dialog.querySelector(`button[value=ok]`).focus();
      });
    }
  }
}
