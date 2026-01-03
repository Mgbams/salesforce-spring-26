public with sharing class TripPicklistByRecordTypeDemo {

    // ==== CONFIG (adjust if your API names differ) ====
    private static final String SOBJECT_API_NAME = 'Trip__c';
    private static final List<String> RECORDTYPE_DEV_NAMES = new List<String>{ 'Business_Trip', 'Vacation' };

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
        List<RecordType> rts = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE SObjectType = :SOBJECT_API_NAME
              AND DeveloperName IN :RECORDTYPE_DEV_NAMES
            ORDER BY DeveloperName
        ];

        if (rts.isEmpty()) {
            System.debug('No Record Types found for ' + SOBJECT_API_NAME +
                         ' with names: ' + String.join(RECORDTYPE_DEV_NAMES, ', '));
            return;
        }

        for (RecordType rt : rts) {
            System.debug('==================================================');
            System.debug('RECORD TYPE: ' + rt.DeveloperName + ' (' + rt.Id + ')');
            System.debug('==================================================');

            ConnectApi.PicklistValuesCollection pvc =
                ConnectApi.RecordUi.getPicklistValuesByRecordType(SOBJECT_API_NAME, String.valueOf(rt.Id));

            Map<String, ConnectApi.PicklistValues> fields = pvc.picklistFieldValues;

            ConnectApi.PicklistValues continents = fields.get(CONTINENT_FIELD);
            ConnectApi.PicklistValues countries  = fields.get(COUNTRY_FIELD);
            ConnectApi.PicklistValues cities     = fields.get(CITY_FIELD);

            // Validate presence of fields in UI API response
            if (continents == null || countries == null || cities == null) {
                System.debug('Missing one or more picklist fields in UI API response.');
                System.debug('Available fields: ' + String.join(new List<String>(fields.keySet()), ', '));
                System.debug('Expected: ' + CONTINENT_FIELD + ', ' + COUNTRY_FIELD + ', ' + CITY_FIELD);
                continue;
            }

            System.debug('CONTINENT | COUNTRY | CITY');
            System.debug('---------------------------');

            // For each continent, find the country values that are valid for it,
            // and for each country, find the city values that are valid for it.
            for (ConnectApi.PicklistValue continent : continents.values) {

                Integer continentIndex = countries.controllerValues.get(continent.value);
                if (continentIndex == null) continue;

                for (ConnectApi.PicklistValue country : countries.values) {

                    if (!country.validFor.contains(continentIndex)) {
                        continue;
                    }

                    Integer countryIndex = cities.controllerValues.get(country.value);
                    if (countryIndex == null) continue;

                    for (ConnectApi.PicklistValue city : cities.values) {

                        if (!city.validFor.contains(countryIndex)) {
                            continue;
                        }

                        System.debug(continent.label + ' | ' + country.label + ' | ' + city.label);
                    }
                }
            }
        }
    }
}