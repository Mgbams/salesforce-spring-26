# 🚀 Deploy Apex Components Faster by Running Only Relevant Tests (Beta)

![Salesforce](https://img.shields.io/badge/Salesforce-Spring%20'26-blue)
![Apex](https://img.shields.io/badge/Apex-Testing-purple)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)
![Status](https://img.shields.io/badge/Feature-Beta-orange)

---

## 📋 Project Information

| Item | Details |
|-----|--------|
| **Project Name** | Deploy Apex Components Faster by Running Only Relevant Tests |
| **Primary Technology** | Apex |
| **Salesforce Version** | Spring ’26 / API 66.0 |
| **Problem It Solves** | Reduces Apex deployment time by running only tests impacted by code changes. |
| **Key Features** | • Targeted test execution <br> • Faster deployments <br> • Zero manual test selection <br> • Fine-grained test control |

---

## 🌟 Overview

Running **all Apex tests** during every deployment slows teams down, especially in large orgs.

Salesforce introduces **RunRelevantTests**, a new test level that:

- Analyzes your **deployment payload**
- Determines **which tests are actually impacted**
- Runs **only those tests**

For additional control, you can annotate test classes to:

- Always run
- Run only when specific components change

This demo shows how to use all three together.

---

## ✨ Key Features

| 🚀 Feature | 📝 Description |
|-----------|---------------|
| ⚡ RunRelevantTests | Automatically runs only relevant tests |
| 🔒 Critical Tests | Force essential tests to always run |
| 🎯 Targeted Tests | Bind tests to specific classes or triggers |
| 🛠 CI/CD Ready | Ideal for Salesforce DX pipelines |

---

## ⚙️ Prerequisites

- [ ] Salesforce org on **Spring ’26 or later**
- [ ] API version **66.0+**
- [ ] Salesforce CLI (`sf`)
- [ ] Permission to deploy Apex
- [ ] Apex tests with ≥75% org-wide coverage

⚠️ This is a **Beta / Pilot feature**.

---

---

## 🚀 Usage

### Deploy Using RunRelevantTests

```bash
sf project deploy start --source-dir force-app --test-level RunRelevantTests
```

✅ Salesforce automatically determines which tests to run  
❌ No need for `RunLocalTests` or `RunSpecifiedTests`

---

## 🧠 Core Concepts You Must Know

### 1️⃣ RunRelevantTests

- Runs only tests relevant to the deployment payload
- Scales with deployment size
- Eliminates unnecessary test execution

| Test Level | Behavior |
|-----------|----------|
| RunLocalTests | Runs all local tests |
| RunSpecifiedTests | Manually selected tests |
| **RunRelevantTests** | Automatically selected tests |

---

### 2️⃣ `@IsTest(critical=true)` — Always Run

Use when a test must always execute, regardless of what changes.

```apex
@IsTest(critical=true)
public class AccountAccessibleTest {
    @IsTest
    static void verifyAccountAccess() {
        // Critical validation logic
    }
}
```

✅ Runs in every deployment  
💡 Use sparingly for essential validations

---

### 3️⃣ `@IsTest(testFor='...')` — Run When Specific Components Change

Use to bind a test to specific Apex classes or triggers.

```apex
@IsTest(testFor='ApexClass:OpportunityDiscountService, ApexTrigger:OpportunityTrigger')
public class OpportunityDiscountServiceTest {
    @IsTest
    static void verifyDiscountLogic() {
        // Runs only when listed components change
    }
}
```

✅ Runs only if specified components are new or modified  
💡 Ideal for service-level and trigger-level tests

---

## 🧪 How Test Selection Works

```text
Deployment Payload
        ↓
Dependency Analysis
        ↓
Relevant Tests Identified
        ↓
Targeted Test Execution
```

| Scenario | Result |
|--------|--------|
| Apex class changed | Related tests run |
| Trigger changed | Trigger-bound tests run |
| No Apex changes | No Apex tests run |
| `critical=true` | Test always runs |
| `testFor` match | Test runs |

---

## 🏗 Architecture

### Project Structure

```text
runOnly-relevantTests-during-deployment/
└── main/
    └── default/
        ├── classes/
        │   ├── OpportunityDiscountService.cls
        │   ├── OpportunityDiscountServiceTest.cls
        │   ├── AccountAccessibleTest.cls
        │   ├── CoreSalesRegressionSmokeTest.cls
        │   └── DiscountFlowIntegrationTest.cls
        ├── layouts/
        ├── objects/
        │   └── Opportunity/
        └── triggers/
            └── OpportunityTrigger.trigger
        
```

---

## 🧯 Troubleshooting

| Issue | Cause | Solution |
|-----|------|---------|
| Too many tests run | High Apex coupling | Refactor dependencies |
| No tests run | No impacted Apex | Expected behavior |
| Deployment fails | Coverage < 75% | Add missing tests |
| CLI error | Outdated CLI | Update Salesforce CLI |

---

## ✅ Best Practices

- Use `critical=true` only for essential tests
- Prefer `testFor` over large shared test classes
---

## 📚 Resources

- Salesforce Help – Run Relevant Tests  
  https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_run_relevant_tests.htm&release=260&type=5

- Apex Testing Best Practices  
  https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_best_practices.htm

- Salesforce CLI  
  https://developer.salesforce.com/tools/sfdxcli

---

## 📝 License & Support

### License
MIT License — see `LICENSE.md`

### Support
- Open a GitHub Issue
- Contact **Kingsley MGBAMS**
- Email **cmgbams@gmail.com**

---

📅 **Last Updated:** 2026-01-17