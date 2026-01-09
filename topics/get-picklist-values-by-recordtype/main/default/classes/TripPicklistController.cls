public with sharing class TripPicklistController {
    // Configuration constants
    private static final String SOBJECT_API_NAME = 'Trip__c';
    private static final String CONTINENT_FIELD = 'Continent__c';
    private static final String COUNTRY_FIELD = 'Country__c';
    private static final String CITY_FIELD = 'City__c';

    // Get available record types for Trip__c
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordTypes() {
        try {
            return [
                SELECT Id, DeveloperName, Name, Description
                FROM RecordType
                WHERE SObjectType = :SOBJECT_API_NAME
                    AND IsActive = true
                ORDER BY Name
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching record types: ' + e.getMessage());
        }
    }

    // Get picklist values for a specific record type
    @AuraEnabled
    public static List<ContinentWrapper> getPicklistValues(String recordTypeId) {
        try {
            List<ContinentWrapper> result = new List<ContinentWrapper>();
            
            // Fetch picklist values scoped to the record type
            ConnectApi.PicklistValuesCollection pvc =
                ConnectApi.RecordUi.getPicklistValuesByRecordType(
                    SOBJECT_API_NAME,
                    recordTypeId
                );

            Map<String, ConnectApi.PicklistValues> fields = pvc.picklistFieldValues;
            ConnectApi.PicklistValues continents = fields.get(CONTINENT_FIELD);
            ConnectApi.PicklistValues countries = fields.get(COUNTRY_FIELD);
            ConnectApi.PicklistValues cities = fields.get(CITY_FIELD);

            // Validate response
            if (continents == null || countries == null || cities == null) {
                return result; // Return empty list if fields not found
            }

            if (countries.controllerValues == null || countries.controllerValues.isEmpty() ||
                cities.controllerValues == null || cities.controllerValues.isEmpty()) {
                return result; // Return empty list if dependencies not configured
            }

            // Build the dependency tree
            for (ConnectApi.PicklistValue continent : continents.values) {
                Integer continentIndex = countries.controllerValues.get(continent.value);
                if (continentIndex == null) continue;

                ContinentWrapper cw = new ContinentWrapper();
                cw.label = continent.label;
                cw.value = continent.value;
                cw.countries = new List<CountryWrapper>();

                for (ConnectApi.PicklistValue country : countries.values) {
                    if (!country.validFor.contains(continentIndex)) continue;

                    Integer countryIndex = cities.controllerValues.get(country.value);
                    if (countryIndex == null) continue;

                    CountryWrapper ctw = new CountryWrapper();
                    ctw.label = country.label;
                    ctw.value = country.value;
                    ctw.cities = new List<CityWrapper>();

                    for (ConnectApi.PicklistValue city : cities.values) {
                        if (!city.validFor.contains(countryIndex)) continue;

                        CityWrapper ciw = new CityWrapper();
                        ciw.label = city.label;
                        ciw.value = city.value;
                        ciw.key = continent.value + '-' + country.value + '-' + city.value;
                        ctw.cities.add(ciw);
                    }

                    // Mark first city in each country for display purposes
                    if (!ctw.cities.isEmpty()) {
                        ctw.cities[0].isFirstCity = true;
                    }
                    cw.countries.add(ctw);
                }

                // Mark first country in each continent for display purposes
                if (!cw.countries.isEmpty()) {
                    cw.countries[0].isFirstCountry = true;
                    if (!cw.countries[0].cities.isEmpty()) {
                        cw.countries[0].cities[0].isFirstCity = true;
                    }
                }

                if (!cw.countries.isEmpty()) {
                    result.add(cw);
                }
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching picklist values: ' + e.getMessage());
        }
    }

    // Wrapper classes for hierarchical data
    public class ContinentWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public List<CountryWrapper> countries;
    }

    public class CountryWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public Boolean isFirstCountry = false;
        @AuraEnabled public List<CityWrapper> cities;
    }

    public class CityWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String key;
        @AuraEnabled public Boolean isFirstCity = false;
    }
}