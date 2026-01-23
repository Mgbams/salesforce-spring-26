# 🚀 Apex Cursors & Pagination Cursors (Spring ’26) — UI Paging + Queueable Processing Demo

![Salesforce](https://img.shields.io/badge/Salesforce-Spring%20'26-blue)
![Apex](https://img.shields.io/badge/Apex-Testing-purple)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)

---

## 📋 Project Information

| Item | Details |
|------|---------|
| **Project Name** | Apex Cursors & Apex PaginationCursor Demo |
| **Primary Technology** | Apex + LWC (Mixed) |
| **Salesforce Version** | Spring ’26 / API 66.0 |
| **Feature Maturity** | Beta / Pilot |
| **Problem It Solves** | Enables scalable pagination and large dataset processing without relying solely on OFFSET pagination or Batch Apex. |
| **Key Capabilities** | • UI paging with `Database.PaginationCursor` <br> • Safe SOQL with binds (`getPaginationCursorWithBinds`) <br> • Cursor-based Queueable chaining for large data processing <br> • Production-aligned test classes and error handling |

---

## 🌟 Overview

Salesforce orgs with **large datasets** often struggle with:

- Slow UI pagination (especially when using `OFFSET`)
- Long-running data processing jobs that exceed CPU or heap limits

**Spring ’26 introduces Apex Cursors**, providing a new way to:

✅ **Page through records efficiently** using `Database.PaginationCursor` (UI-friendly)  
✅ **Process massive datasets safely** using `Database.Cursor` with Queueable chaining (back-end processing)

This repo demonstrates both cursor types in two real-world examples:
1. **Case Inbox UI paging** (PaginationCursor + LWC datatable)
2. **Contact archiving job** (Cursor + Queueable)

---

## ✨ Key Features

| ✨ Feature | 📝 Description |
|----------|----------------|
| 🧾 UI Paging with PaginationCursor | Loads Cases page-by-page for an interactive inbox UI |
| 🔐 Bind-Safe Querying | Uses `Database.getPaginationCursorWithBinds()` for secure and maintainable SOQL |
| 🔁 Queueable Cursor Chaining | Processes Contacts in chunks without Batch Apex |
| ✅ Test Coverage Included | Deterministic tests for both UI paging and Queueable processing |
| 🛡 Security Best Practices | Demonstrates `with sharing`, `USER_MODE`, and `stripInaccessible()` |

---

## ⚙️ Prerequisites

- [ ] Salesforce org on **Spring ’26 or later**
- [ ] Apex classes compiled on **API 66.0+**
- [ ] Salesforce CLI installed (`sf`)
- [ ] VS Code + Salesforce Extensions (recommended)
- [ ] Permissions:
  - [ ] Deploy Apex & LWC
  - [ ] Run Apex tests
  - [ ] Read Cases and Contacts
  - [ ] Edit Contacts (for archive demo)

⚠️ **Warning:** Apex Cursors must be implemented in API v66.0.

---

## 🚀 Usage

### 1) Authenticate to your org

```bash
sf org login web --alias [ORG_ALIAS]
sf config set target-org=[ORG_ALIAS]
````

### 2) Deploy to the org

```bash
sf project deploy start --source-dir force-app
```

### 3) Deploy with Spring ’26 test optimization (optional)

```bash
sf project deploy start --source-dir force-app --test-level RunRelevantTests
```

✅ Expected behavior:

* Apex cursor components deploy successfully
* Only impacted tests run when using `RunRelevantTests`
* UI paging controller returns cursor state and pages correctly
* Archive job can run asynchronously using Queueable chaining

---

## 🧠 Core Concepts You Must Know

### 1️⃣ `Database.PaginationCursor` (UI Paging)

**What it is:**
A cursor type designed for **interactive paging** in UIs (Next/Previous, Load More).

**Why it matters:**
It avoids OFFSET-heavy paging and provides efficient page access at scale.

**Where it’s used in this repo:**
✅ `CaseInboxCursorController.getPage()`

**Example:**

```apex
Database.PaginationCursor cursor =
    Database.getPaginationCursorWithBinds(soql, binds, AccessLevel.USER_MODE);

Database.CursorFetchResult fr = cursor.fetchPage(start, size);
List<SObject> rows = fr.getRecords();
```

---

### 2️⃣ `getPaginationCursorWithBinds()` (Safe SOQL with binds)

**What it is:**
A PaginationCursor method that accepts a query + bind map + access mode.

**Why it matters:**

* Prevents unsafe string concatenation
* Keeps SOQL readable and maintainable
* Great for UI filters and user-specific queries

**Example:**

```apex
Map<String, Object> binds = new Map<String, Object>{
    'ownerId' => UserInfo.getUserId()
};

cursor = Database.getPaginationCursorWithBinds(
    soql,
    binds,
    AccessLevel.USER_MODE
);
```

---

### 3️⃣ `Database.Cursor` + Queueable chaining (Large dataset processing)

**What it is:**
A Cursor that supports large datasets, combined with Queueable jobs for chunk processing.

**Why it matters:**
It’s a strong alternative to Batch Apex for:

* archiving jobs
* exports
* data cleanup
* background updates

**Where it’s used in this repo:**
✅ `ContactArchiveCursorJob` + `ContactArchiveJobLauncher`

**Example:**

```apex
List<SObject> scope = cursor.fetch(position, chunkSize);
position += scope.size();

if (position < cursor.getNumRecords()) {
    System.enqueueJob(new ContactArchiveCursorJob(cursor, position, chunkSize));
}
```

---

## 🧪 How It Works

### High-level Flow

```text
User clicks Next/Previous in LWC (Case Inbox)
        ↓
Apex controller creates or reuses PaginationCursor
        ↓
fetchPage(start, size) loads next slice of records
        ↓
cursorJson returned to LWC for next request
```

```text
Launcher starts Cursor job (Contacts)
        ↓
Queueable fetches chunk via cursor.fetch(position, chunkSize)
        ↓
Updates records
        ↓
Re-enqueues next job until cursor exhausted
```

### Scenario Outcomes

| Scenario                 | Cursor Type        | Expected Outcome                     |
| ------------------------ | ------------------ | ------------------------------------ |
| First Case page load     | PaginationCursor   | Cursor created + first page returned |
| Next/Previous clicks     | PaginationCursor   | Cursor reused via `cursorJson`       |
| Small dataset processing | Cursor + Queueable | Processes in 1–2 jobs                |
| Large dataset processing | Cursor + Queueable | Chains jobs safely until complete    |
| No matching data         | PaginationCursor   | Empty list returned without errors   |

---

## 🏗 Architecture

### Project Structure

```text
apex-cursors-and-paginationcursors/
└── main/
    └── default/
        ├── classes/
        │   ├── CaseInboxCursorController.cls
        │   ├── CaseInboxCursorControllerTest.cls
        │   ├── ContactArchiveJobLauncher.cls
        │   ├── ContactArchiveCursorJob.cls
        │   └── ContactArchiveCursorJobTest.cls
        └── lwc/
            └── caseInbox/
                ├── caseInbox.html
                ├── caseInbox.js
                └── caseInbox.js-meta.xml
```

### Key Components

| Component                   | Purpose                                              |
| --------------------------- | ---------------------------------------------------- |
| `CaseInboxCursorController` | UI paging server endpoint (PaginationCursor + binds) |
| `caseInbox` LWC             | UI datatable + Next/Previous paging controls         |
| `ContactArchiveJobLauncher` | Starts a large dataset cursor job                    |
| `ContactArchiveCursorJob`   | Queueable worker processing records in chunks        |
| Tests                       | Ensure stable results and deployment readiness       |

---

## 🧯 Troubleshooting

| Issue                         | Cause                                       | Solution                                           |
| ----------------------------- | ------------------------------------------- | -------------------------------------------------- |
| No Cases shown in UI          | Cases not owned by current user             | Assign Cases to your user OR remove OwnerId filter |
| “unexpected token” SOQL error | Invalid query syntax (`LAST_N_DAYS :bind`)  | Use Date/Datetime binds instead of date literals   |
| CursorJson errors             | Cursor not serialized/deserialized properly | Ensure controller uses JSON serialize/deserialize  |
| Test failures in org          | Validation rules / flows interfering        | Update test data to satisfy org automation         |
| CLI deployment errors         | CLI outdated or bad auth                    | Run `sf update` and re-login                       |

---

## ✅ Best Practices

* Use `Database.PaginationCursor` for UI paging (Next/Previous/Load More)
* Use `Database.Cursor` for large-scale async processing
* Prefer bind-safe queries (`getPaginationCursorWithBinds`)
* Use `AccessLevel.USER_MODE` for UI-facing logic
* Strip inaccessible fields before returning records:

  * `Security.stripInaccessible(AccessType.READABLE, records)`
* Write deterministic tests:

  * only query records created in the test context
* Keep chunk sizes reasonable (100–500) unless you benchmark

---

## 📚 Resources

* Apex Cursors Overview (Spring ’26)
  [https://developer.salesforce.com/docs/atlas.en-us.260.0.apexcode.meta/apexcode/apex_cursors.htm](https://developer.salesforce.com/docs/atlas.en-us.260.0.apexcode.meta/apexcode/apex_cursors.htm)

* Cursor API Reference
  [https://developer.salesforce.com/docs/atlas.en-us.260.0.apexref.meta/apexref/apex_class_Database_Cursor.htm](https://developer.salesforce.com/docs/atlas.en-us.260.0.apexref.meta/apexref/apex_class_Database_Cursor.htm)

* `Database.getPaginationCursor()`
  [https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_database.htm#apex_System_database_getPaginationCursor](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_database.htm#apex_System_database_getPaginationCursor)

* Salesforce CLI Reference
  [https://developer.salesforce.com/tools/sfdxcli](https://developer.salesforce.com/tools/sfdxcli)

---

## Support

* 👤 Maintainer: Kingsley Mgbams
* ✉️ Email: cmgbams@gmail.com

---

## Last Updated

📅 **2026-01-23**
