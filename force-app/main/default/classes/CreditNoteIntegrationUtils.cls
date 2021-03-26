public class CreditNoteIntegrationUtils {
    
    public static void updateGroupAvaiableCredit(List<Id> cmpGroupIdList){
        System.debug(cmpGroupIdList);
        
        List<Account> cmpGroupList = [SELECT Id, Name, (SELECT Id, Name, TradeCreditNmb__c FROM SalesAreas__r) FROM Account WHERE Id IN :cmpGroupIdList];
        
        for(Account cmpGroup : cmpGroupList){
            System.debug(cmpGroup);
            Double groupCredit = 0;
            for(AccountAreaSales__c av : cmpGroup.SalesAreas__r){
                if(av.TradeCreditNmb__c != null)
                	groupCredit = groupCredit + av.TradeCreditNmb__c; 
				System.debug(av);
            }
            cmpGroup.AvaiableCreditNmb__c = groupCredit;
        }
        
        update cmpGroupList;
    }
    
    public static Boolean sendEmail(String creditNoteName, String emailAddress, String errorMsg){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[]{emailAddress};
        message.subject = 'Erro na transmissão da Nota de Crédito '+creditNoteName;
        String msg = 'Ocorreram um ou mais erros na transmissão da Nota de Crédito para o SAP: \n'+errorMsg;
		message.plainTextBody = msg;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
            return true;
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
            return false;
        }             
    }
    
    @AuraEnabled
    public static CreditNote__c getCreditNote(Id creditNoteId){
        return [SELECT Id, Name, ErrorMessageTxt__c, SAPCodeTxt__c, SentToSAPBln__c, Status__c FROM CreditNote__c WHERE Id = :creditNoteId];
    }
    
    @future (callout=true)
    public static void futureCreateCreditNote(Id creditNoteId){
        createCreditNote(creditNoteId);
    }
    
    @AuraEnabled
    public static void createCreditNote(Id creditNoteId){
        CreditNote__c creditNote = [SELECT Id, Name, CreatedBy.Email FROM CreditNote__c WHERE Id = :creditNoteId];
        String errorString = '';
        HTTPResponse res = SAPInteg.createCreditNote(creditNote.Id);
        if(res.getStatusCode() == 200){
            //String strTesteErro = '{"ET_BAPIRET2":{"item":{"TYPE":"E","ID":"","NUMBER":"000","MESSAGE":"a0zL0000004tSU1IAM já importada para o Escrit.vendas: 0020 Código da campanha SAP: 0000008669","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":0,"FIELD":"","SYSTEM":""}},"E_COD_CAMP":"0000008669","E_ERROR":"X","E_GUID":""}';
            //String strSucesso = '{"ET_BAPIRET2":"","E_COD_CAMP":"0000008670","E_ERROR":"","E_GUID":""}';
            //String strTesteErroMult = '{"ET_BAPIRET2":{"item":[{"TYPE":"E","ID":"","NUMBER":"000","MESSAGE":"(INIDT) - Data de início da campanha é obrigatório!","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":0,"FIELD":"","SYSTEM":""},{"TYPE":"E","ID":"","NUMBER":"000","MESSAGE":"(FIMDT) - Data de término da campanha é obrigatório!","LOG_NO":"","LOG_MSG_NO":"000000","MESSAGE_V1":"","MESSAGE_V2":"","MESSAGE_V3":"","MESSAGE_V4":"","PARAMETER":"","ROW":0,"FIELD":"","SYSTEM":""}]},"E_COD_CAMP":"0000000000","E_ERROR":"X","E_GUID":""}';
            
            Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            System.debug(res.getBody());
            //Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(strTesteErroMult);
            
			Boolean executionError = (String)jsonObj.get('E_ERROR') == 'X' ? true : false;
            
            if(!executionError){
                String SAPCode = (String)jsonObj.get('E_COD_CAMP');
                creditNote.SentToSAPBln__c = True;
                creditNote.SAPCodeTxt__c = SAPCode;
                creditNote.ErrorMessageTxt__c = '';
            }else{
				Map<String,Object> msgs = (Map<String,Object>)jsonObj.get('ET_BAPIRET2');  
                if(SAPIntegUtils.getType(msgs.get('item')) == 'Object'){
                    Map<String, Object> returnMap =(Map<String, Object>) msgs.get('item');
                    if((String)returnMap.get('TYPE') == 'E'){
                        errorString = (String)returnMap.get('MESSAGE');
                    }
                }else{
                    List<Object> listRet = (List<Object>) msgs.get('item');
                    for(Object ret : listRet){
                        Map<String, Object> returnMap = (Map<String, Object>) ret;
                        if((String)returnMap.get('TYPE') == 'E'){
                            errorString = errorString+(String)returnMap.get('MESSAGE')+'\n';
                        }
                    }                
                }
                creditNote.SentToSAPBln__c = False;
                creditNote.SAPCodeTxt__c = '';
                creditNote.ErrorMessageTxt__c = errorString;
                
                sendEmail(creditNote.Name, creditNote.CreatedBy.Email, errorString);
            }
            update creditNote;
        }
        else{
            errorString = 'Erro na comunicação com o servidor SAP. Status: '+res.getStatusCode();
            creditNote.ErrorMessageTxt__c = errorString;
            update creditNote;
            sendEmail(creditNote.Name, creditNote.CreatedBy.Email, errorString);
        }
    }    
}