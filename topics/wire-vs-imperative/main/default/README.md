# 🚀 Wire vs Imperative Apex in LWC

![Apex](https://img.shields.io/badge/Apex-Testing-purple)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)
![LWC](https://img.shields.io/badge/LWC-Component-blue)

---

## 📋 Project Information

| Attribute | Details |
|----------|--------|
| **Project Name** | Wire vs Imperative Apex in LWC |
| **Primary Technology** | Apex + Lightning Web Components (LWC) |
| **Problem Solved** | Helps developers choose the correct pattern for calling Apex (Wire vs Imperative) to avoid stale data, performance issues, and inconsistent UI behavior |
| **Key Features** | Reactive data loading, manual Apex execution, caching with refreshApex, pagination, error handling |

---

## 🌟 Overview

In Lightning Web Components, calling Apex is not a one-size-fits-all decision.

Salesforce provides two approaches:

- **Wire Service (`@wire`)** → reactive and cacheable  
- **Imperative Apex** → manual and flexible  

This project demonstrates:

- When each approach should be used  
- How they behave differently  
- How to combine both in a real-world scenario  

👉 Why it matters:

Choosing the wrong approach can lead to:
- Stale or inconsistent UI
- Excessive server calls
- Hard-to-debug behavior in enterprise applications

---

## ✨ Key Features

| Feature | Description |
|--------|------------|
| Wire Service Integration | Reactive data loading with built-in caching |
| Imperative Apex Calls | Manual execution for DML and event-driven logic |
| Pagination Support | Efficient handling of large datasets |
| Error Handling | User-friendly and robust error messaging |
| refreshApex Usage | Synchronize UI after data mutations |

---

## ⚙️ Prerequisites

- [ ] Salesforce Org (Developer or Sandbox)
- [ ] Lightning Web Components enabled
- [ ] Salesforce CLI (`sf`) installed
- [ ] VS Code with Salesforce Extension Pack
- [ ] Permissions:
  - Apex Class Access
  - Object CRUD/FLS (Opportunity)
---

## 🚀 Usage

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/Mgbams/salesforce-spring-26
cd wire-vs-imperative
````

### 2️⃣ Authenticate to Salesforce

```bash
sf org login web --alias my-org
```

### 3️⃣ Deploy the Project

```bash
sf project deploy start --source-dir force-app
```

### 4️⃣ Run Apex Tests

```bash
sf apex run test --tests OpportunityDataControllerTest --result-format human --wait 10
```

### 5️⃣ Add Component to App Page

* Go to Lightning App Builder
* Add **Opportunity Workbench** component
* Save and Activate

### ✅ Expected Behavior

* Data loads automatically via `@wire`
* Pagination updates records reactively
* Button triggers Imperative Apex for updates
* UI refreshes using `refreshApex`

---

## 🧠 Core Concepts You Must Know

### 1️⃣ Wire Service (`@wire`)

* Automatically calls Apex
* Requires `@AuraEnabled(cacheable=true)`
* Best for **read-only, reactive data**

```apex
@AuraEnabled(cacheable=true)
public static List<Opportunity> getData() {
    return [SELECT Id, Name FROM Opportunity];
}
```

👉 Use when:

* Displaying data
* Reacting to parameter changes

---

### 2️⃣ Imperative Apex

* Called manually via JavaScript
* Supports DML operations
* Uses Promises (`then/catch` or async/await)

```javascript
getData()
  .then(result => { this.data = result; })
  .catch(error => { this.error = error; });
```

👉 Use when:

* Handling button clicks
* Performing inserts/updates/deletes

---

### 3️⃣ refreshApex

* Refreshes cached wire data after mutation

```javascript
import { refreshApex } from '@salesforce/apex';

refreshApex(this.wiredResult);
```

👉 Critical for keeping UI consistent after DML

---

## 🧪 How It Works

### 🔄 Data Flow

```text
[Component Load]
      ↓
@wire calls Apex
      ↓
Data displayed in UI
      ↓
[User Action]
      ↓
Imperative Apex (DML)
      ↓
refreshApex()
      ↓
UI refreshes automatically
```

---

### 📊 Scenario Mapping

| Scenario             | Approach      | Outcome             |
| -------------------- | ------------- | ------------------- |
| Load data on page    | Wire          | Automatic + cached  |
| Button click update  | Imperative    | Manual execution    |
| After save refresh   | refreshApex   | UI sync             |
| Large dataset paging | Wire + params | Reactive pagination |

---

## 🏗 Architecture

### 📁 Project Structure

```text
force-app/main/default/
 ├── classes/
 │   ├── OpportunityDataController.cls
 │   └── OpportunityDataControllerTest.cls
 │
 └── lwc/
     └── opportunityWorkbench/
         ├── opportunityWorkbench.js
         ├── opportunityWorkbench.html
         ├── opportunityWorkbench.css
         └── opportunityWorkbench.js-meta.xml
```

### 🔑 Components

| Component       | Role                                |
| --------------- | ----------------------------------- |
| Apex Controller | Data access + business logic        |
| LWC JS          | Handles wire + imperative calls     |
| LWC HTML        | UI rendering                        |
| Test Class      | Ensures code coverage + reliability |

---

## 🧯 Troubleshooting

| Issue               | Cause                               | Solution                      |
| ------------------- | ----------------------------------- | ----------------------------- |
| `@wire` not working | Missing `cacheable=true`            | Add annotation to Apex method |
| Data not refreshing | Not using `refreshApex`             | Store wire result and refresh |
| DML error in wire   | DML not allowed in cacheable method | Use Imperative Apex           |
| Empty results       | Incorrect filters/pagination        | Validate parameters           |
| Permission errors   | Missing CRUD/FLS                    | Update user permissions       |

---

## ✅ Best Practices

* Use **Wire for reading data**
* Use **Imperative for mutations**
* Always handle errors gracefully
* Store full wire result for refresh
* Respect governor limits (pagination, limits)
* Enforce CRUD/FLS checks in Apex

---

## 📚 Resources

* [Call Apex Methods from LWC](https://developer.salesforce.com/docs/platform/lwc/guide/apex.html)
* [Wire Apex Methods](https://developer.salesforce.com/docs/platform/lwc/guide/apex-wire-method.html)
* [Apex Result Caching](https://developer.salesforce.com/docs/platform/lwc/guide/apex-result-caching.html)
* [LWC Developer Guide](https://developer.salesforce.com/docs/platform/lwc/guide)

---

## 🤝 Support

* Contact: Kingsley MGBAMS
* Email: [cmgbams@gmail.com](mailto:cmgbams@gmail.com)

---

## 📅 Last Updated: 2026-04-12
