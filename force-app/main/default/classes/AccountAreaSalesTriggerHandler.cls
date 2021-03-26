public class AccountAreaSalesTriggerHandler {
    public static void doBeforeInsert(List<AccountAreaSales__c> records, Map<Id, AccountAreaSales__c> oldRecords){
        List<String> listCodes = new List<String>();
        for(AccountAreaSales__c av : records){
            if(av.InactiveBln__c){
                listCodes.add(av.CustomIdTxt__c.substring(0,6));
            }
        }
        if(listCodes.size() > 0){
            Map<string, Account> mapAccounts = new Map<string, Account>();
            InactiveAccounts__c inAcc = InactiveAccounts__c.getInstance();                        
            Account inactiveAcc = [SELECT Id, CodeCustomerTxt__c, Name FROM Account WHERE CodeCustomerTxt__c =: inAcc.InactiveAccountsCodeTxt__c];
            
            for(Account acc : [SELECT Id, CodeCustomerTxt__c FROM Account WHERE CodeCustomerTxt__c IN :listCodes]){
                mapAccounts.put(acc.CodeCustomerTxt__c, acc);
            }
            
            for(AccountAreaSales__c av : records){
                if(av.InactiveBln__c)
                    av.AccountLkp__c = inactiveAcc.Id;
                else{
                    if(mapAccounts.containsKey(av.CustomIdTxt__c.substring(0,6))){
                        av.AccountLkp__c = mapAccounts.get(av.CustomIdTxt__c.substring(0,6)).Id;
                    }
                }
            }
        }
        
        /*Map<Id, Id> idSellerByAv = new Map<Id, Id>();
        Map<Id, Id> idUserBySeller = new Map<Id, Id>();
        for(AccountAreaSales__c av : records){
            idSellerByAv.put(av.Id, av.SellerLkp__c);
        }
        for(Seller__c s : [SELECT ID, UserLkp__c FROM Seller__c WHERE ID IN: idSellerByAv.values() AND UserLkp__c != null]){
            idUserBySeller.put(s.Id, s.UserLkp__c);
        }
        for(AccountAreaSales__c av : records){
            if(idSellerByAv.containsKey(av.Id)){
                if(idUserBySeller.containsKey(idSellerByAv.get(av.Id))){
                    av.OwnerId = idUserBySeller.get(idSellerByAv.get(av.Id)); 
                }
            }
        }*/
        
        List<ID> accIdList = new List<ID>();
        List<Account> listAcc = new List<Account>(); 
        Map<Id, AccountAreaSales__c> accByAv = new Map<Id, AccountAreaSales__c>();
        for(AccountAreaSales__c av : records){
            if(av.AccountLkp__c != null){
            	accByAv.put(av.AccountLkp__c, av); 
                accIdList.add(av.AccountLkp__c);
            }
        }
        if(!accIdList.isEmpty()){
            listAcc = [Select Id, Name
                       From Account
                       Where Id IN : accIdList];
            for(Account acc : listAcc){
                if(acc.Name != null){
                    accByAv.get(acc.Id).AccountLabelTxt__c = acc.Name;
                }
            }
        }
    }
    public static void doBeforeUpdate(List<AccountAreaSales__c> records, Map<Id, AccountAreaSales__c> oldRecords){
        List<String> listCodes = new List<String>();
        for(AccountAreaSales__c av : records){
            if(av.InactiveBln__c != oldRecords.get(av.Id).InactiveBln__c){
                listCodes.add(av.CustomIdTxt__c.substring(0,6));
            }
        }
        if(listCodes.size() > 0){
            Map<string, Account> mapAccounts = new Map<string, Account>();
            InactiveAccounts__c inAcc = InactiveAccounts__c.getInstance();                        
            Account inactiveAcc = [SELECT Id, CodeCustomerTxt__c, Name FROM Account WHERE CodeCustomerTxt__c =: inAcc.InactiveAccountsCodeTxt__c];
            
            for(Account acc : [SELECT Id, CodeCustomerTxt__c FROM Account WHERE CodeCustomerTxt__c IN :listCodes]){
                mapAccounts.put(acc.CodeCustomerTxt__c, acc);
            }
            
            for(AccountAreaSales__c av : records){
                if(av.InactiveBln__c)
                    av.AccountLkp__c = inactiveAcc.Id;
                    else{
                        if(mapAccounts.containsKey(av.CustomIdTxt__c.substring(0,6))){
                            av.AccountLkp__c = mapAccounts.get(av.CustomIdTxt__c.substring(0,6)).Id;
                        }
                    }
            }		
        }
        /*Map<Id, Id> idSellerByAv = new Map<Id, Id>();
        Map<Id, Id> idUserBySeller = new Map<Id, Id>();
        for(AccountAreaSales__c av : records){
            //if(av.SellerLkp__c != oldRecords.get(av.Id).SellerLkp__c)
            	idSellerByAv.put(av.Id, av.SellerLkp__c);
        }
        for(Seller__c s : [SELECT ID, UserLkp__c FROM Seller__c WHERE ID IN: idSellerByAv.values() AND UserLkp__c != null]){
            idUserBySeller.put(s.Id, s.UserLkp__c);
        }
        for(AccountAreaSales__c av : records){
            if(idSellerByAv.containsKey(av.Id)){
                if(idUserBySeller.containsKey(idSellerByAv.get(av.Id))){
                    av.OwnerId = idUserBySeller.get(idSellerByAv.get(av.Id));
                }
            }
        }*/
    }
    public static void doBeforeDelete(List<AccountAreaSales__c> records, Map<Id, AccountAreaSales__c> oldRecords){
        
    }
    public static void doAfterInsert(List<AccountAreaSales__c> records, Map<Id, AccountAreaSales__c> oldRecords){
        AccountSharingUtil.processSalesAreaInsert(records, oldRecords);
        
    }
    public static void doAfterUpdate(List<AccountAreaSales__c> records, Map<Id, AccountAreaSales__c> oldRecords){
        AccountSharingUtil.processSalesAreaUpdate(records, oldRecords);
        
        List<AccountAreaSales__c> listAreas = new List<AccountAreaSales__c>();
        Map<Id, AccountAreaSales__c> mapOldAreaS = new Map<Id, AccountAreaSales__c>();
        
        for(AccountAreaSales__c av : records){
            if(av.AccountLkp__c != oldRecords.get(av.Id).AccountLkp__c){
                listAreas.add(av);
                mapOldAreas.put(av.Id, oldRecords.get(av.Id));
            }
        }
        if(listAreas.size() > 0){
            AccountSharingUtil.processSalesAreaChangeAccount(listAreas, mapOldAreas);
        }        

    }
    public static void doAfterDelete(List<AccountAreaSales__c> records, Map<Id, AccountAreaSales__c> oldRecords){
        AccountSharingUtil.processSalesAreaDelete(records, oldRecords);
        
    }
    
    public static void removeAreaSales(AccountAreaSales__c av){
        
        InactiveAccounts__c inAcc = InactiveAccounts__c.getInstance();                  
        
        av.AccountLkp__r = new Account(CodeCustomerTxt__c = inAcc.InactiveAccountsCodeTxt__c);                                               
        
    }
    
    public static void reAddSalesArea(AccountAreaSales__c av){
                       
        string accCode = av.CustomIdTxt__c.substring(0,6);
        
        av.AccountLkp__r = new Account(CodeCustomerTxt__c = accCode);                                            
        
    }
}