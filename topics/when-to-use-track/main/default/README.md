# ⚡ lwc-track-performance-demo

![LWC](https://img.shields.io/badge/LWC-JavaScript-purple)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)

---

## 📋 Project Information

| Field | Details |
|---|---|
| **Project Name** | lwc-track-performance-demo |
| **Primary Technology** | Lightning Web Components (LWC) |
| **Problem It Solves** | Overusing `@track` in LWC triggers unnecessary deep observation and rerenders, degrading component performance as data grows. This project demonstrates the correct reactivity model and immutable update patterns. |
| **Key Capabilities** | Before/after `@track` contrast, server-side wire filtering, immutable array updates, dynamic row actions, case number hyperlinking |

---

## 🌟 Overview

A common LWC habit: reach for `@track` whenever a value doesn't update.

```js
@track records = [];
@track isLoading = false;
@track errorMessage = '';
```

This pattern made sense in early LWC. Since Spring '20, it's unnecessary for most use cases — and actively harmful for performance when applied to objects and arrays on large datasets.

This project demonstrates:
- When LWC reactivity is automatic and `@track` is not needed
- How deep mutation causes unnecessary rerenders
- How immutable patterns (`map`, spread operator) trigger reactivity cleanly
- A production-quality Case Viewer built without unnecessary `@track`

> **Rule of thumb:** If you're creating a new object or array, you don't need `@track`.

---

## ✨ Key Features

| Feature | Description |
|---|---|
| `@track` Anti-Pattern Demo | Side-by-side bad/good JS showing the performance cost of overuse |
| Server-Side Wire Filtering | `$filterStatus` reactive property drives Apex query — no client-side filtering |
| Immutable Array Updates | Case status updates use `map` + spread — no direct mutation |
| Dynamic Row Actions | Datatable action label changes per row (`Close Case` / `Reopen Case`) |
| Case Number Hyperlink | `type: 'url'` column links directly to the Salesforce record page |
| Proper SLDS Error Handling | Errors rendered with SLDS alert markup, not plain `<p>` tags |

---

## ⚙️ Prerequisites

- [ ] Salesforce org (Developer Edition, Sandbox, or Scratch Org)
- [ ] API version 59.0 or later
- [ ] Cases with Status values matching your org's picklist (`New`, `Working`, `Escalated`, `Closed`)
- [ ] `CaseController` Apex class deployed before the LWC component
- [ ] Salesforce CLI (`sf`) installed — [Install guide](https://developer.salesforce.com/tools/salesforcecli)
- [ ] VS Code with [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)

> ⚠️ **Important:** The `statusOptions` in the JS and the `filterStatus` default value must match your org's exact Case Status picklist values. Mismatched values will return no results silently. Verify your picklist values in Setup → Case → Fields → Status before deploying.

---

## 🚀 Usage

### 1. Authenticate to your org

```bash
sf org login web --alias my-org
```

### 2. Deploy the Apex controller first

```bash
sf project deploy start --source-dir force-app/main/default/classes --target-org my-org
```

### 3. Deploy the LWC component

```bash
sf project deploy start --source-dir force-app/main/default/lwc --target-org my-org
```

### 4. Or deploy everything at once

```bash
sf project deploy start --source-dir force-app --target-org my-org
```

### 5. Add the component to a page

Navigate to any App Page or Record Page in Lightning App Builder and add `CaseList`.

**Expected behavior:**
- Component loads with the default status filter (`New`)
- Selecting a status from the dropdown re-queries the server automatically
- Each case number is a clickable hyperlink to the record page
- Row action shows `Close Case` for open cases and `Reopen Case` for closed cases

---

## 🧠 Core Concepts You Must Know

### 1️⃣ LWC Reactivity Is Automatic for Primitives

Since Spring '20, primitives are reactive without any decorator:

```js
// ✅ No @track needed
isLoading = false;
errorMessage = '';
filterStatus = 'New';
```

Assigning a new value triggers the UI update automatically.

### 2️⃣ Reference Changes Trigger Reactivity on Objects and Arrays

```js
// ✅ New reference — UI updates
this.cases = data;

// ✅ New array from map — UI updates
this.cases = this.cases.map(c => ({ ...c, Status: 'Closed' }));

// ❌ Direct mutation — UI does NOT update without @track
this.cases[0].Status = 'Closed';
```

LWC watches the reference, not the contents. Replace the reference to trigger the update.

### 3️⃣ `$filterStatus` Makes the Wire Reactive

```js
@wire(getCases, { statusFilter: '$filterStatus' })
wiredCases({ data, error }) { ... }
```

The `$` prefix tells LWC to re-fire the wire automatically every time `filterStatus` changes. No manual re-query needed — changing the combobox value triggers a fresh Apex call.

### 4️⃣ Immutable Updates Prevent Mutation Bugs

```js
// ✅ Immutable — creates new array and new object
this.cases = this.cases.map( c => c.Id === caseId ? { ...c, Status: newStatus } : c );
```

This is safer than mutating in place: the original structure is never modified, reactivity fires cleanly, and the pattern works without `@track`.

### 5️⃣ Dynamic Row Actions Per Row

```js
function getRowActions(row, doneCallback) {
    const actions = row.Status !== 'Closed'
        ? [{ label: 'Close Case', name: 'close', iconName: 'utility:close' }]
        : [{ label: 'Reopen Case', name: 'reopen', iconName: 'utility:refresh' }];
    doneCallback(actions);
}
```

Passing a function reference (not an array) to `rowActions` lets the datatable compute the correct action per row at render time.

---

## 🧪 How It Works

```text
User selects status from combobox
        │
        ▼
┌─────────────────────────────────┐
│  filterStatus = event value     │  → primitive update, reactive
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│  Wire re-fires automatically    │  → $filterStatus triggers new Apex call
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│  Apex filters server-side       │  → WHERE Status = :statusFilter
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│  cases = data.map(add caseUrl)  │  → immutable map adds hyperlink field
└─────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────┐
│  Datatable renders              │  → dynamic actions, linked case numbers
└─────────────────────────────────┘
```

### Scenario → Outcome

| Scenario | Outcome |
|---|---|
| Select `New` from combobox | Wire re-fires, Apex returns New cases only |
| Select `Closed` from combobox | Wire re-fires, row actions show `Reopen Case` |
| Click `Close Case` on a row | Immutable map updates that row's Status to `Closed` |
| Click `Reopen Case` on a row | Immutable map updates that row's Status to `New` |
| Click a Case Number | Opens the Salesforce record page in a new tab |
| No cases match the filter | Empty state message displayed |
| Apex error | SLDS alert banner displayed with error message |

---

## 🏗 Architecture

```text
force-app/
└── main/default/
    ├── classes/
    │   ├── CaseController.cls              ← Apex — server-side filtering
    │   └── CaseController.cls-meta.xml
    └── lwc/
        └── caseList/
            ├── caseList.js                 ← Component logic — no unnecessary @track
            ├── caseList.html               ← Template — SLDS markup
            └── caseList.js-meta.xml        ← Component metadata
```

| Component | Role |
|---|---|
| `CaseController.cls` | Cacheable Apex method — accepts `statusFilter`, queries Cases server-side |
| `caseList.js` | All reactive state managed without `@track`; wire, immutable updates, dynamic actions |
| `caseList.html` | SLDS-compliant template; combobox, datatable, error alert, empty state |

---

## 🧯 Troubleshooting

| Issue | Cause | Solution |
|---|---|---|
| No cases shown on load | `filterStatus` default doesn't match org picklist | Check Setup → Case → Status picklist; update `filterStatus` default to match |
| Combobox shows no options | `statusOptions` values don't match org picklist | Update `statusOptions` values to match exact picklist API names |
| Wire never fires | Apex method not `cacheable=true` | Add `@AuraEnabled(cacheable=true)` to the Apex method |
| Row actions don't appear | `rowActions` passed as array, not function | Pass a function reference — `rowActions: getRowActions` not `rowActions: [...]` |
| Case number link goes nowhere | `caseUrl` field not computed in wire result | Ensure `data.map(c => ({ ...c, caseUrl: \`/${c.Id}\` }))` runs in `wiredCases` |
| Status update doesn't reflect in UI | Direct array mutation used instead of `map` | Replace `this.cases[i].Status = x` with the immutable `map` pattern |
| Deploy fails — field not found | `Subject` field missing from SOQL | Add `Subject` to the Apex SOQL query |

---

## ✅ Best Practices

- Never use `@track` on primitives — `string`, `number`, `boolean` are reactive by default
- Never use `@track` on arrays or objects when you can reassign the reference
- Always use immutable patterns (`map`, spread) for array item updates
- Use `$propertyName` in wire adapters to make filtering reactive automatically
- Filter server-side when possible — avoids destructive client-side filtering bugs
- Match `statusOptions` values exactly to your org's picklist API names
- Always guard Apex methods with `if (String.isBlank(param)) return new List<SObject>()`
- Use `type: 'action'` with a function reference for dynamic per-row datatable actions
- Use `type: 'url'` with a computed field for record page hyperlinks in datatables

---

## 📚 Resources

- [LWC Reactivity](https://developer.salesforce.com/docs/platform/lwc/guide/reactivity.html)
- [Reactive Properties](https://developer.salesforce.com/docs/platform/lwc/guide/reactivity-fields.html)
- [Getters and Setters in LWC](https://developer.salesforce.com/docs/platform/lwc/guide/js-props-getters-setters.html)
- [Wire Service](https://developer.salesforce.com/docs/platform/lwc/guide/wire-service.html)
- [Lightning Datatable](https://developer.salesforce.com/docs/platform/lwc/guide/lwc-ref-lightning-datatable.html)
- [Salesforce CLI Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

---

## 🤝 Support

Found a bug or have a question?

- **Contact:** Kingsley MGBAMS — cmgbams@gmail.com

---

## 🗓 Last Updated 2026-04-05