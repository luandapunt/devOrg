public class LeadConversion {
    
    public static Database.LeadConvert convert(Lead l, List<Account> accountList, LeadStatus converted){
        
        Database.LeadConvert lc = new database.LeadConvert();
        
        lc.setLeadId(l.Id);
        
        for(Account acct : accountList){
            if(l.CNPJTxt__c == acct.CNPJTxt__c && l.SalesOrganizationTxt__c == acct.SalesOrganizationTxt__c){
                lc.setAccountId(acct.Id);
            }
        }
        
        lc.setDoNotCreateOpportunity(True);
        
        lc.setConvertedStatus(converted.ApiName);
        
        return lc;

        
        
    }

}