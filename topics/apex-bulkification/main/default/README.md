# ⚡ apex-bulkification-demo

![Apex](https://img.shields.io/badge/Apex-Triggers-purple)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)
![Status](https://img.shields.io/badge/Feature-GA-brightgreen)

---

## 📋 Project Information

| Field | Details |
|---|---|
| **Project Name** | apex-bulkification-demo |
| **Primary Technology** | Apex |
| **Problem It Solves** | Apex triggers that use SOQL or DML inside loops fail under load, causing `LimitException` errors in production. This project demonstrates a deterministic, governor-safe pattern for any batch size. |
| **Key Features** | CQAW pattern, single SOQL + single DML per transaction, reparenting support, null-safe guards, 5 bulk test scenarios |

---

## 🌟 Overview

Salesforce processes up to 200 records per transaction. Governor limits apply to the **entire batch** — not per record. Triggers that query or write inside loops consume limits linearly and fail in production during data loads or bulk operations.

This project demonstrates the **CQAW pattern** — a structured Apex approach that ensures constant governor limit usage regardless of batch size.

**CQAW = a constant-cost execution pattern for Apex transactions.**

It uses a Contact → Account rollup as the teaching example, but the pattern applies to any trigger context.

**Why it matters:** Code that passes in sandbox at 1 record regularly fails in production at 200.

CQAW isn’t an optimization — it’s the baseline for safe Apex.

---

## ✨ Key Features

| Feature | Description |
|---|---|
| CQAW Pattern | Collect → Query → Aggregate → Write — constant cost at any batch size |
| Single SOQL Query | All related records fetched in one query |
| Single DML Operation | All updates committed in one operation |
| Reparenting Support | Handles Contact moving between Accounts |
| Null Safety | Guards against null `AccountId` |
| Handler Separation | Logic reusable across Apex contexts |

---

## ⚙️ Prerequisites

- [ ] Salesforce org (Developer, Sandbox, or Scratch Org)
- [ ] Salesforce CLI (`sf`) installed — [Install guide](https://developer.salesforce.com/tools/salesforcecli)
- [ ] VS Code with [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)
- [ ] `Total_Contacts__c` custom field deployed on Account **before** the trigger

---

## 🚀 Usage

### 1. Authenticate to your org

```bash
sf org login web --alias my-org
````

### 2. Deploy the custom field first

```bash
sf project deploy start --source-dir force-app/main/default/objects --target-org my-org
```

### 3. Deploy classes and trigger

```bash
sf project deploy start --source-dir force-app/main/default/classes --source-dir force-app/main/default/triggers --target-org my-org
```

### 4. Or deploy everything at once

```bash
sf project deploy start --source-dir force-app --target-org my-org
```

This deploys the CQAW-based trigger and handler into your org.

### 5. Run tests

```bash
sf apex run test --class-names ContactTriggerHandler_Test --target-org my-org --result-format human
```

**Expected behavior:** Inserting or updating Contacts updates `Total_Contacts__c` on the related Account — correctly and within governor limits for any batch size up to 200.

---

## 🧠 Core Concepts You Must Know

### 1️⃣ Governor Limits Are Per Transaction, Not Per Record

| Limit          | Cap |
| -------------- | --- |
| SOQL Queries   | 100 |
| DML Statements | 150 |

Code that runs 1 SOQL per record will hit limits quickly — this is guaranteed, not an edge case.

---

### 2️⃣ Set<Id> for Deduplication

```apex
Set<Id> accountIds = new Set<Id>();
for (Contact con : Trigger.new) {
    if (con.AccountId != null) {
        accountIds.add(con.AccountId);
    }
}
```

Ensures each related record is queried only once.

---

### 3️⃣ Map<Id, SObject> for O(1) Lookup

```apex
Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Total_Contacts__c FROM Account WHERE Id IN :accountIds]);
```

Provides instant access without repeated queries.

---

### 4️⃣ Aggregate in Memory

```apex
Map<Id, Integer> counts = new Map<Id, Integer>();
for (Contact con : Trigger.new) {
    if (con.AccountId != null) {
        counts.put(con.AccountId,
            (counts.containsKey(con.AccountId) ? counts.get(con.AccountId) : 0) + 1
        );
    }
}
```

Ensures correct totals before writing.

---

### 5️⃣ Single DML Write

```apex
if (!updates.isEmpty()) {
  update updates;
}
```

Prevents unnecessary DML and ensures scalability.

---

## 🧪 How It Works

```text
Trigger fires (up to 200 records)
        │
        ▼
Collect → Query → Aggregate → Write
        │
        ▼
Result: Constant cost — 1 SOQL · 1 DML · Any batch size
```

### Scenario → Outcome

| Scenario            | Outcome                                        |
| ------------------- | ---------------------------------------------- |
| Insert 1 Contact    | Count increments by 1                          |
| Insert 200 Contacts | Count increments correctly with 1 SOQL + 1 DML |
| Multiple Accounts   | All Accounts updated in one transaction        |
| Reparent Contact    | Old and new Accounts updated                   |
| No Account          | Safely ignored                                 |

---

## 🏗 Architecture

```text
apex-bulkification-demo/
├── sfdx-project.json
├── README.md
└── force-app/main/default/
    ├── triggers/
    │   └── ContactTrigger.trigger
    ├── classes/
    │   ├── ContactTriggerHandler.cls
    │   └── ContactTriggerHandler_Test.cls
    └── objects/Account/fields/
        └── Total_Contacts__c.field-meta.xml
```

| Component  | Role                    |
| ---------- | ----------------------- |
| Trigger    | Routes logic            |
| Handler    | Implements CQAW         |
| Test Class | Validates bulk behavior |

---

## 🧯 Troubleshooting

| Issue                 | Cause               | Solution                           |
| --------------------- | ------------------- | ---------------------------------- |
| Too many SOQL queries | Query inside loop   | Move query outside using Set + Map |
| Wrong counts          | Missing aggregation | Aggregate before DML               |
| Deployment fails      | Wrong order         | Deploy objects first               |

---

## ✅ Best Practices

* Always design for **200 records** — sandbox success at 1 record is not validation
* Never use SOQL or DML inside loops
* Use Set and Map for efficient processing
* Keep triggers thin and logic in handlers
* Test for bulk scenarios

---

## 📚 Resources

* [https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm)
* [https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_order_of_execution.htm](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_order_of_execution.htm)
* [https://trailhead.salesforce.com/content/learn/modules/apex_triggers](https://trailhead.salesforce.com/content/learn/modules/apex_triggers)

---

## 🤝 Support

* Contact: Kingsley MGBAMS — [cmgbams@gmail.com](mailto:cmgbams@gmail.com)

---

## 🗓 Last Updated: 2026-03-23
