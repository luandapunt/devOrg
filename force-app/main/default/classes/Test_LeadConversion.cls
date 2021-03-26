@isTest
private class Test_LeadConversion {
    
    @isTest static void testConvertNewAccount(){
        Lead l = TestData.createLead('Nome de Teste', null);
        Address__c add = new Address__c (Name = 'Rua 1', 
                                         Leadlkp__c = l.Id, 
                                         CNPJTxt__c = l.CNPJTxt__c.substring(0,2) + l.CNPJTxt__c.substring(3,6) + l.CNPJTxt__c.substring(7,10) + l.CNPJTxt__c.substring(11,15) + l.CNPJTxt__c.substring(16,18), 
                                         CEPTxt__c = l.PostalCode,
                                         StateTxt__c = l.StateCode,
                                         PartnerStateInscriptionTxt__c = l.RG_StateInscriptionTxt__c,
                                         Phone__c = l.Phone
                                        );
        insert add;
        List<Account> accountList = new List<Account>();
        LeadStatus convertStatus = [SELECT Id, ApiName 
                                    FROM LeadStatus 
                                    WHERE IsConverted=true LIMIT 1];
        Database.LeadConvert lc = LeadConversion.convert(l,accountList,convertStatus);
        System.assertEquals(null, lc.getAccountId());
    }
    
    @isTest static void testConvertExistingAccount(){
        Lead l = TestData.createLead('Nome de Teste', null);
        Account acc = TestData.createAccount('Nome de Teste', null);
        acc.CNPJTxt__c = '44.149.954/0001-36';
        update acc;
        List<Account> accountList = new List<Account>();
        accountList.add(acc);
        LeadStatus convertStatus = [SELECT Id, ApiName 
                                    FROM LeadStatus 
                                    WHERE IsConverted=true LIMIT 1];
        Database.LeadConvert lc = LeadConversion.convert(l,accountList,convertStatus);
        System.assertEquals(acc.Id, lc.getAccountId());        
    }

}