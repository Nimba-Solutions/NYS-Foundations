public with sharing class MappingController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getMappings(Id formMappingId) {
        Map<String, String> mappings = new Map<String, String>();
        
        try {
            for (FormMappingDetail__c detail : [
                SELECT FieldName__c, Product__c 
                FROM FormMappingDetail__c 
                WHERE Form_Mappings__c = :formMappingId
            ]) {
                mappings.put(detail.FieldName__c, detail.Product__c);
            }
        } catch (Exception e) {
            System.debug('Error in getMappings: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving mappings: ' + e.getMessage());
        }
        
        return mappings;
    }
}