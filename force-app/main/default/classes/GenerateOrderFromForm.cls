public class GenerateOrderFromForm {
    @InvocableMethod(label='Generate Order from Conference Form' description='Generates Order and Line Items from Conference Form')
    public static List<Results> generateOrder(List<Requests> requests) {
        List<Results> outputList = new List<Results>();
        
        for (Requests request : requests) {
            Results output = new Results();
            
            try {
                String objectApiName = getObjectApiName(request.recordId);
                String formMappingId = [SELECT Id, Object_Name__c FROM FormMapping__c WHERE Object_Name__c =: objectApiName LIMIT 1].Id;
                Map<String, String> fieldMappings = MappingController.getMappings(formMappingId);
                System.debug('Object API Name: ' + objectApiName); 
                System.debug('Field Mappings: ' + fieldMappings);
                Id pricebookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
                if (request.isMember == true) {
                    List<Pricebook2> memberPricebooks = [SELECT Id FROM Pricebook2 WHERE Name = 'Member Price Book' LIMIT 1];
                    if (!memberPricebooks.isEmpty()) {
                        pricebookId = memberPricebooks[0].Id;
                    }
                }
                
                Map<String, PricebookEntry> productCodeToPricebookEntry = new Map<String, PricebookEntry>();
                
                List<PricebookEntry> pricebookEntries = [
                    SELECT Id, ProductCode, UnitPrice, Product2Id, Pricebook2Id
                    FROM PricebookEntry 
                    WHERE Pricebook2Id IN (:pricebookId)
                    AND Product2Id IN :fieldMappings.values()
                ];
                
                for (PricebookEntry pbe : pricebookEntries) {
                    productCodeToPricebookEntry.put(pbe.Product2Id, pbe);
                }
                System.debug('#####productCodeToPricebookEntry: '+ productCodeToPricebookEntry);
                // Construct the Soft Record query
                String fields = new List<String>(fieldMappings.keySet()).isEmpty() 
                    ? 'Id' 
                    : 'Id, ' + String.join(new List<String>(fieldMappings.keySet()), ', ');
                
                String query = 'SELECT ' + fields + 
                    ' FROM ' + objectApiName + 
                    ' WHERE Id = \'' + request.recordId + '\'';
                
                SObject formRecord = Database.query(query);
                
                
                Id orderId;
                if (request.orderId != null) {
                    orderId = request.orderId;
                } else {
                    Order newOrder = new Order(
                        AccountId = request.accountId,
                        EffectiveDate = Date.today(),
                        Status = 'Draft',
                        Pricebook2Id = pricebookId
                    );
                    // Dynamically populate a lookup relationship to the current Soft Record
                    newOrder.put(objectApiName, request.recordId);
                    // ^^^ WARNING ^^^ 
                    // if objectApiName doesn't perfectly match the api name of the lookup 
                    // field on the order object, the code will crash.
                    
                    insert newOrder;
                    orderId = newOrder.Id;
                }
                
                List<OrderItem> orderItems = new List<OrderItem>();
                
                for (String fieldName : fieldMappings.keySet()) {
                    Decimal decimalQuantity = (Decimal)formRecord.get(fieldName);
                    if (decimalQuantity != null && decimalQuantity > 0) {
                        Integer intQuantity = decimalQuantity.intValue();
                        String productId = fieldMappings.get(fieldName);
                        PricebookEntry pbe = productCodeToPricebookEntry.get(productId);
                        
                        if (pbe != null) {
                            OrderItem item = new OrderItem(
                                OrderId = orderId,
                                Quantity = intQuantity,
                                PricebookEntryId = pbe.Id,
                                UnitPrice = pbe.UnitPrice
                            );
                            orderItems.add(item);
                        } else {
                            System.debug('Warning: No PricebookEntry found for ProductCode: ' + productId);
                        }
                    }
                }
                
                if (!orderItems.isEmpty()) {
                    insert orderItems;
                    output.result = 'success';
                    output.orderId = orderId;
                } else {
                    output.result = 'error';
                    output.errorMessage = 'No order items were created. Check if any quantities are greater than zero.';
                }
            } catch (Exception e) {
                output.result = 'error';
                output.errorMessage = 'Error processing Conference Form: ' + e.getMessage();
                System.debug('Error processing Conference Form: ' + e.getMessage());
            }
            
            outputList.add(output);
        }
        
        return outputList;
    }
    
    public static String getObjectApiName(Id recordId) {
        return recordId.getSObjectType().getDescribe().getName();
    }
    
    public class Requests {
        @InvocableVariable(required=true description='Id of the Form "soft record" to process')
        public Id recordId;
        
        @InvocableVariable(required=false description='Whether or not to apply Membership prices')
        public Boolean isMember;
        
        @InvocableVariable(required=true description='Id of the Account for the Order')
        public Id accountId;
        
        @InvocableVariable(required=false description='[Optional] Id of an existing Order to add items to')
        public Id orderId;
    }
    
    public class Results {
        @InvocableVariable(description='Result of the processing')
        public String result;
        
        @InvocableVariable(description='Error message if processing failed')
        public String errorMessage;
        
        @InvocableVariable(description='ID of the created or used Order')
        public Id orderId;
    }
}