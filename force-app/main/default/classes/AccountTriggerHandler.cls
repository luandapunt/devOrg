public class AccountTriggerHandler {

    public static void doBeforeInsert(List<Account> records, Map<Id, Account> oldMap){
        //se conta for RT grupo e tiver AV principal
        //adiciona na equipe da conta o Seller.User da AV principal
    }
    public static void doBeforeUpdate(List<Account> records, Map<Id, Account> oldMap){
        
    }
    public static void doBeforeDelete(List<Account> records, Map<Id, Account> oldMap){
        
    }
    public static void doAfterInsert(List<Account> records, Map<Id, Account> oldMap){
        List<Id> accountIdList = new List<Id>();
        List<RecordType> rts = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account'];// DeveloperName = 'AccountPartner'];
        Id rtPartner;
        Id rtCampaign;
        
        for(RecordType rt : rts){
            if(rt.DeveloperName == 'AccountPartner') rtPartner = rt.Id;
            if(rt.DeveloperName == 'CampaignGroup') rtCampaign = rt.Id;
        }
        
        if(rts.size() > 0){
            for(Account acc : records){
                //System.debug('RecordType: '+acc.RecordTypeId);
                if(acc.ConvertLeadBln__c || acc.RecordTypeId == rtPartner)
                    accountIdList.add(acc.Id);
            }
            if(!System.Test.isRunningTest())
                AccountIntegrationUtils.futureCreateAccount(accountIdList);
        }
        AccountSharingUtil.processAccountInsert(records, oldMap, rtCampaign);
    }
    public static void doAfterUpdate(List<Account> records, Map<Id, Account> oldMap){
        List<RecordType> rts = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Account'];// DeveloperName = 'AccountPartner'];
        Id rtPartner;
        Id rtCampaign;
        
        for(RecordType rt : rts){
            if(rt.DeveloperName == 'AccountPartner') rtPartner = rt.Id;
            if(rt.DeveloperName == 'CampaignGroup') rtCampaign = rt.Id;
        }
        //System.debug(oldMap);
        AccountSharingUtil.processAccountUpdate(records, oldMap, rtCampaign);
        
    }
    public static void doAfterDelete(List<Account> records, Map<Id, Account> oldMap){
        
    }
    
}