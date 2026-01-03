public with sharing class TripPicklistByRecordTypeDemo {

    // ==== CONFIG (adjust if your API names differ) ====
    private static final String SOBJECT_API_NAME = 'Trip__c';
    private static final List<String> RECORDTYPE_DEV_NAMES =
        new List<String>{ 'Business_Trip', 'Vacation' };

    private static final String CONTINENT_FIELD = 'Continent__c';
    private static final String COUNTRY_FIELD   = 'Country__c';
    private static final String CITY_FIELD      = 'City__c';
    // ================================================

    /**
     * Entry point for the training demo.
     * Run from Anonymous Apex:
     *   TripPicklistByRecordTypeDemo.run();
     */
    public static void run() {

        // 1. Retrieve record types
        List<RecordType> rts = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE SObjectType = :SOBJECT_API_NAME
            AND DeveloperName IN :RECORDTYPE_DEV_NAMES //Tip: remove the DeveloperName IN (...) filter to print for all record types if needed
            ORDER BY DeveloperName
        ];

        if (rts.isEmpty()) {
            System.debug('No Record Types found.');
            return;
        }

        // 2. Process each record type independently
        for (RecordType rt : rts) {

            System.debug('==================================================');
            System.debug('RECORD TYPE: ' + rt.DeveloperName);
            System.debug('==================================================');

            // 3. Fetch picklist values scoped to the record type
            ConnectApi.PicklistValuesCollection pvc =
                ConnectApi.RecordUi.getPicklistValuesByRecordType(
                    SOBJECT_API_NAME,
                    String.valueOf(rt.Id)
                );

            Map<String, ConnectApi.PicklistValues> fields =
                pvc.picklistFieldValues;

            ConnectApi.PicklistValues continents = fields.get(CONTINENT_FIELD);
            ConnectApi.PicklistValues countries  = fields.get(COUNTRY_FIELD);
            ConnectApi.PicklistValues cities     = fields.get(CITY_FIELD);

            // Validate presence of fields in UI API response
            if (continents == null || countries == null || cities == null) {
                System.debug('Missing one or more picklist fields in UI API response.');
                continue;
            }    

            // Defensive checks: ensure dependencies are actually configured
            if (countries.controllerValues == null || countries.controllerValues.isEmpty()) {
                System.debug(
                    'Country__c does not appear to be dependent on Continent__c ' +
                    '(no controllerValues found).'
                );
                continue;
            }
            
            if (cities.controllerValues == null || cities.controllerValues.isEmpty()) {
                System.debug(
                    'City__c does not appear to be dependent on Country__c ' +
                    '(no controllerValues found).'
                );
                continue;
            }

            System.debug('CONTINENT | COUNTRY | CITY');
            System.debug('---------------------------');

            // 4. Build the dependency tree
            for (ConnectApi.PicklistValue continent : continents.values) {

                Integer continentIndex = countries.controllerValues.get(continent.value);
                if (continentIndex == null)  {
                     continue;
                }

                for (ConnectApi.PicklistValue country : countries.values) {

                    if (!country.validFor.contains(continentIndex)) {
                        continue;
                    }

                    Integer countryIndex =
                        cities.controllerValues.get(country.value);
                    if (countryIndex == null) {
                        continue;
                    }

                    for (ConnectApi.PicklistValue city : cities.values) {

                        if (!city.validFor.contains(countryIndex)) {
                            continue;
                        }

                        System.debug(
                            continent.label + ' | ' +
                            country.label   + ' | ' +
                            city.label
                        );
                    }
                }
            }
        }
    }
}