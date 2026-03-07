# 🖼 LWC Empty State Illustrations — Spring '26

![Salesforce](https://img.shields.io/badge/Salesforce-Spring%20'26-blue)
![LWC](https://img.shields.io/badge/LWC-Component-purple)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)
![Status](https://img.shields.io/badge/Feature-Beta-orange)

---

## 📋 Project Information

| Field | Details |
|---|---|
| **Project Name** | LWC Empty State Illustrations — Spring '26 Demo |
| **Technology** | Lightning Web Components (LWC) |
| **Salesforce Version** | Spring '26 / API 66.0 |
| **Feature Maturity** | Beta |
| **Problem** | Teams built inconsistent custom empty states with no theme awareness. `lightning-empty-state` standardises this. |
| **Key Capabilities** | Theme-aware SVG illustrations · Description + CTA slots · Auto responsive sizing · SLDS 1 & 2 support |

---

## 🌟 Overview

Most teams had their own `<p>No records found.</p>`. No illustrations. No theme support. No consistency.

`lightning-empty-state` (Spring '26 Beta) replaces that with a single component: theme-aware SVG illustrations that adapt to SLDS 1, SLDS 2, and dark mode automatically — with built-in text and CTA slots.

> ⚠️ **Beta — do not use in production.** Sandbox or Developer Edition only.

---

## ✨ Key Features

| Feature | Detail |
|---|---|
| `illustration-name` | Selects SLDS SVG using `category:name` format — e.g. `noresults:filter` |
| `description` slot | Required. Explains the empty state to the user |
| `cta` slot | Optional `lightning-button` for a next-step action |
| Theme detection | Auto-switches between SLDS 1 / SLDS 2 / dark mode — no code needed |
| Responsive sizing | `medium` / `small` / `xsmall` based on container width |

---

## ⚙️ Prerequisites

- [ ] Salesforce org on **Spring '26** or later
- [ ] `apiVersion` **66.0+** in `.js-meta.xml`
- [ ] Salesforce CLI (`sf`) + VS Code + Salesforce Extension Pack
- [ ] Developer Edition or Sandbox org

---

## 🚀 Usage

```bash
sf org login web --alias spring26-demo

git clone https://github.com/your-org/lwc-empty-state-demo.git
cd lwc-empty-state-demo

sf project deploy start \
  --source-dir force-app/main/default \
  --target-org spring26-demo

sf org open --target-org spring26-demo
```

Go to **Setup → Lightning App Builder**, add **Case Queue Browser**, and activate the page.

---

## 🧠 Core Concepts

### 1️⃣ Minimal Required Usage

```html
<lightning-empty-state
    title="No Cases Found"
    illustration-name="noresults:filter">
  <p slot="description">
    No cases match your filters. Adjust or clear them to continue.
  </p>
</lightning-empty-state>
```

### 2️⃣ With a Call-to-Action

```html
<lightning-empty-state
    title="No Cases Found"
    illustration-name="noresults:filter"
    alternative-text="No cases match the selected filters.">
  <p slot="description">Try adjusting your filters.</p>
  <lightning-button
      slot="cta"
      label="Clear Filters"
      variant="brand"
      onclick={handleClearFilters}>
  </lightning-button>
</lightning-empty-state>
```

### 3️⃣ Available Illustration Names

| Name | Use Case |
|---|---|
| `noresults:filter` | Filter returned no results |
| `noresults:search` | Search returned nothing |
| `success:new` | Queue empty — all done |
| `error:connectionissue` | Failed to load content |
| `cart:noitems` | Empty cart |

### 4️⃣ `lightning-empty-state` vs `lightning-illustration`

| | `lightning-empty-state` | `lightning-illustration` |
|---|---|---|
| Illustration | ✅ | ✅ |
| Title + Description | ✅ | ❌ |
| CTA button | ✅ | ❌ |
| **Use when** | Text + action needed | Illustration only |

---

## 🧪 How It Works

```text
Query returns data?
      │
   Yes → Render data table
      │
   No → Filters active?
            │
          Yes → noresults:filter + Clear Filters button
            │
           No → success:new + Create Case button
```

---

## 🏗 Architecture

```text
force-app/main/default/
├── lwc/caseQueueBrowser/
│   ├── caseQueueBrowser.html        # lwc:if / lwc:elseif / lwc:else states
│   ├── caseQueueBrowser.js          # hasCases + isFiltered getters
│   └── caseQueueBrowser.js-meta.xml # apiVersion 66.0
└── classes/
    └── CaseQueueController.cls      # @AuraEnabled + WITH USER_MODE
```

---

## 🧯 Troubleshooting

| Issue | Cause | Solution |
|---|---|---|
| Illustration not rendering | Org not on Spring '26 | Check **Setup → Company Information** |
| SLDS 2 shows SLDS 1 image | Experience Cloud site | SLDS 2 unsupported in Experience Builder |
| No illustration in small container | Width below 256px | Add `size="small"` to override |
| CTA not showing | Missing `slot="cta"` | Add `slot="cta"` to `lightning-button` |

---

## ✅ Best Practices

- `description` slot is required — always include it
- Match `illustration-name` precisely to the scenario — `filter` and `search` are not interchangeable
- Use `alternative-text` only when the illustration adds meaning beyond the title and description
- Max two buttons in the `cta` slot — `brand` for primary, `neutral` for secondary
- Test with both SLDS 1 and SLDS 2 themes before publishing

---

## 📚 Resources

| Resource | URL |
|---|---|
| Component Reference | https://developer.salesforce.com/docs/platform/lightning-component-reference/guide/lightning-empty-state.html |
| SLDS 2 Empty State Design | https://www.lightningdesignsystem.com/2e1ef8501/p/09f001-empty-state |
| Spring '26 Release Notes | https://help.salesforce.com/s/articleView?id=release-notes.rn_lc_empty_state_illustration.htm&release=260&type=5 |

---

## 🙋 Support

**Maintainer:** Kingsley MGBAMS — cmgbams@gmail.com

---

## 🗓 Last Updated: `2026-03-07`