# json-form-custom-element
https://www.webcomponents.org/element/json-form-custom-element

<!---
```
<custom-element-demo>
  <template>
    <script src="../webcomponentsjs/webcomponents-lite.js"></script>
    <link rel="stylesheet" href="https://unpkg.com/@ubio/css@1.3.11/index.css">
    <link rel="import" href="json-form.html">
    <next-code-block></next-code-block>
  </template>
</custom-element-demo>
```
-->
```html
<json-form
    schema='{"type":"string","title":"Hello","description":"A brief but helpful description of value","maxLength":5}'
    value='"world"'
></json-form>
```


## Install

You can either use unpkg.com CDN

```html
<script src="//unpkg.com/json-form-custom-element"></script>
```

or as a dependency, in es6

```javascript
import 'json-form-custom-element'
```

Installation process uses `customElements.define` browser API (which supported by current FireFox and Chrome, [it may require](https://caniuse.com/#feat=custom-elementsv1) polyfill in other browsers).

## Usage

```html
<json-form schema='{}' value='{}' config='{}'></json-form>
```

Attributes:
- schema, strinigified json schema, which may contain some additional ui specifications, see https://json-tools.github.io/json-form/ for example of `schema` configurations
- value, strinigified json value
- config, stringified json object which may contain these properties
  - dense: true | false (boolean) - choose between dense and regular layout
  - textFieldStyle: "outlined" | "filled" (string) - style of text fields
  - name: (string) - name of a form, should be unique on the page, used to generate unique ids of form elements
  - collapseNestedObjects: (boolean) - make nested json forms expandable (collapsed by default)
  - customCss: (string) - custom stylesheet, replaces builtin styling
  - showErrorIcon: (boolean) - whether to show inline error icon when validation fails (default true)

Events:
  - change: `CustomEvent` with detail `{ isValid: boolean, value, errors: { [path]: [string] }}`

Styles:
  - `--nested-object-padding`: padding of a nested object, default `0px`
  - `--expandable-section-padding`: padding of an expandable object, default `0 10px`
  - `--form-background`: background of a form, default `#fafafa`
  - `--font-family`: font family for form elements, default `helvetica, sans-serif`
  - `--color-active`: color of active element, default `#27b9cc`
  - `--color-inactive`: color of inactive element, default `#8a8a8a`
  - `--color-invalid`: color of invalid element, default `#c72227`

## JSON Schema

A few notes on how json schema interpeted by form generator.

### Types

For the sake of simpliticy form generator uses a "type" keyword of JSON Schema in order to identify type of the field. When "type" keyword is an array or types or missing then value edited as json string. Boolean renders toggle, but can be customized to render a checkbox.

### Title

Title rendered as label for terminal input fields (leaf nodes of the value), and as h3 headers for objects.

### Required

Keyword `required` of object type used to identify whether to display * near the label. Optional text fields also have button to erase value displayed.


## Contribution

Main json-form repository is here: https://github.com/json-tools/json-form please report all bugs there. Issues are disabled in this project.
