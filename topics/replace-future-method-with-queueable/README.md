# 🚀 Replace @future with Queueable Apex

![Apex](https://img.shields.io/badge/Apex-Testing-purple)
![SFDX](https://img.shields.io/badge/SFDX-CLI-green)

---

## 📋 Project Information

| Attribute | Value |
|----------|------|
| Project Name | Replace @future with Queueable |
| Technology | Apex |
| Problem | @future methods limit async processing (no objects, no chaining, no observability) |
| Key Features | Queueable jobs, chaining, payload pattern, finalizers, retry logic |

---

## 🌟 Overview

This project demonstrates how to replace legacy `@future` methods with **Queueable Apex**, a more flexible and controllable asynchronous pattern.

It focuses on:
- Passing complex objects instead of IDs
- Chaining async jobs safely
- Adding retry logic using Finalizers

This matters because modern Salesforce architectures require:
- Observability (job tracking)
- Composability (multi-step workflows)
- Reduced redundancy (no re-querying)

---

## ✨ Key Features

| Feature | Description |
|--------|------------|
| Queueable Jobs | Execute async logic with full object support |
| Job Chaining | Sequential processing using one child job per execution |
| Payload Pattern | Pass structured data between jobs |
| Finalizers | Post-execution handling and retry logic |
| Monitoring | Track jobs via `AsyncApexJob` |

---

## ⚙️ Prerequisites

- [ ] Salesforce CLI (`sf`)
- [ ] VS Code + Salesforce Extensions
- [ ] Apex execution permissions

⚠️ **Note:** Ensure async Apex limits are understood before use.

---

## 🚀 Usage

### Deploy the Project

```bash
sf project deploy start
```

### Run Example Job

```apex
List<Account> accs = [SELECT Id, Name FROM Account LIMIT 10];
System.enqueueJob(new AccountQueueable(accs));
```

### Expected Behavior

- Accounts are updated asynchronously
- Job appears in `AsyncApexJob`
- Finalizer handles success/failure

---

## 🧠 Core Concepts You Must Know

### 1️⃣ Queueable Apex

```apex
public class AccountQueueable implements Queueable {
    public void execute(QueueableContext context) {
        // Async logic
    }
}
```

**Use when:**
- You need async execution with complex objects
- You require job tracking

---

### 2️⃣ Job Chaining

```apex
System.enqueueJob(new Step2Job());
```

**Rule:** Only one child job per execution

**Use when:**
- Sequential workflows are required

---

### 3️⃣ Finalizers

```apex
System.attachFinalizer(this);
```

```apex
if (context.getResult() == ParentJobResult.UNHANDLED_EXCEPTION) {
    System.enqueueJob(new RetryJob());
}
```

**Use when:**
- You need retry logic or cleanup after execution

---

## 🧪 How It Works

### Flow Diagram

```text
Trigger / Service
    |
    v
enqueue Queueable Job
    |
    v
execute()
    |
    +--> business logic
    +--> enqueue next job (optional)
    |
    v
Finalizer executes
    |
    +--> success
    +--> failure → retry (guarded)
```

### Scenarios

| Scenario | Outcome |
|---------|--------|
| Success | Data updated |
| Failure | Finalizer retries |
| Max retries reached | Escalation/logging |

---

## 🏗 Architecture

```text
force-app/
└── main/default/
    └── classes/
        ├── AccountQueueable.cls
        ├── Step1Job.cls
        ├── Step2Job.cls
        ├── SyncPayload.cls
        ├── AccountJobWithFinalizer.cls
        └── tests/
            ├── AccountQueueableTest.cls
            └── AccountJobWithFinalizerTest.cls
```

**Key Components**

- **Queueable Classes** → Async execution units  
- **Payload Class** → Data contract between jobs  
- **Finalizer** → Retry & post-processing  

---

## 🧯 Troubleshooting

| Issue | Cause | Solution |
|------|------|---------|
| Job not executing | Missing `Test.stopTest()` | Add in tests |
| Multiple jobs fail | Exceeded limits | Reduce batch size |
| Infinite retries | Missing guard | Add `retryCount` check |
| Callout failure | Missing interface | Implement `Database.AllowsCallouts` |

---

## ✅ Best Practices

- Pass objects instead of IDs when possible  
- Guard retry logic with a counter  
- Keep Queueable jobs small and focused  
- Use `AsyncApexJob` for monitoring  
- Avoid chaining for parallel processing  

---

## 📚 Resources

- https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm
- https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_invoking_future_methods.htm
- https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs_chained.htm
- https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_finalizers.htm
- https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_flex_queue.htm

---

## Support

- Contact: Kingsley MGBAMS — cmgbams@gmail.com 

---

## Last Updated: 2026-04-19