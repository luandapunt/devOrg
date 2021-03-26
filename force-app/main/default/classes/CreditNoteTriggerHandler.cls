public class CreditNoteTriggerHandler {
    /*public static void approvalProcessCommentCheck(List<CreditNote__c> listCreditNote){
        System.debug('####approvalProcessCommentCheck');
        System.debug('####listCreditNote');
        System.debug(listCreditNote);
         
        Map<Id, CreditNote__c> approvalStatements = new Map<Id, CreditNote__c>();
        
        for(CreditNote__c c: listCreditNote){
            // Put all objects for update that require a comment check in a map,
            // so we only have to use 1 SOQL query to do all checks
            
            if (c.ApprovalCommentCheckTxt__c == 'Requested'){ 
                approvalStatements.put(c.Id, c);
                // Reset the field value to null, 
                // so that the check is not repeated,
                // next time the object is updated
                c.ApprovalCommentCheckTxt__c = null; 
            }
        }
        System.debug(approvalStatements);
        
        if (!approvalStatements.isEmpty()){
            // UPDATE 2/1/2014: Get the most recent process instance for the approval.
            // If there are some approvals to be reviewed for approval, then
            // get the most recent process instance for each object.
            List<Id> processInstanceIds = new List<Id>{};
                
                for (Account accS : [SELECT (SELECT ID
                                             FROM ProcessInstances
                                             ORDER BY CreatedDate DESC
                                             LIMIT 1)
                                     FROM Account
                                     WHERE ID IN :approvalStatements.keySet()])
            {
                processInstanceIds.add(accS.ProcessInstances[0].Id);
            }
            System.debug(processInstanceIds);
            
            // Now that we have the most recent process instances, we can check
            // the most recent process steps for comments. 
            for (ProcessInstance pi : [SELECT TargetObjectId,
                                       (SELECT Id, StepStatus, Comments 
                                        FROM Steps
                                        ORDER BY CreatedDate DESC
                                        LIMIT 1 )
                                       FROM ProcessInstance
                                       WHERE Id IN :processInstanceIds
                                       ORDER BY CreatedDate DESC])
            {
                System.debug('##pi'+pi);
                // If no comment exists, then prevent the object from saving. 
                if ((pi.Steps[0].Comments == null || 
                     pi.Steps[0].Comments.trim().length() == 0))
                {
                    approvalStatements.get(pi.TargetObjectId).addError(
                        'Por favor forneça um comentário para aprovação/rejeição.');
                }
            } 
        }  
    }   */
    public static void isBeforeInsert(List<CreditNote__c> listCreditNote, Map<Id, CreditNote__c> oldMap){
        List<Id> accId = new List<Id>();
        List<Id> cmpId = new List<Id>();
        
        List<Account> accList = new List<Account>();
        List<CampaignAccount__c> cmpAccList = new List<CampaignAccount__c>();
        Set<String> cmpAccSet = new Set<String>();
        
        for(CreditNote__c cd : listCreditNote){
            accId.add(cd.AccountLkp__c);   
            if(cd.Type__c == 'Solicitação')
            	cmpId.add(cd.CampaignLkp__c);
        }
        if(!accId.isEmpty()){
            accList = [Select Id, MainSalesAreaLkp__c, MainSalesAreaLkp__r.SellerLkp__c, MainSalesAreaLkp__r.OwnersManagerFml__c, MainSalesAreaLkp__r.SellerLkp__r.CoordinatorLkp__c
                       From Account
                       Where Id IN :accId];
            
            if(!cmpId.isEmpty()){
                cmpAccList = [SELECT Id, Name, CampaignLkp__c, AccountLkp__c FROM CampaignAccount__c
                              WHERE CampaignLkp__c IN :cmpId AND AccountLkp__c IN :accId];               
            }
            
            accId.clear();
        }        
        
        for(CampaignAccount__c cmpAcc : cmpAccList){
            cmpAccSet.add(cmpAcc.CampaignLkp__c+';'+cmpAcc.AccountLkp__c);
        }
        
        for(CreditNote__c cd : listCreditNote){
            for(Account acc : accList){
                if(cd.AccountLkp__c==acc.Id){
                    if(acc.MainSalesAreaLkp__c==null){
                        cd.addError('Não é possível criar essa nota de crédito pois a conta associada não possui uma área de negócios principal.');
                    }
                    else if(acc.MainSalesAreaLkp__r.SellerLkp__c==null){
                        cd.addError('Não é possível criar essa nota de crédito pois a área de negócios associada não possui um vendedor.');
                    }
                    else if(acc.MainSalesAreaLkp__r.OwnersManagerFml__c!=null){
                        cd.ManagersManagerLkp__c = acc.MainSalesAreaLkp__r.OwnersManagerFml__c;
                        cd.SellerCoordinatorLkp__c = acc.MainSalesAreaLkp__r.SellerLkp__r.CoordinatorLkp__c;
                    }
                    else{
                        cd.addError('Não é possível criar essa nota de crédito pois o escritório de vendas relacionado não possui um gerenciador.');
                    }
                }
            }
            if(cd.Type__c == 'Solicitação'){
                if(!cmpAccSet.contains(cd.CampaignLkp__c+';'+cd.AccountLkp__c)){
                    cd.addError('Não é possível criar essa nota de crédito pois o agrupamento não faz parte da campanha informada');
                }
            }
        }
        if(!accList.isEmpty()){
            accList.clear();
        }
    }
    public static void isBeforeUpdate(List<CreditNote__c> listCreditNote, Map<Id, CreditNote__c> oldMap){
        System.debug(listCreditNote);
        System.debug(oldMap);
        //approvalProcessCommentCheck(listCreditNote);
        
        List<ContentDocumentLink> files = new List<ContentDocumentLink>();
        
        List<Id> accId = new List<Id>();
        List<Id> cmpId = new List<Id>();
        List<CampaignAccount__c> cmpAccList = new List<CampaignAccount__c>();
        Set<String> cmpAccSet = new Set<String>();
        
        for(CreditNote__c cd : listCreditNote){
            accId.add(cd.AccountLkp__c);   
            if(cd.Type__c == 'Solicitação')
                cmpId.add(cd.CampaignLkp__c);
        }
        if(!accId.isEmpty() && !cmpId.isEmpty()){
            cmpAccList = [SELECT Id, Name, CampaignLkp__c, AccountLkp__c FROM CampaignAccount__c
                          WHERE CampaignLkp__c IN :cmpId AND AccountLkp__c IN :accId];     
            accId.clear();
        }        
        for(CampaignAccount__c cmpAcc : cmpAccList){
            cmpAccSet.add(cmpAcc.CampaignLkp__c+';'+cmpAcc.AccountLkp__c);
        }
        
        for(CreditNote__c cd : listCreditNote){
            if(cd.Type__c == 'Solicitação' && cd.CampaignLkp__c != OldMap.get(cd.Id).CampaignLkp__c){
                if(!cmpAccSet.contains(cd.CampaignLkp__c+';'+cd.AccountLkp__c)){
                    cd.addError('Não é possível editar essa nota de crédito pois o agrupamento não faz parte da campanha informada');
                }
            }
            else if(cd.Type__c=='Solicitação' && cd.Status__c=='Solicitado' && cd.Status__c!=OldMap.get(cd.Id).Status__c){
                files = [Select Id
                         From ContentDocumentLink
                         Where LinkedEntityId =: cd.Id];
                if(files.isEmpty()){
                    cd.addError('É necessário anexar imagens à nota de crédito antes de enviar para aprovação.');
                }   
            }else if(cd.Type__c == 'Solicitação' && cd.Status__c == 'Aprovado' && cd.Status__c!=OldMap.get(cd.Id).Status__c){
                if(!System.Test.isRunningTest())
                	CreditNoteIntegrationUtils.futureCreateCreditNote(cd.Id);
            }
        }
    }
    public static void isBeforeDelete(List<CreditNote__c> listCreditNote, Map<Id, CreditNote__c> oldMap){
     
    }
    public static void isAfterInsert(List<CreditNote__c> listCreditNote, Map<Id, CreditNote__c> oldMap){
        
    }
    public static void isAfterUpdate(List<CreditNote__c> listCreditNote, Map<Id, CreditNote__c> oldMap){

    }
    public static void isAfterDelete(List<CreditNote__c> listCreditNote, Map<Id, CreditNote__c> oldMap){
        
    }

}