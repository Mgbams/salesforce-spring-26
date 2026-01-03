# Topic: Get Picklist Values by Record Type (UI API / ConnectApi.RecordUi)

## What this demo does

For each specified Record Type on `Trip__c`, the demo prints valid combinations of:
Continent\_\_c | Country\_\_c | City\_\_c
using `ConnectApi.RecordUi.getPicklistValuesByRecordType`.

## Prerequisites in the org

- Custom object: `Trip__c`
- Record Types on Trip\_\_c with developer names:
  - `Business_Trip`
  - `Vacation`
- Picklist fields:
  - `Continent__c` (controlling)
  - `Country__c` (dependent on Continent\_\_c)
  - `City__c` (dependent on Country\_\_c)
- You must have permission to run Apex and access the object/fields.
- Api version of Apex class should be 66.0 or above as shown in TripPicklistByRecordTypeDemo.cls-meta.xml
- Api ersion of org should be 66.0 or above

## Deploy the topic to your org

From the project root:

### Deploy only this topic directory

```bash
sf project deploy start -o org-name --source-dir topics/get-picklist-values-by-recordtype
```

- Replace org-name with the name of your authorized org alias

## Run the demo

This demo can be executed either from **VS Code** (recommended for developers) or from the **Salesforce Developer Console**.

### Option A — Run from VS Code (recommended)

1. Open **VS Code** and make sure your Salesforce project is loaded.
2. Open the **Command Palette** using:
   - `Ctrl + Shift + P` (Windows)
   - `Cmd + Shift + P` (macOS)
3. Run the command:  
   **SFDX: Execute Anonymous Apex with Editor Contents**
4. In a new file (or an `.apex` script), paste the following code:
   ```apex
   TripPicklistByRecordTypeDemo.run();
   ```
5. Execute the script.
6. Open the generated Debug Log and inspect the output printed by the demo.

### Option B — Run from Developer Console

1. Go to **Setup** in Salesforce.
2. Open the **Developer Console**.
3. In the Developer Console menu, select **Debug → Open Execute Anonymous Window**.
4. Paste the following Apex code into the window:
   ```apex
   TripPicklistByRecordTypeDemo.run();
   ```
5. Click Execute.
6. Open the generated Debug Log.
7. Review the output printed in the log, which displays the valid Continent / Country / City combinations for each record type
