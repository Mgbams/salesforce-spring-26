# 🚀 GraphQL Mutations Manager (Spring ’26)

![Salesforce](https://img.shields.io/badge/Salesforce-Spring%20'26-blue)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)

---

## 📋 Project Information

| Property | Value |
|-----------|--------|
| **Project Name** | GraphQL Mutations Manager |
| **Primary Technology** | LWC (Lightning Web Components) |
| **Salesforce Version** | Spring ’26 (API 66.0+) |
| **Problem It Solves** | Enables full CRUD operations using GraphQL mutations directly in LWC without Apex controllers. |
| **Key Capabilities** | Create, Update, Delete via GraphQL • Cross-component auto-refresh • Toast notifications • LMS integration |

---

## 🌟 Overview

Salesforce Spring ’26 introduces **GraphQL Mutations support in LWC (API 66.0+)**, enabling developers to perform create, update, and delete operations directly from Lightning Web Components.

Traditionally, Salesforce UI required:

- Apex for complex CRUD
- LDS for simple operations
- Manual refresh coordination across components

This project demonstrates how to:

- Use `lightning/graphql`
- Execute object-scoped mutations
- Synchronize components via Lightning Message Service (LMS)
- Eliminate unnecessary Apex layers

Why it matters:

- Cleaner architecture
- Reduced server-side code
- Easier CI/CD deployments
- More predictable UI state management

---

## ✨ Key Features

| Feature | Description |
|----------|--------------|
| OpportunityCreate | Create Opportunities using GraphQL mutation |
| OpportunityUpdate | Update StageName dynamically |
| OpportunityDelete | Delete records safely |
| Lightning Message Service | Syncs components automatically |
| Toast Notifications | Salesforce-standard success & error UX |

---

## ⚙️ Prerequisites

- [x] Salesforce **Spring ’26 org**
- [x] API Version **66.0+**
- [x] Opportunity object access
- [x] Salesforce CLI (SFDX)
- [x] VS Code + Salesforce Extensions

⚠️ **Note:** GraphQL mutations require API 66+. Earlier API versions will not support this feature.

---

## 🚀 Usage

Expected Behavior:

- Creating an Opportunity shows a toast and refreshes all components.
- Updating Stage reflects immediately across UI.
- Deleting removes the record instantly without manual refresh.

---

## 🧠 Core Concepts You Must Know

### 1️⃣ GraphQL Queries in LWC

```javascript
import { gql, graphql } from 'lightning/graphql';
```

Used to retrieve records with precise field selection.

Why use it?
- Reduced overfetching
- Cleaner data layer
- Modern API pattern

---

### 2️⃣ GraphQL Mutations

Example:

```javascript
mutation CreateOpportunity {
  uiapi {
    OpportunityCreate(input: {
      Opportunity: {
        Name: "New Deal"
        StageName: "Prospecting"
        CloseDate: "2026-12-31"
      }
    }) {
      Record {
        Id
        Name { value }
      }
    }
  }
}
```

When to use:
- CRUD without Apex
- UI-driven data changes
- Lightweight front-end logic

---

### 3️⃣ Lightning Message Service (LMS)

Used to synchronize components.

```javascript
publish(this.messageContext, OPPORTUNITY_REFRESH, {
  refresh: true
});
```

Why?
- Decoupled communication
- Enterprise-safe
- Scalable architecture

---

## 🧪 How It Works

### Flow Diagram

```
User Action
     │
     ▼
executeMutation()
     │
     ▼
Salesforce GraphQL API
     │
     ▼
publish(LMS)
     │
     ▼
Other Components refreshGraphQL()
```

### Scenario Mapping

| Scenario | System Action | Outcome |
|-----------|---------------|----------|
| Create | OpportunityCreate | Toast + Auto Refresh |
| Update | OpportunityUpdate | Stage Updated + Sync |
| Delete | OpportunityDelete | Record Removed |

---

## 🏗 Architecture

```
topics / graphql /
└── main/
    └── default/
        ├── applications/
        │   └── GraphQLApp.app-meta.xml
        │
        ├── flexipages/
        │   ├── GraphQL_Demo.flexipage-meta.xml
        │   └── GraphQL_UtilityBar.flexipage-meta.xml
        │
        ├── lwc/
        │   ├── opportunityMutationCreate/
        │   │   ├── opportunityMutationCreate.html
        │   │   ├── opportunityMutationCreate.js
        │   │   └── opportunityMutationCreate.js-meta.xml
        │   │
        │   ├── opportunityMutationUpdate/
        │   │   ├── opportunityMutationUpdate.html
        │   │   ├── opportunityMutationUpdate.js
        │   │   └── opportunityMutationUpdate.js-meta.xml
        │   │
        │   └── opportunityMutationDelete/
        │       ├── opportunityMutationDelete.html
        │       ├── opportunityMutationDelete.js
        │       └── opportunityMutationDelete.js-meta.xml
        │
        └── messageChannels/
            └── opportunityRefresh.messageChannel-meta.xml
```

### Key Components

| Component | Role |
|------------|------|
| opportunityMutationCreate | Creates records |
| opportunityMutationUpdate | Updates StageName |
| opportunityMutationDelete | Deletes records |
| opportunityRefresh | Message Channel for sync |

---

## 🧯 Troubleshooting

| Issue | Cause | Solution |
|--------|--------|-----------|
| Mutation not supported | API < 66.0 | Upgrade API version |
| No auto-refresh | LMS not subscribed | Verify `subscribe()` |
| Template expression error | Logical operator in template | Use getter instead |
| No data returned | Missing permissions | Check FLS & Object Access |

---

## ✅ Best Practices

- Always use API 66.0+
- Use getters for complex template logic
- Publish LMS only after successful mutation
- Use toast notifications for UX consistency
- Keep components loosely coupled

---

## 📚 Resources

- GraphQL API Guide  
  https://developer.salesforce.com/docs/platform/graphql

- Lightning Message Service  
  https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_message_channel

- SFDX CLI Reference  
  https://developer.salesforce.com/tools/sfdxcli

- Lightning Web Components Developer Guide  
  https://developer.salesforce.com/docs/component-library/documentation/en/lwc

---

## Support

For issues, please open a GitHub Issue.

Contact:  
**Kingsley MGBAMS**  
cmgbams@gmail.com

---
## Last Updated 2026-02-07
