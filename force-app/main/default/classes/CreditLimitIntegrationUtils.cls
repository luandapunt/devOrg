public class CreditLimitIntegrationUtils {
    public static void getCreditLimit(List<Id> accountIdList){
        List<Account> accList = [SELECT Id, Name, CodeCustomerTxt__c FROM Account WHERE Id IN :accountIdList];
        Map<String, Account> accMap = new Map<String, Account>();
        
        for(Account acc: accList){
        	accMap.put(acc.CodeCustomerTxt__c, acc);    
        }
        
        HTTPResponse res = SAPInteg.getCreditLimit(accountIdList);
        Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        System.debug('RECEBIDO DO SAP: ');
        System.debug(res.getBody());    
        
        Map<String,Object> creditLimitMap = (Map<String,Object>)jsonObj.get('T_ZPH_CRED_OUT');  
        if (creditLimitMap.containsKey('item')){
            if(SAPIntegUtils.getType(creditLimitMap.get('item')) == 'Object'){
                Map<String, Object> creditLimit = (Map<String, Object>) creditLimitMap.get('item');
                String accSAPCode = StringUtils.removeLeftPadZeros((String)creditLimit.get('KUNNR'));
                System.debug(creditLimit.get('KUNNR'));
                System.debug(creditLimit.get('CREDITLIMIT'));
                System.debug(creditLimit.get('TOT_COMPROMISSOS'));
                
                if(accMap.containsKey(accSAPCode)){
                    accMap.get(accSAPCode).CreditLimit__c = Decimal.valueOf((String)creditLimit.get('CREDITLIMIT'));
                    accMap.get(accSAPCode).UsedCredit__c = (Decimal)creditLimit.get('TOT_COMPROMISSOS');
                }
            }
            else{
                List<Object> creditLimitList = (List<Object>) creditLimitMap.get('item');
                for(Object creditLimitJSON: creditLimitList){
                    Map<String, Object> creditLimit = (Map<String, Object>) creditLimitJSON;
                    String accSAPCode = StringUtils.removeLeftPadZeros((String)creditLimit.get('KUNNR'));
                    System.debug(creditLimit.get('KUNNR'));
                    System.debug(creditLimit.get('CREDITLIMIT')); 
                    System.debug(creditLimit.get('TOT_COMPROMISSOS'));
                    
                    if(accMap.containsKey(accSAPCode)){
                        if(SAPIntegUtils.getType(creditLimit.get('CREDITLIMIT')) == 'String'){
                        	accMap.get(accSAPCode).CreditLimit__c = Decimal.valueOf((String)creditLimit.get('CREDITLIMIT'));    
                        }
                        else{
                            accMap.get(accSAPCode).CreditLimit__c = (Decimal)creditLimit.get('CREDITLIMIT');     
                        }
                        
                        if(SAPIntegUtils.getType(creditLimit.get('TOT_COMPROMISSOS')) == 'String'){
                        	accMap.get(accSAPCode).UsedCredit__c = Decimal.valueOf((String)creditLimit.get('TOT_COMPROMISSOS'));    
                        }
                        else{
                            accMap.get(accSAPCode).UsedCredit__c = (Decimal)creditLimit.get('TOT_COMPROMISSOS');
                        }                        
                    }                    
                }
            }
        }
        
        try{
        	upsert accMap.values();    
        }
        catch (DmlException e) {
        	System.debug(e.getTypeName()+' - '+e.getMessage()+' - '+e.getStackTraceString());
        }
    }
}