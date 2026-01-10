# Salesforce Picklist Values by Record Type Demo

## 📋 Overview

This project demonstrates how to retrieve and display dependent picklist values scoped to specific record types using Salesforce's ConnectAPI UI API. The solution includes both a backend Apex demonstration and a frontend Lightning Web Component (LWC) with a visual interface.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Record Type Scoping** | Retrieve picklist values specific to each record type |
| **Dependency Resolution** | Display valid Continent → Country → City dependent picklist combinations |
| **Visual Interface** | Interactive LWC component with hierarchical data display |
| **Performance Optimized** | Uses server-side processing for efficiency |
| **Responsive Design** | Works on desktop and mobile devices |
| **Error Handling** | Comprehensive error messages and loading states |

---

## ⚙️ Prerequisites

### Salesforce Org Requirements
- **Custom Object**: `Trip__c`
- **Record Types** on Trip__c (Developer Names):
  - `Business_Trip`
  - `Vacation`
- **Dependent Picklist Fields**:
  - `Continent__c` (Controlling field)
  - `Country__c` (Dependent on Continent__c)
  - `City__c` (Dependent on Country__c)

### Technical Requirements
- **API Version**: Org API version 66.0 or above
- **Permissions**: User must have access to execute Apex and access the object/fields
- **Lightning Experience**: Must be enabled in the org

---

## 🚀 Deployment

### Method 1: Deploy Specific Directory
```bash
sf project deploy start -o <your-org-alias> --source-dir topics/get-picklist-values-by-recordtype
```

### Method 2: Deploy Entire Project
```bash
sf project deploy start -o <your-org-alias>
```

### Method 3: Using VS Code
1. Open the Salesforce Extension Pack in VS Code
2. Authorize your org
3. Right-click the `topics/get-picklist-values-by-recordtype` folder
4. Select "SFDX: Deploy Source to Org"

---

## 🎮 Running the Demo

### Option A: Apex Execution (Debug Output)

#### Using VS Code (Recommended)
1. Press `Ctrl+Shift+P` (Windows) or `Cmd+Shift+P` (macOS)
2. Select **"SFDX: Execute Anonymous Apex with Editor Contents"**
3. In the new file, paste:
   ```apex
   TripPicklistController.run();
   ```
4. Execute the script
5. Check the output in the debug logs

#### Using Developer Console
1. Navigate to **Setup → Developer Console**
2. Click **Debug → Open Execute Anonymous Window**
3. Paste and execute:
   ```apex
   TripPicklistController.run();
   ```
4. Open the debug log and check the output

### Option B: Visual Interface (LWC Component)

1. Open the **App Launcher** in your Salesforce org
2. Search for and select **"PicklistValuesByRecordType"**
3. Select a record type from the dropdown
4. View the hierarchical display of valid picklist combinations

**Expected Output:**
```
Continent       | Country        | City
------------------------------------------------
North America   | United States  | New York
                |                | Los Angeles
                |                | Chicago
                | Canada         | Toronto
                |                | Vancouver
Europe          | United Kingdom | London
                |                | Manchester
                | France         | Paris
                |                | Lyon
```

---

## 🏗️ Project Architecture

### File Structure
```
get-picklist-values-by-recordtype/main/default/
├── classes/
│   ├── TripPicklistController.cls
│   └── TripPicklistController.cls-meta.xml
├── lwc/
│   └── tripPicklistByRecordType/
│       ├── tripPicklistByRecordType.js
│       ├── tripPicklistByRecordType.html
│       ├── tripPicklistByRecordType.css
│       └── tripPicklistByRecordType.js-meta.xml
├── apps/
│   └── PicklistValuesByRecordType.app-meta.xml
├── flexipages/
│   └── PicklistValuesByRecordType_UtilityBar.flexipage-meta.xml
└── tabs/
    └── PicklistValuesByRecordType.tab-meta.xml
```

### Key Components

#### 1. Apex Controller (`TripPicklistController.cls`)
- **Primary Method**: Uses `ConnectApi.RecordUi.getPicklistValuesByRecordType()`
- **Data Structure**: Returns hierarchical wrapper classes:
  - `ContinentWrapper` → `CountryWrapper` → `CityWrapper`
- **Features**:
  - Server-side dependency resolution
  - Error handling and validation
  - Cacheable record type queries

#### 2. Lightning Web Component (`tripPicklistByRecordType`)
- **Features**:
  - Reactive UI with loading states
  - Scrollable table for large datasets
  - Dynamic record type selection
  - Error boundary handling

---

## 🔧 Technical Implementation

### Core API Method
```apex
// Retrieve picklist values scoped to a specific record type
ConnectApi.PicklistValuesCollection pvc =
    ConnectApi.RecordUi.getPicklistValuesByRecordType(
        'Trip__c',
        recordTypeId
    );
```

### Data Flow
1. **User selects** a record type in the LWC
2. **Apex controller** retrieves picklist values using ConnectAPI
3. **Dependencies resolved** using `validFor` arrays
4. **Hierarchical data** returned to LWC
5. **Table rendered** with continent/country/city relationships

### Wrapper Classes
```apex
public class ContinentWrapper {
    @AuraEnabled public String label;
    @AuraEnabled public String value;
    @AuraEnabled public List<CountryWrapper> countries;
}
```

---

## 🐛 Troubleshooting Guide

### Common Issues

| Issue | Solution |
|-------|----------|
| **"No picklist values found"** | Verify record types are active and assigned to user profiles |
| **Permission errors** | Check object/field-level security and FLS settings |
| **Missing dependencies** | Ensure dependent picklist relationships are configured |
| **API version errors** | Update class metadata to API version 66.0 or above |
| **Component not loading** | Check browser console for JavaScript errors |

### Debug Steps
1. **Enable Debug Logs** for the executing user
2. **Check Browser Console** for client-side errors
3. **Verify Apex Coverage** (>75% required for deployment)
4. **Test in Sandbox** before production deployment

---

## 📊 Best Practices Demonstrated

### ✅ Implemented
- **Separation of Concerns**: Business logic in Apex, presentation in LWC
- **Performance**: Server-side processing for large datasets
- **Error Handling**: Graceful degradation and user-friendly messages
- **Accessibility**: Semantic HTML and ARIA labels
- **Responsive Design**: Works across device sizes

### 🔄 Optimization Opportunities
1. **Pagination** for very large picklist datasets
2. **Client-side filtering** for better UX
3. **Caching strategy** for frequently accessed data
4. **Bulk processing** for multiple record types

---

## 🔗 Dependencies

| Component | Version | Purpose |
|-----------|---------|---------|
| **Salesforce Org** | API 66.0+ | Required for ConnectAPI methods |
| **Lightning Experience** | Enabled | LWC component display |
| **Custom Metadata** | Optional | For configurable field mappings |

---

## 📚 Learning Resources

### Salesforce Documentation
- [ConnectAPI.RecordUi Documentation](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_RecordUi_static_methods.htm)
- [Dependent Picklists in Apex](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Schema_PicklistEntry.htm)
- [LWC Developer Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)

### Related Topics
- Record Type-Based Picklist Values
- UI API for Picklist Retrieval
- Hierarchical Data Display in LWC
- Performance Optimization for Large Datasets

---

## 🤝 Contributing

1. **Fork** the repository
2. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

---

## 📄 License

This project is licensed for educational and demonstration purposes. All code is provided as-is without warranty.

---

## 🆘 Support

For issues or questions:
1. **Check the troubleshooting section**
2. **Review Salesforce documentation**
3. **Open an issue** in the repository
4. **Contact**: cmgbams@gmail.com

---

**Last Updated**:  January 10, 2026
**Version**: 1.0.0
**Compatibility**: Salesforce API 66.0+
```

## 🎯 Target Audience

This README is designed for:
- **Developers** implementing similar solutions
- **Administrators** configuring the demo
- **Managers** evaluating the functionality
- **Salesforce partners** demonstrating capabilities