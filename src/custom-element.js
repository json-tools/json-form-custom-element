const Elm = require('./JsonFormCustomElement');
const css = require('../../json-form/stylesheets/standalone.css').toString();


function readAttribute(node, name, defValue) {
    if (!node.hasAttribute(name)) {
        return defValue;
    }

    try {
        return JSON.parse(node.getAttribute(name));
    } catch (e) {
        return defValue;
    }
}


customElements.define('json-form',
    class extends HTMLElement {

        static get observedAttributes() {
            return ['value', 'schema', 'config'];
        }

        constructor() {
            super();

            const appRoot = document.createElement('div');
            const appStyles = document.createElement('style');

            const shadowRoot = this.attachShadow({mode: 'open'});
            shadowRoot.appendChild(appStyles);
            shadowRoot.appendChild(appRoot);
            this._appStyles = appStyles;
            this._appRoot = appRoot;

            this._schema = readAttribute(this, 'schema', {});
            this._value = readAttribute(this, 'value', {});
            this._config = readAttribute(this, 'config');
            this._muteAttributeChange = false;

        }

        connectedCallback() {
            const app = Elm.Elm.JsonFormCustomElement.init({
                node: this._appRoot,
                flags: {
                    schema: this._schema,
                    value: this._value,
                    config: this._config
                }
            });
            this.app = app;

            this._appStyles.textContent = this._config && this._config.customCss || css;

            app.ports.valueUpdated.subscribe(({ value, isValid, errors }) => {
                const event = new CustomEvent('change', { detail: { value, isValid, errors } });
                this._muteAttributeChange = true;
                this.setAttribute('value', JSON.stringify(value));
                this.dispatchEvent(event);
            });
        }

        attributeChangedCallback(name, oldValue, newValue) {
            if (this._muteAttributeChange) {
                this._muteAttributeChange = false;
                return;
            }

            if (oldValue === newValue) {
                return;
            }

            switch (name) {
                case 'value':
                    this._value = JSON.parse(newValue);
                    if (this.app) {
                        this.app.ports.valueChange.send(this._value);
                    }
                    break;
                case 'schema':
                    this._schema = JSON.parse(newValue);
                    if (this.app) {
                        this.app.ports.schemaChange.send(this._schema);
                    }
                    break;
                case 'config':
                    this._config = JSON.parse(newValue);
                    if (this.app) {
                        this.app.ports.configChange.send(this._config);
                    }
                    break;
            }
        }
});
