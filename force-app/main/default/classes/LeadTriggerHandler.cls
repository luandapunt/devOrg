public class LeadTriggerHandler {

    public static void isBeforeInsert(List<Lead> listLead, Map<Id, Lead> oldMap){
		Map<String, List<Lead>> mapChannelLeads = new Map<String, List<Lead>>();
        
        for(Lead l : listLead){
            if(l.PVCChannelTxt__c != null && l.ChannelLkp__c == null){
                if(mapChannelLeads.containsKey(l.PVCChannelTxt__c)){
                    mapChannelLeads.get(l.PVCChannelTxt__c).add(l);
                }
                else{
                    mapChannelLeads.put(l.PVCChannelTxt__c, new List<Lead>{l});
                }
            }
        }
        
        if(!mapChannelLeads.isEmpty()){
            for(Channel__c c : [SELECT Id, CodeTxt__c FROM Channel__c WHERE CodeTxt__c IN :mapChannelLeads.keySet()]){
                for(Lead l : mapChannelLeads.get(c.CodeTxt__c)){
                    l.ChannelLkp__c = c.Id;
                }
            }
        }
        
    	List<Id> listSellerIds = new List<Id>();
        
        for(Lead l: listLead){
            listSellerIds.add(l.SellerLkp__c);
        }
        
        if(listSellerIds.size() > 0){
            Map<Id,Seller__c> mapSellers = new Map<Id,Seller__c>([SELECT Id, SellerNumberNmb__c, UserLkp__r.CPFTxt__c, CoordinatorLkp__c
                                                                  FROM Seller__c
                                                                  WHERE Id IN: listSellerIds]);
            
            for(Lead l: listLead){
                if(mapSellers.containsKey(l.SellerLkp__c)){
                    l.SellerCPFTxt__c =mapSellers.get(l.SellerLkp__c).UserLkp__r.CPFTxt__c;
                    l.CoordinatorLkp__c =mapSellers.get(l.SellerLkp__c).CoordinatorLkp__c;
                }
            }
        }
        
    }
    
    public static void isBeforeUpdate(List<Lead> listLead, Map<Id, Lead> oldMap){ 
		Map<String, List<Lead>> mapChannelLeads = new Map<String, List<Lead>>();
        
        List<String> listCNPJInTrigger = new List<String>();
        
        for(Lead l : listLead){
            if(l.PVCChannelTxt__c != null && l.PVCChannelTxt__c != oldMap.get(l.Id).PVCChannelTxt__c){
                if(mapChannelLeads.containsKey(l.PVCChannelTxt__c)){
                    mapChannelLeads.get(l.PVCChannelTxt__c).add(l);
                }
                else{
                    mapChannelLeads.put(l.PVCChannelTxt__c, new List<Lead>{l});
                }
            }
        }
        if(!mapChannelLeads.isEmpty()){
            for(Channel__c c : [SELECT Id, CodeTxt__c FROM Channel__c WHERE CodeTxt__c IN :mapChannelLeads.keySet()]){
                for(Lead l : mapChannelLeads.get(c.CodeTxt__c)){
                    l.ChannelLkp__c = c.Id;
                }
            }
        }
        
        for(Lead l: listLead){
            if(l.ConvertLeadBln__c && l.ConvertLeadBln__c != oldMap.get(l.Id).ConvertLeadBln__c){
                listCNPJInTrigger.add(l.CNPJTxt__c);
            }
        }                
        
        if(listCNPJInTrigger.size() > 0){
            List<Account> accountList = [Select Id, CNPJTxt__c, SalesOrganizationTxt__c
                                         From Account
                                         WHERE CNPJTxt__c IN :listCNPJInTrigger];
            for(Lead l : listLead){
                if(l.ConvertLeadBln__c && l.ConvertLeadBln__c != oldMap.get(l.Id).ConvertLeadBln__c){
                    for(Account acct : accountList){
                        if(acct.CNPJTxt__c==l.CNPJTxt__c && acct.SalesOrganizationTxt__c==l.SalesOrganizationTxt__c){
                            l.RegisteredInDatabaseBln__c=True;
                        }
                    }   
                }
            }
        }
        
        for(Lead l : listLead){
            String errorString = '';
            if(l.ApprovalTxt__c == 'Enviado para aprovação' && l.ApprovalTxt__c != oldMap.get(l.Id).ApprovalTxt__c){
                if(l.Street==Null || l.City==Null || l.State==Null || l.PostalCode==Null || l.Country==Null){

                    //l.addError('Campo obrigatório ausente: Endereço');
                    errorString += 'Endereço; ';
                }
                for(Schema.FieldSetMember f : SObjectType.Lead.FieldSets.RequiredFieldsStep1.getFields()){
                    if(l.get(f.getFieldPath()) == null){
                        errorString += f.getLabel() + '; ';
                    }
                }
                if(errorString != ''){
                    l.addError('Campos obrigatórios ausentes: ' + errorString);
                }
        	}
        }
        
        
        for(Lead l : listLead){
            String errorString = '';
            if(l.ApprovalTxt__c == 'Aprovado na etapa 1' && l.ApprovalTxt__c != oldMap.get(l.Id).ApprovalTxt__c){
                if(l.Street==Null || l.City==Null || l.State==Null || l.PostalCode==Null || l.Country==Null){
                    //l.addError('Campo obrigatório ausente: Endereço');
                    errorString += 'Endereço; ';
                }
                for(Schema.FieldSetMember f : SObjectType.Lead.FieldSets.RequiredFieldsStep2.getFields()){
                    if(l.get(f.getFieldPath()) == null){
                        errorString += f.getLabel() + '; ';
                    }
                }
                if(errorString != ''){
                    l.addError('Campos obrigatórios ausentes: ' + errorString);
                }
            }
        }
        
        for(Lead l : listLead){
            String errorString = '';
            if(l.ApprovalTxt__c == 'Aprovado na etapa 2' && l.ApprovalTxt__c != oldMap.get(l.Id).ApprovalTxt__c){
                if(l.Street==Null || l.City==Null || l.State==Null || l.PostalCode==Null || l.Country==Null){
                    //l.addError('Campo obrigatório ausente: Endereço');
                    errorString += 'Endereço; ';
                }
                for(Schema.FieldSetMember f : SObjectType.Lead.FieldSets.RequiredFieldsFinalStep.getFields()){
                    if(l.get(f.getFieldPath()) == null){
                        errorString += f.getLabel() + '; ';
                    }
                }
                if(errorString != ''){
                    l.addError('Campos obrigatórios ausentes: ' + errorString);
                }
            }
        }
        
        List<Id> listSellerIds = new List<Id>();
        
        for(Lead l: listLead){
            if(l.SellerLkp__c != null && l.SellerLkp__c != oldMap.get(l.Id).SellerLkp__c){
                listSellerIds.add(l.SellerLkp__c);
            }
        }
        
        if(listSellerIds.size() > 0){
            Map<Id,Seller__c> mapSellers = new Map<Id,Seller__c>([SELECT Id, SellerNumberNmb__c, UserLkp__r.CPFTxt__c, CoordinatorLkp__c
                                                                  FROM Seller__c
                                                                  WHERE Id IN: listSellerIds]);
            
            for(Lead l: listLead){
                if(mapSellers.containsKey(l.SellerLkp__c)){
                    l.SellerCPFTxt__c =mapSellers.get(l.SellerLkp__c).UserLkp__r.CPFTxt__c;
                    l.CoordinatorLkp__c =mapSellers.get(l.SellerLkp__c).CoordinatorLkp__c;
                }
            }
        }
        
    }

    public static void isAfterUpdate(List<Lead> listLead, Map<Id, Lead> oldMap){
        List<String> listCNPJInTrigger = new List<String>();
        
        for(Lead l: listLead){
            if(l.ConvertLeadBln__c && l.ConvertLeadBln__c != oldMap.get(l.Id).ConvertLeadBln__c)
                listCNPJInTrigger.add(l.CNPJTxt__c);
        }    
        
        if(listCNPJInTrigger.size() > 0){
            LeadStatus convertStatus = [SELECT Id, ApiName 
                                        FROM LeadStatus 
                                        WHERE IsConverted=true LIMIT 1];
            
            List<Account> accountList = [Select Id, CNPJTxt__c, SalesOrganizationTxt__c
                                         From Account
                                         WHERE CNPJTxt__c IN :listCNPJInTrigger];
            
            List<Database.LeadConvert> lcList = new List<Database.LeadConvert>();
            
            for(Lead l : listLead){
                if(l.ConvertLeadBln__c && l.ConvertLeadBln__c != oldMap.get(l.Id).ConvertLeadBln__c){
                    Database.LeadConvert lc = LeadConversion.convert(l,accountList,convertStatus);
                    lcList.add(lc);      
                }
            }
            List<Database.LeadConvertResult> lcrList = Database.convertLead(lcList);
            
            convertAddresses(lcrList);
            
            list<Account> listAccUpdate = new List<Account>();
            
            List<RecordType> rts = [SELECT Id FROM RecordType WHERE DeveloperName = 'SAPBusinessAccount'];
            
            if(rts.size() > 0){
                for(Database.LeadConvertResult lcr : lcrList){
                    listAccUpdate.add(new Account(Id = lcr.getAccountId(), 
                                                  RecordTypeId = rts[0].Id));
                }
                update listAccUpdate;
            }
        }
    }


    private static void convertAddresses(List<Database.LeadConvertResult> lcrList){
        Map<Id, Id> mapLeadToAcc = new Map<Id, Id>();
        List<Account> listAccToInsert = new List<Account>();
        for(Database.LeadConvertResult lcr : lcrList){
            mapLeadToAcc.put(lcr.getLeadId(), lcr.getAccountId());
        }
        
        List<Address__c> listAddress = [SELECT Id, CNPJTxt__c, 
                                        CEPTxt__c,
                                        CityTxt__c,
                                        NeighborhoodTxt__c,
                                        PartnerTypeTxt__c,
                                        PartnerNameTxt__c,
                                        PartnerStateInscriptionTxt__c,
                                        Name,
                                        LeadLkp__c,
                                        StateTxt__c,
                                        NumberTxt__c,
                                        Phone__c,
                                        LeadLkp__r.OwnerId,
                                        LeadLkp__r.Company
                                        FROM Address__c
                                       WHERE LeadLkp__c IN :mapLeadToAcc.keyset()];
        
        for(Address__c address : listAddress){
            Account accAux = new Account();
            accAux.ConvertLeadBln__c = true;
            accAux.CNPJTxt__c = address.CNPJTxt__c;
            accAux.ParentId = mapLeadToAcc.get(address.LeadLkp__c);
            accAux.BillingPostalCode = address.CEPTxt__c;
            accAux.BillingCity = address.CityTxt__c;
            accAux.BillingDistrict__c = address.NeighborhoodTxt__c;
            accAux.BillingNumber__c = address.NumberTxt__c;
            accAux.PartnerTypeTxt__c = address.PartnerTypeTxt__c;
            accAux.BillingStateCode = address.StateTxt__c;
            accAux.BillingCountryCode = 'BR';
            accAux.Name = address.PartnerNameTxt__c != null ? address.PartnerNameTxt__c : address.LeadLkp__r.Company;
            accAux.RG_StateInscriptionTxt__c = address.PartnerStateInscriptionTxt__c;
            accAux.BillingStreet = address.Name;
            accAux.Phone = address.Phone__c;
            accAux.OwnerId = address.LeadLkp__r.OwnerId;
            listAccToInsert.add(accAux);
        }
        
        List<RecordType> rts = [SELECT Id FROM RecordType WHERE DeveloperName = 'AccountPartner'];
        
        if(rts.size() > 0){
            for(Account acc : listAccToInsert){
                acc.RecordTypeId = rts[0].Id;
                system.debug(acc.CNPJTxt__c);
            }
        }
        
        insert listAccToInsert;
    }
    
}