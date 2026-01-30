![Salesforce](https://img.shields.io/badge/Salesforce-Spring%20'26-blue)
![Apex](https://img.shields.io/badge/Apex-Testing-purple)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)
![Status](https://img.shields.io/badge/Feature-Beta-orange)

# Dynamic Event Listeners (Spring ’26) — Trailhead-Style Demo Repo 🚀

> ⚡ A hands-on Salesforce Spring ’26 demo showcasing **Dynamic Event Listeners in LWC (`lwc:on`)** using a real Case Record Page scenario (Assign, Escalate, Email Customer).

---

## 📌 Project Information

- **Project Name:** Dynamic Event Listeners  
- **Primary Technology:** Lightning Web Components (LWC), Apex  
- **Salesforce Version:** Spring ’26 (**API 63.0**)  
- **Problem It Solves:**  
  Traditional event wiring in LWC can become messy when UI interaction modes are dynamic (hover preview vs click execute). This project demonstrates how `lwc:on` simplifies scalable event handling.
- **Key Features:**
  - Dynamic event handling using `lwc:on` in both parent and child LWCs
  - “Next Best Actions” Case UI panel with interaction modes
  - Real Apex actions: assign owner, escalate status/priority, email customer
  - Record page refresh using Lightning Data Service notifications
  - Clean, Trailhead-style structure for learning + reuse

---

## 📋 Overview 🌱

### 🎯 What This Repo Is
This repository is a **Trailhead-style demo project** for the Spring ’26 feature:

✅ **Dynamic Event Listeners in LWC (`lwc:on`)**

Instead of hardcoding multiple DOM listeners (`onclick`, `onfocus`, etc.) or using imperative `addEventListener()`, Spring ’26 introduces `lwc:on`, allowing you to attach event handlers declaratively using a JavaScript map.

### 🧠 What You'll Learn
- How to use `lwc:on` to **attach multiple event listeners dynamically**
- How to build a “Console-style” Next Best Actions UI for Case agents
- How to run **real business actions** (DML + email) from LWC
- How to refresh the Salesforce record page UI correctly after DML

> 💡 **Why it matters:** The bigger your UI gets, the harder it becomes to manage event wiring. `lwc:on` gives you a scalable, state-driven approach.

---

## ✨ Features

| Feature | Description | Why It Matters | Status |
|--------|-------------|----------------|--------|
| 🧩 `lwc:on` Dynamic Listener Maps | Attach event listeners via JS object map | Cleaner markup, scalable event handling | ✅ Implemented |
| 🎛 Interaction Mode Switching | Toggle preview vs execute vs both | Real UX requirement in console apps | ✅ Implemented |
| 👤 Assign to Me | Updates `Case.OwnerId` to current user | Most common service console action | ✅ Implemented |
| 🚨 Escalate | Sets `Status = Escalated`, `Priority = High` | Escalation workflows in support orgs | ✅ Implemented |
| ✉️ Email Customer | Sends escalation notification email | Real communication workflow | ✅ Implemented |
| 🔄 Record UI Refresh | Uses `getRecordNotifyChange()` | Ensures header/fields update without refresh | ✅ Implemented |

---

## ⚙️ Prerequisites

✅ Before you start, make sure you have:

- [ ] A Salesforce org (**Developer Edition / Sandbox / Scratch Org**)
- [ ] Salesforce DX installed: **sfdx CLI** or **sf CLI**
- [ ] VS Code + Salesforce Extension Pack *(recommended)*
- [ ] Git installed
- [ ] A Case record in your org
- [ ] Case Status includes a value called **Escalated** *(or update code accordingly)*

> ⚠️ **Org-specific requirement:**  
> The code sets `Case.Status = 'Escalated'`. If your org uses a different picklist value like `Escalated - Tier 2`, update the Apex method.
> Salesforce Org APi: 66+
> Apex class and lwc components of apiVersion 66+

---

## 🚀 Installation

### Method A — Salesforce DX CLI (Recommended)

```bash
# 1) Clone the repo
git clone https://github.com/Mgbams/salesforce-spring-26/tree/main/topics/dynamic-event-listeners
cd dynamic-event-listeners

# 2) Authenticate to your org
sf org login web -a DynamicEventListenersOrg

# 3) Deploy metadata
sf project deploy start

# 4) Open the org
sf org open
````

✅ If you're using legacy SFDX commands:

```bash
sfdx force:auth:web:login -a DynamicEventListenersOrg
sfdx force:source:push
sfdx force:org:open
```

---

### Method B — VS Code (GUI)

1. Open VS Code
2. Select **File → Open Folder**
3. Open the repository folder
4. In Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`):

   * Run: **SFDX: Authorize an Org**
   * Run: **SFDX: Deploy Source to Org**
5. Open in org:

   * Run: **SFDX: Open Default Org**

---

### Method C — Manual Deployment (Not Recommended)

You *can* deploy manually via:

* Setup → **Apex Classes**
* Setup → **Lightning Web Components**
* Setup → **Lightning App Builder**

…but this repo is designed for Salesforce DX workflows.

---

## 🧪 Usage

### ✅ What to Expect in the UI

This project adds a Case-side panel:

📌 **Next Best Actions**

* Assign to Me
* Escalate
* Email Customer

And an **Interaction Mode** combobox:

* Preview on Hover/Focus
* Execute on Click
* Both

---

### Step-by-step demo flow (Trailhead-style)

#### 1) Add the component to a Case Record Page

1. Go to **Setup → Lightning App Builder**
2. Open: **Case_Record_Page** *(or your Case record page)*
3. Drag the component:

   * `caseNextBestActions`
4. Save and Activate

> ✅ The component requires `recordId`, so it must be placed on a **record page**.

---

#### 2) Preview Mode

Select: **Preview on Hover/Focus**

✅ Hover over any tile to preview details in the panel.

---

#### 3) Execute Mode

Select: **Execute on Click**

Click a tile:

* **Assign to Me** → Case owner becomes the logged-in user
* **Escalate** → Case status becomes Escalated + Priority High
* **Email Customer** → Sends escalation notice email

---

### Key code examples

#### ✅ Parent uses `lwc:on` for custom events

**File:** `force-app/main/default/lwc/caseNextBestActions/caseNextBestActions.html`

```html
<c-next-best-action-tile
  key={a.id}
  action-id={a.id}
  action-label={a.label}
  description={a.description}
  category={a.category}
  icon-name={a.iconName}
  lwc:on={tileListeners}
></c-next-best-action-tile>
```

#### ✅ Parent dynamically defines the listener map

**File:** `caseNextBestActions.js`

```js
get tileListeners() {
  if (this.interactionMode === 'preview') return { preview: this.handlePreview };
  if (this.interactionMode === 'execute') return { execute: this.handleExecute };
  return { preview: this.handlePreview, execute: this.handleExecute };
}
```

#### ✅ Child uses `lwc:on` for DOM events

**File:** `nextBestActionTile.html`

```html
<article class="tile" lwc:on={domListeners}>
```

**File:** `nextBestActionTile.js`

```js
get domListeners() {
  return {
    click: this.handleClick,
    mouseenter: this.handleMouseEnter,
    focus: this.handleFocus
  };
}
```

#### ✅ Refresh record page after DML

```js
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

getRecordNotifyChange([{ recordId: this.recordId }]);
```

---

### 📷 Screenshots (Optional)

Add screenshots to `/docs/images/` and reference here:

* UI view: `docs/images/next-best-actions.png`
* Interaction mode change: `docs/images/interaction-mode.png`

Example markdown:

```md
![Next Best Actions Demo](docs/images/next-best-actions.png)
```

---

## 🏗 Architecture

### 📁 File Structure

```txt
force-app/main/default/
├── applications/
│   └── Dynamic_Events_Explorer.app-meta.xml
├── classes/
│   ├── CaseNextBestActionsController.cls
│   └── CaseNextBestActionsController.cls-meta.xml
├── flexipages/
│   ├── Case_Record_Page.flexipage-meta.xml
│   └── Dynamic_Events_Explorer_UtilityBar.flexipage-meta.xml
└── lwc/
    ├── caseNextBestActions/
    │   ├── caseNextBestActions.html
    │   ├── caseNextBestActions.js
    │   ├── caseNextBestActions.css
    │   └── caseNextBestActions.js-meta.xml
    └── nextBestActionTile/
        ├── nextBestActionTile.html
        ├── nextBestActionTile.js
        ├── nextBestActionTile.css
        └── nextBestActionTile.js-meta.xml
```

---

### Key Components

| Component                       | Type       | Purpose                                                 |
| ------------------------------- | ---------- | ------------------------------------------------------- |
| `CaseNextBestActionsController` | Apex       | Provides recommendations + business actions (DML/email) |
| `caseNextBestActions`           | Parent LWC | UI shell, interaction mode logic, listener routing      |
| `nextBestActionTile`            | Child LWC  | Tile UI, DOM interaction, emits `preview`/`execute`     |

---

## 🔬 Technical Details

### Apex Methods

| Method                                  | Type                           | Purpose                                          |
| --------------------------------------- | ------------------------------ | ------------------------------------------------ |
| `getRecommendedActions(caseId)`         | `@AuraEnabled(cacheable=true)` | Returns action tile metadata                     |
| `assignCaseToMe(caseId)`                | `@AuraEnabled`                 | Sets `OwnerId = UserInfo.getUserId()`            |
| `escalateCase(caseId)`                  | `@AuraEnabled`                 | Sets `Status = Escalated` + `Priority = High`    |
| `emailCustomerEscalationNotice(caseId)` | `@AuraEnabled`                 | Sends escalation email to Contact/Supplied email |

---

### Event Flow / Data Flow

```txt
User Interaction (Hover/Focus/Click)
        ↓
nextBestActionTile dispatches CustomEvent
  - preview
  - execute
        ↓
caseNextBestActions listens via lwc:on
        ↓
Parent updates preview OR calls Apex
        ↓
Apex updates Case / sends email
        ↓
getRecordNotifyChange refreshes record page UI
```

---

### Patterns Demonstrated

✅ **Dynamic Listener Map Pattern**

* `lwc:on={listeners}`
* JS getter returns `{ eventName: handler }`

✅ **Event Dispatch Pattern**

* child dispatches `CustomEvent('execute')`
* parent handles business logic

✅ **UI + DML Hybrid Pattern**

* LWC for UI and orchestration
* Apex for DML and messaging

✅ **LDS Refresh Pattern**

* `getRecordNotifyChange` after server updates

---

## 🛠 Troubleshooting

| Issue              | Symptoms                             | Likely Cause                          | Fix                                         |
| ------------------ | ------------------------------------ | ------------------------------------- | ------------------------------------------- |
| No actions display | “No recommended actions yet.”        | `recordId` is missing                 | Add component to **Case Record Page**       |
| Escalate fails     | Toast error / DML exception          | `Escalated` is not a valid Status     | Update Apex status value to match org       |
| Email fails        | “No customer email found”            | No `Contact.Email` or `SuppliedEmail` | Populate Contact email or Web-to-Case email |
| UI doesn’t update  | Status/Owner unchanged visually      | Record page not refreshed             | Ensure `getRecordNotifyChange()` runs       |
| Permission error   | Apex exception / insufficient access | User can’t edit Case                  | Assign proper profile/permission set        |

> 💡 Tip: check browser console logs and debug logs in Salesforce if something fails silently.

---

## ✅ Best Practices

### Demonstrated in this repo

* ✅ Uses `lwc:on` instead of imperative event wiring
* ✅ Clean parent-child separation:

  * child emits events
  * parent performs logic
* ✅ Uses focused Apex methods per action
* ✅ Uses user feedback (toasts)
* ✅ Refreshes record page via LDS notify change

### Opportunities / Enhancements (optional)

* 🔁 Add Permission Set + CRUD/FLS checks (production hardening)
* 🧪 Add Apex test class: `CaseNextBestActionsControllerTest`
* 🧭 Replace certain actions with Flow invocation (if desired)
* 🔒 Add shield checks around email capability
* 📈 Log action execution (Platform Events or custom object)

---

## 📚 Resources

### Official Documentation

* Dynamic event listener considerations:
  [https://developer.salesforce.com/docs/platform/lwc/guide/events-dynamic-considerations.html](https://developer.salesforce.com/docs/platform/lwc/guide/events-dynamic-considerations.html)
* Events handling + `lwc:on`:
  [https://developer.salesforce.com/docs/platform/lwc/guide/events-handling.html#attach-event-listeners-declaratively-and-dynamically](https://developer.salesforce.com/docs/platform/lwc/guide/events-handling.html#attach-event-listeners-declaratively-and-dynamically)
* Spring ’26 Developer Guide:
  [https://developer.salesforce.com/blogs/2026/01/developers-guide-to-the-spring-26-release](https://developer.salesforce.com/blogs/2026/01/developers-guide-to-the-spring-26-release)

### Useful Platform References

* `getRecordNotifyChange` (Lightning UI Record API):
  [https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_ui_api_record_notify](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_ui_api_record_notify)

---

### Support / Contact

For questions, feedback, or improvements:

* Maintainer: **Kingsley MGBAMS**
* Email: **cmgbams@gmail.com**
* Issues: Use GitHub Issues in this repository

> ✅ Contributions welcome! Please open an issue or submit a PR.

---

## 🗓 Last Updated: **2026-01-30**


