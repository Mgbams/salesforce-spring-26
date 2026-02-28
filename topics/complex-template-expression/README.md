# ⚡ LWC Complex Template Expressions — Spring '26 Demo

![Salesforce](https://img.shields.io/badge/Salesforce-Spring%20'26-blue)
![LWC](https://img.shields.io/badge/LWC-Component-purple)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)
![Status](https://img.shields.io/badge/Feature-Beta-orange)

---

## 📋 Project Information

| Field | Details |
|---|---|
| **Project Name** | LWC Complex Template Expressions — Spring '26 Demo |
| **Technology** | Lightning Web Components (LWC) |
| **Salesforce Version** | Spring '26 / API 66.0 |
| **Feature Maturity** | Beta |
| **Problem It Solves** | LWC templates required JavaScript getters for trivial display logic, bloating component classes with presentation-only methods. |
| **Key Capabilities** | Inline arithmetic · String concatenation · Conditional text via ternary · Nullish coalescing fallbacks · Getter-backed class attributes |

---

## 🌟 Overview

LWC's original template system only allowed plain property references. Every computed display value — a formatted name, a conditional label, a cost total — required a dedicated getter in JavaScript, regardless of how simple the logic was.

**Complex Template Expressions** (Spring '26, API 66.0+) allows a supported subset of JavaScript expressions directly inside LWC HTML templates, in text node positions. This keeps display logic in the presentation layer where it belongs and reduces JavaScript class bloat.

> **Current Beta scope:** Expressions work in text node positions only. HTML attribute bindings (e.g. `class={...}`) still require a simple property reference or getter.

---

## ✨ Key Features

| Feature | Example |
|---|---|
| String concatenation | `{firstName + ' ' + lastName}` |
| Conditional text | `{priority > 8 ? 'Critical' : 'Normal'}` |
| Nullish coalescing | `{totalBillableHours ?? 'No hours logged yet'}` |
| Inline arithmetic | `{hourlyRate * (totalBillableHours ?? 0)}` |
| Getter-backed attributes | `class={priorityClass}` (Beta workaround) |

---

## ⚙️ Prerequisites

- [ ] Salesforce org on **Spring '26** or later
- [ ] `apiVersion` set to **66.0+** in `.js-meta.xml`
- [ ] Salesforce CLI (`sf`) installed and authenticated
- [ ] VS Code + **Salesforce Extension Pack**
- [ ] Developer Edition org or Sandbox

> ⚠️ **Beta — Do not use in production.** This feature is subject to the [Salesforce Beta Services Terms](https://www.salesforce.com/company/legal/agreements/). Evaluate in a Developer Edition or Sandbox only.

---

## 🚀 Usage

**1. Authenticate**
```bash
sf org login web --alias spring26-demo
```

**2. Clone and deploy**
```bash
git clone https://github.com/your-org/lwc-complex-template-expressions.git
cd lwc-complex-template-expressions

sf project deploy start \
  --source-dir force-app/main/default/lwc/caseDashboardCard \
  --target-org spring26-demo
```

**3. Open and test**
```bash
sf org open --target-org spring26-demo
```
Go to **Setup → Lightning App Builder**, add **Case Dashboard Card** to a page, and activate it.

**Expected behavior:** The component renders a fully evaluated case card. All dynamic values resolve inline. Changing `@api` property values triggers reactive re-evaluation with no extra JavaScript.

---

## 🧠 Core Concepts You Must Know

### 1️⃣ Enabling the Feature

Set `apiVersion` to `66.0` in the component metadata. Each component opts in independently.
```xml
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
  <apiVersion>66.0</apiVersion>
  <isExposed>true</isExposed>
</LightningComponentBundle>
```

### 2️⃣ Text Node Expressions

Write JavaScript expressions directly between HTML tags.
```html
<p>{firstName + ' ' + lastName}</p>
<p>{priority > 8 ? 'Critical' : priority > 5 ? 'High' : 'Normal'}</p>
<p>{totalBillableHours ?? 'No hours logged yet'}</p>
<p>${hourlyRate * (totalBillableHours ?? 0)}</p>
```

### 3️⃣ Attribute Limitation (Beta)

Complex expressions inside attribute bindings are **not yet supported**. Use a getter instead.
```html
<!-- ❌ Fails in Beta -->
<span class={priority > 8 ? 'badge-critical' : 'badge-normal'}>...</span>

<!-- ✅ Correct pattern -->
<span class={priorityClass}>
  {priority > 8 ? 'Critical' : priority > 5 ? 'High' : 'Normal'}
</span>
```
```js
get priorityClass() {
  if (this.priority > 8) return 'badge badge-critical';
  if (this.priority > 5) return 'badge badge-high';
  return 'badge badge-normal';
}
```

### 4️⃣ `??` vs `||`

Always use `??` for nullable numeric fields. `||` incorrectly treats `0` as falsy.
```html
<!-- ❌ Shows fallback when hours === 0 -->
<p>{totalBillableHours || 'No hours logged yet'}</p>

<!-- ✅ Only triggers on null or undefined -->
<p>{totalBillableHours ?? 'No hours logged yet'}</p>
```

---

## 🧪 How It Works
```text
@api properties received by component
          │
          ▼
┌─────────────────────────────────────────────┐
│            caseDashboardCard                │
│                                             │
│  Text nodes   → Complex expressions         │
│                 {firstName + ' ' + lastName}│
│                 {priority > 8 ? '...' : …}  │
│                 {totalBillableHours ?? '…'} │
│                 {hourlyRate * (hours ?? 0)} │
│                                             │
│  Attributes   → Getters (Beta workaround)   │
│    class=       get priorityClass()         │
│    class=       get daysOpenClass()         │
└─────────────────────────────────────────────┘
          │
          ▼
  Virtual DOM re-evaluates on property change
```

### Expression Outcome Map

| Scenario | Mechanism | Output |
|---|---|---|
| Full name | Inline expression | `Sarah Connor` |
| Priority label | Inline expression | `Critical` |
| Priority badge CSS | Getter | `badge badge-critical` |
| Overdue status text | Inline expression | `Overdue — Immediate Attention Required` |
| Overdue CSS class | Getter | `case-overdue` |
| Billable hours fallback | Inline expression | `No hours logged yet` |
| Estimated cost | Inline expression | `$0` |

---

## 🏗 Architecture
```text
force-app/
└── main/
    └── default/
        └── lwc/
            └── caseDashboardCard/
                ├── caseDashboardCard.html          # Inline expressions (text nodes)
                ├── caseDashboardCard.js            # @api props + 2 attribute getters
                ├── caseDashboardCard.css           # Badge and status strip styles
                └── caseDashboardCard.js-meta.xml   # apiVersion 66.0
```

| File | Role |
|---|---|
| `.html` | All inline template expressions |
| `.js` | State properties + `priorityClass` / `daysOpenClass` getters |
| `.css` | `.badge-*` and `.case-overdue` / `.case-on-track` classes |
| `.js-meta.xml` | Sets `apiVersion: 66.0` to enable the feature |

---

## 🧯 Troubleshooting

| Issue | Cause | Solution |
|---|---|---|
| Expressions render as raw `{...}` text | `apiVersion` below `66.0` | Set `<apiVersion>66.0</apiVersion>` and redeploy |
| `class=` expression fails to deploy | Attribute expressions unsupported in Beta | Replace with a getter in `.js` |
| Component missing in App Builder | `isExposed` is `false` or no `<target>` | Add `<isExposed>true</isExposed>` and a valid `<target>` |
| `NaN` in cost field | `totalBillableHours` is `null`, unguarded | Use `{hourlyRate * (totalBillableHours ?? 0)}` |
| `0` hours shows fallback text | `||` used instead of `??` | Replace `||` with `??` |
| Deploy fails with API version error | Org is not on Spring '26 | Verify in **Setup → Company Information** or use a Spring '26 scratch org |

---

## ✅ Best Practices

- Opt in per component only — do not bump `apiVersion` on untested components
- Use expressions for text nodes only until attribute support reaches GA
- Use `??` over `||` for all nullable numeric or boolean fields
- Move logic to a named getter if an expression exceeds one readable line or is reused more than twice
- Comment Beta-workaround getters so they can be removed once attribute support ships
- Never deploy Beta features to production

---

## 📚 Resources

| Resource | URL |
|---|---|
| Template Expressions — LWC Dev Guide | https://developer.salesforce.com/docs/platform/lwc/guide/create-components-html-expressions.html |
| Use Complex Expressions | https://developer.salesforce.com/docs/platform/lwc/guide/create-components-html-expressions-use.html |
| Considerations and Limitations | https://developer.salesforce.com/docs/platform/lwc/guide/create-components-html-expressions-considerations.html |
| Bind Data in a Template | https://developer.salesforce.com/docs/platform/lwc/guide/js-props-getter.html |
| Salesforce CLI Reference | https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/ |
| Spring '26 Release Notes | https://help.salesforce.com/s/articleView?id=release-notes.rn_lwc.htm |

---

## 🙋 Support

- **Maintainer:** Kingsley MGBAMS — cmgbams@gmail.com

---

## 🗓 Last Updated: `2026-02-28`