public class QuoteLineTestController {
    
    @AuraEnabled
    public static SBQQ__QuoteLine__c getQuoteLine(String quoteLineId){
        return [SELECT Id, Name, SBQQ__Quantity__c FROM SBQQ__QuoteLine__c WHERE Id =: quoteLineId];
    }
    
}