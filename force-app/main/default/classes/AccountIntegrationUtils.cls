public class AccountIntegrationUtils {
    
    public static void associatePartner(List<Id> accountIdList){
        List<Account> partnerList = [SELECT Id, Name, CodeCustomerTxt__c, RecordType.DeveloperName, ParentId, AssociatedToIssuerBln__c  
                                     FROM Account WHERE Id IN :accountIdList AND RecordType.DeveloperName = 'AccountPartner'];
        System.debug('PARTNER LIST:');
        System.debug(partnerList);       
        for(Account acc: partnerList){
            HTTPResponse res = SAPInteg.associatePartner(acc.ParentId, acc.Id);
            Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            System.debug('RECEBIDO DO SAP: ');
            System.debug(res.getBody());   
            
            if((String)jsonObj.get('E_KUNNR') != ''){
                acc.AssociatedToIssuerBln__c = true;
            }else{
                Map<String, Object> messages = (Map<String, Object>)jsonObj.get('T_BAPIRET2');
                
                if(SAPIntegUtils.getType(messages.get('item')) == 'Object'){
                    Map<String, Object> msg = (Map<String, Object>) messages.get('item');
                    if((String)msg.get('TYPE') == 'E'){
                        system.debug('ERRO: ' + (String)msg.get('MESSAGE'));
                    }
                }
                else{
                    List<Object> msgListJSON = (List<Object>) messages.get('item');
                    for(Object msgJSON: msgListJSON){
                        Map<String, Object> msg = (Map<String, Object>) msgJSON;
                        if(msg.get('TYPE')=='E'){
                            system.debug('ERRO: ' + (String)msg.get('MESSAGE'));
                        }
                    }
                }       
            }   
        }
        
        update partnerList;
    }
    
	public static void createAccount(Id accountId){
        String response = '{"E_KUNNR":"0000218707","GUID":"","T_BAPIRET2":{"item":[{"TYPE":"S","ID":"F2","NUMBER":247,"MESSAGE":"O cliente 0000218707 foi criado","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"0000218707","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":0,"FIELD":"","SYSTEM":"0000218707"}]}}';
   		String response2 = '{"E_KUNNR":"","GUID":"","T_BAPIRET2":{"item":[{"TYPE":"E","ID":"CVI_API","NUMBER":"003","MESSAGE":"Zona Nielsen: é campo obrigatório","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"Zona Nielsen","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":1,"FIELD":"NIELS","SYSTEM":""},{"TYPE":"E","ID":"00","NUMBER":"058","MESSAGE":"Entrada 2190 111510001 não existente em SKB1 (verificar a entrada)","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":2190,"MESSAGE_V2":111510001,"MESSAGE_V3":"","MESSAGE_V4":"SKB1","PARAMETER":"","ROW":1,"FIELD":"AKONT","SYSTEM":""},{"TYPE":"E","ID":"CVI_API","NUMBER":"001","MESSAGE":"SKB1-AKONT: valor inválido (verificação de chave externa falhou)","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"SKB1-AKONT","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":1,"FIELD":"AKONT","SYSTEM":""},{"TYPE":"E","ID":"F2","NUMBER":"081","MESSAGE":"Conta do Razão 111510001 não empresa 2190 não existe","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":111510001,"MESSAGE_V2":2190,"MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":1,"FIELD":"AKONT","SYSTEM":""},{"TYPE":"E","ID":"CVI_API","NUMBER":"007","MESSAGE":"KNB1-AKONT: controle de plausibilidade falhou","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"KNB1-AKONT","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":1,"FIELD":"AKONT","SYSTEM":""}]}}';        
        
        Account acc = new Account(id = accountId);
        
        HTTPResponse res = SAPInteg.createAccount(accountId);
        
        if(res.getStatusCode() == 200){
            Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            System.debug('RECEBIDO DO SAP: ');
            System.debug(res.getBody());    
            
            if((String)jsonObj.get('E_KUNNR') != ''){
                String accSAPCode = StringUtils.removeLeftPadZeros((String)jsonObj.get('E_KUNNR'));  
                System.debug(accSAPCode);
                acc.CodeCustomerTxt__c = accSAPCode;
                acc.IntegrationError__c = '';  
                acc.IntegrationStatus__c = '200';
                update acc;
            }else{
                String errorLog = '';
                Map<String,Object> messages = (Map<String,Object>)jsonObj.get('T_BAPIRET2');  
                
                if(SAPIntegUtils.getType(messages.get('item')) == 'Object'){
                    Map<String, Object> msg = (Map<String, Object>) messages.get('item');
                    if((String)msg.get('TYPE') == 'E'){
                        system.debug('ERRO: ' + (String)msg.get('MESSAGE'));
                        errorLog = errorLog + (String)msg.get('MESSAGE')+'<br/>';
                    }
                }
                else{
                    List<Object> msgListJSON = (List<Object>) messages.get('item');
                    for(Object msgJSON: msgListJSON){
                        Map<String, Object> msg = (Map<String, Object>) msgJSON;
                        if(msg.get('TYPE')=='E'){
                            system.debug('ERRO: ' + (String)msg.get('MESSAGE'));
                            errorLog = errorLog + (String)msg.get('MESSAGE')+'<br/>';
                        }
                    }
                }
                acc.IntegrationStatus__c = '400';
                acc.IntegrationError__c = errorLog;  
                System.debug('###IntegrationStatus: '+acc.IntegrationError__c);
                update acc;
            }            
        }else{
            String errorLog = '';
            errorLog = res.getStatusCode() + ' - ' + res.getStatus()+'\n\n'+res.getBody();
            acc.IntegrationStatus__c = '400';
            acc.IntegrationError__c = errorLog;
            update acc;
        }
    }   
	
    public static void createAccount(List<Id> accountIdList){
        List<Account> accountList = [SELECT Id, Name, CodeCustomerTxt__c, RecordType.DeveloperName, ParentId FROM Account WHERE Id IN :accountIdList];
        Map<Id, Account> accMap = new Map<Id, Account>();
        
        System.debug('ACCOUNT LIST:');
        System.debug(accountList);
        
        for(Account acc: accountList){
            System.debug(acc.RecordType.DeveloperName);
            if(acc.RecordType.DeveloperName == 'AccountPartner'){
                createPartner(acc.Id, acc.ParentId);
            }else{
                createAccount(acc.Id);
            }
        }
    }
	
    public static void createPartner(Id accountId, Id parentId){
        Account acc = new Account(id = accountId);
        
        HTTPResponse res = SAPInteg.createPartner(accountId);
        Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        System.debug('RECEBIDO DO SAP: ');
        System.debug(res.getBody());    
        
        if(res.getStatusCode() == 200){
            if((String)jsonObj.get('E_KUNNR') != ''){
                String accSAPCode = StringUtils.removeLeftPadZeros((String)jsonObj.get('E_KUNNR'));  
                System.debug(accSAPCode);
                acc.CodeCustomerTxt__c = accSAPCode;
                acc.IntegrationStatus__c = '200';          
                acc.IntegrationError__c = '';            
                update acc;
            }else{
                String errorLog = '';
                Map<String,Object> messages = (Map<String,Object>)jsonObj.get('T_BAPIRET2');  
                
                if(SAPIntegUtils.getType(messages.get('item')) == 'Object'){
                    Map<String, Object> msg = (Map<String, Object>) messages.get('item');
                    if((String)msg.get('TYPE') == 'E'){
                        system.debug('ERRO: ' + (String)msg.get('MESSAGE'));
                        errorLog = errorLog + (String)msg.get('MESSAGE')+'<br/>';
                        acc.IntegrationStatus__c = '400';
                        acc.IntegrationError__c = errorLog;   
                    }
                }
                else{
                    List<Object> msgListJSON = (List<Object>) messages.get('item');
                    for(Object msgJSON: msgListJSON){
                        Map<String, Object> msg = (Map<String, Object>) msgJSON;
                        if(msg.get('TYPE')=='E'){
                            system.debug('ERRO: ' + (String)msg.get('MESSAGE'));
                            errorLog = errorLog + (String)msg.get('MESSAGE')+'<br/>';
                            acc.IntegrationStatus__c = '400';
                            acc.IntegrationError__c = errorLog;   
                        }
                    }
                }
                update acc;
            }            
        }else{
            String errorLog = '';
            acc.IntegrationStatus__c = '400';
            errorLog = res.getStatusCode() + ' - ' + res.getStatus();
            update acc;           
        }
    }    
    
    @future (callout=true)
    public static void futureCreateAccount(List<Id> accountIdList){
        createAccount(accountIdList);
    }
     
    @AuraEnabled
    public static Account getAccount(Id accountId) {
        return [SELECT Name, IntegrationError__c FROM Account WHERE Id = :accountId];
    }
	
    @AuraEnabled
    public static void resendAccount(Id accountId){
        System.debug('####resendAccount: '+accountId);
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(accountId);
        futureCreateAccount(accountIdList);
    }
}