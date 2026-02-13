# 🚀 Navigate to Flow from LWC (Spring ’26 Demo)

![Salesforce](https://img.shields.io/badge/Salesforce-Spring%20'26-blue)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)

---

## 📋 Project Information

| Property | Value |
|-----------|--------|
| **Project Name** | Navigate to Flow from LWC |
| **Primary Technology** | LWC + Flow |
| **Salesforce Version** | Spring ’26 (API 66.0) |
| **Problem It Solves** | Simplifies launching Screen Flows from Lightning Web Components without embedding `<lightning-flow>` or handling manual finish events. |
| **Key Capabilities** | • Launch Flow using `standard__flow`<br>• Pass input variables via URL state<br>• Redirect back using `retURL`<br>• Display post-flow toast notification |

---

## 🌟 Overview

Traditionally, launching a Screen Flow from an LWC required embedding the `<lightning-flow>` component and handling flow lifecycle events manually.

With **Spring ’26**, Salesforce introduces the `standard__flow` PageReference type.

This project demonstrates how to:

- Launch a Flow using `NavigationMixin`
- Pass input parameters using `flow__` state variables
- Redirect back to the originating record
- Display a success message after completion

This pattern promotes:

- Cleaner architecture  
- Separation of concerns (UI vs Business Logic)  
- Safer CI/CD deployments  
- Reduced component complexity  

---

## ✨ Key Features

| Feature | Description |
|----------|-------------|
| `standard__flow` Navigation | Launch Screen Flow using native PageReference |
| URL-Based Input Passing | Uses `flow__variableName` convention |
| Dynamic `retURL` | Generated using `NavigationMixin.GenerateUrl()` |
| Post-Flow Toast | URL state parameter triggers success notification |

---

## ⚙️ Prerequisites

- [ ] Salesforce **Spring ’26** org
- [ ] API Version 66.0+
- [ ] Lightning Experience enabled
- [ ] Salesforce CLI (latest version)
- [ ] VS Code with Salesforce Extensions
- [ ] Screen Flow created and activated
- [ ] Flow variables marked **Available for Input**

---

## 🚀 Usage

### 1️⃣ Clone Repository

```bash
git clone https://github.com/Mgbams/salesforce-spring-26/tree/main/topics
cd navigateToflowFromLWC
```

### 2️⃣ Authorize Org

```bash
sf org login web --set-default
```

### 3️⃣ Deploy Metadata

```bash
sf project deploy start
```

### 4️⃣ Add Component to Opportunity Record Page

- Navigate to Lightning App Builder
- Edit Opportunity Record Page
- Add `dealEscalationLauncher` LWC
- Save and Activate

---

### Expected Behavior

1. User enters escalation reason + discount %
2. Clicks **Request Escalation**
3. Flow launches
4. Record created based on decision logic
5. User redirected back to Opportunity
6. Success toast displayed

---

## 🧠 Core Concepts You Must Know

### 1️⃣ `standard__flow` PageReference

Used to launch Flows via navigation.

```js
this[NavigationMixin.Navigate]({
    type: 'standard__flow',
    attributes: {
        devName: 'Opportunity_Deal_Escalation_Request'
    }
});
```

**Why use it?**  
Eliminates embedded flow components and manual event handling.

---

### 2️⃣ Passing Flow Variables

State parameters use the `flow__` prefix.

```js
state: {
    flow__recordId: this.recordId,
    flow__discountPercent: this.discountPercent
}
```

Flow variable must:

- Match name exactly
- Be marked **Available for Input**

---

### 3️⃣ Return URL Handling (`retURL`)

```js
retURL: this.returnUrl + '?c__escalated=true'
```

- Not a Flow variable
- Controls redirect behavior
- Enables post-flow UI messaging

---

## 🧪 How It Works

### Execution Flow

```
Opportunity Record
       ↓
LWC Component
       ↓
NavigationMixin (standard__flow)
       ↓
Screen Flow
       ↓
Decision Element
       ↓
Create Deal Escalation Record
       ↓
Redirect via retURL
       ↓
Success Toast
```

---

### Decision Logic

| Discount % | Outcome |
|------------|----------|
| ≥ 25% | Executive Review Required |
| < 25% | Sales Manager Review |

---

## 🏗 Architecture

```
topics/
└── navigateToFlowFromLWC/
    └── main/
        └── default/
            ├── applications/
            │   └── Navigate_To_Flow_From_LWC.app-meta.xml
            │
            ├── flexipages/
            │   └── Navigate_To_Flow_From_LWC_UtilityBar.flexipage-meta.xml
            │
            ├── flows/
            │   └── Opportunity_Deal_Escalation_Request.flow-meta.xml
            │
            ├── lwc/
            │   └── dealEscalationLauncher/
            │       ├── dealEscalationLauncher.html
            │       ├── dealEscalationLauncher.js
            │       └── dealEscalationLauncher.js-meta.xml
            │
            └── objects/
                └── Deal_Escalation__c/
                    ├── Deal_Escalation__c.object-meta.xml
                    ├── fields/
                    └── listViews/
```

### Component Roles

| Layer | Responsibility |
|--------|---------------|
| LWC | UI + Navigation |
| Flow | Business Logic |
| Custom Object | Data Persistence |

---

## 🧯 Troubleshooting

| Issue | Cause | Solution |
|--------|--------|----------|
| Flow not launching | Incorrect `devName` | Verify Flow API Name |
| Variables not passed | Not marked Available for Input | Update Flow variable settings |
| No redirect | Missing `retURL` | Ensure state includes `retURL` |
| Toast repeats on refresh | URL param not cleared | Remove `c__` state parameter after display |

---

## ✅ Best Practices

- Separate UI from business logic
- Avoid hardcoded URLs
- Use `GenerateUrl()` for navigation safety
- Keep Flow API names stable
- Mark only necessary variables as input-enabled
- Follow CI/CD metadata deployment strategy

---

## 📚 Resources

- [Salesforce NavigationMixin Documentation](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_navigate)
- [PageReference Types](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/components_navigation_page_definitions.htm)
- [Customize Flow Finish Behavior](https://help.salesforce.com/s/articleView?id=sf.flow_distribute_internal_url.htm&type=5)
- [Salesforce CLI Reference](https://developer.salesforce.com/tools/sfdxcli)

---

## Support

For issues, please use **GitHub Issues**.

Maintainer: Kingsley MGBAMS
Email: cmgbams@gmail.com  

---

## Last Updated: 2026-02-13
