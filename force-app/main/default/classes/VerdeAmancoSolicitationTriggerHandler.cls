public class VerdeAmancoSolicitationTriggerHandler {
    
    public static void isBeforeInsert(List<VerdeAmancoSolicitation__c> listVerdeAmanco, Map<Id, VerdeAmancoSolicitation__c> oldMap){
        List<Id> userAddressSelected = new List<Id>();
        List<Id> allAcct = new List<Id>();
        List<Id> allSalesAreas = new List<Id>();
        List<String> solicChannel = new List<String>();
        List<AccountAreaSales__c> totalSA = new List<AccountAreaSales__c>();
        List<AccountAreaSales__c> acct = new List<AccountAreaSales__c>();
        List<User> users = new List<User>();
        List<Channel__c> channel = new List<Channel__c>();
        
        for(VerdeAmancoSolicitation__c solic : listVerdeAmanco){
            
            if(solic.AddressTypeTxt__c=='Endereço do Solicitante'){
                userAddressSelected.add(UserInfo.getUserId());
            }
            if(solic.AddressTypeTxt__c=='Endereço do Cliente'){
                allAcct.add(solic.SalesAreaLkp__c);
            }
            allSalesAreas.add(solic.SalesAreaLkp__c);
        }
        
        if(!allSalesAreas.isEmpty()){
            totalSA=[Select Id, ChannelLkp__c, AccountLkp__c, ChannelPVCTxt__c
                       From AccountAreaSales__c
                       Where Id IN :allSalesAreas];
        }
        if(!allAcct.isEmpty()){
            acct = [Select Id, AccountLkp__c, AccountLkp__r.BillingStreet, AccountLkp__r.BillingState, AccountLkp__r.BillingCity, AccountLkp__r.BillingPostalCode
                       From AccountAreaSales__c
                       Where Id IN :allAcct];
        }
        
        
        if(!userAddressSelected.isEmpty()){
            users = [Select Id, Street, State, City, PostalCode
                                From User
                                Where Id IN :userAddressSelected];
        }

        for(VerdeAmancoSolicitation__c solic : listVerdeAmanco){
            for(AccountAreaSales__c sa : totalSA){
                if(sa.Id==solic.SalesAreaLkp__c){
                    if(sa.ChannelLkp__c!=Null){
                        solicChannel.add(sa.ChannelLkp__c);
                    }
                    else{
                        solic.addError('Só é possível criar uma Solicitação Verde Amanco se a área de vendas escolhida estiver com o campo "Canal PVC" preenchido.');
                    }
                }
            }
            
            if(solic.AddressTypeTxt__c=='Endereço do Cliente'){ 
                if(!acct.isEmpty()){
                    for(AccountAreaSales__c acc : acct){ 
                        if(acc.Id==solic.SalesAreaLkp__c){ 
                            solic.ShippingAddressTxt__c=acc.AccountLkp__r.BillingStreet;
                            solic.StateTxt__c=acc.AccountLkp__r.BillingState;
                            solic.CityTxt__c=acc.AccountLkp__r.BillingCity;
                            solic.CEPTxt__c=acc.AccountLkp__r.BillingPostalCode;
                        }
                
                    }	
                }    
            }
            
            if(solic.AddressTypeTxt__c=='Endereço do Solicitante'){
                if(!users.isEmpty()){
                    for(User us : users){                   
                        if(us.Id==UserInfo.getUserId()){                     
                            solic.ShippingAddressTxt__c=us.Street;
                            solic.StateTxt__c=us.State;
                            solic.CityTxt__c=us.City;
                            solic.CEPTxt__c=us.PostalCode;
                        }
                    }
                }
            }
            
            if(solic.RequesterNameTxt__c == null){
				solic.RequesterNameTxt__c = UserInfo.getName();
            }
            
        }

        channel = [Select Id, ActiveVerdeAmancoKitLkp__c, CodeTxt__c
                   From Channel__c
                   Where Id IN :solicChannel];
    
        for(VerdeAmancoSolicitation__c solic : listVerdeAmanco){            
            for(AccountAreaSales__c sa : totalSA){
                if(solic.SalesAreaLkp__c==sa.Id){
                    for(Channel__c cn :channel){
                        //Pega o Canal ao qual a Solicitação está ligada
                        if(sa.ChannelLkp__c==cn.Id){
                            if(cn.ActiveVerdeAmancoKitLkp__c!=Null){
                                //Preenche, com o Id do Kit Verde Amanco ligado ao Canal, o campo de pesquisa "Kit Verde Amanco" da Solicitação
                                solic.VerdeAmancoKitLkp__c = cn.ActiveVerdeAmancoKitLkp__c;
                            }
                            else{
                                solic.addError('Só é possível criar uma Solicitação Verde Amanco se o canal da área de vendas escolhida estiver com o campo "Kit Ativo" preenchido.');
                            }
                        }
                    }
                }
            }
            
        }
        
    }
    public static void isBeforeUpdate(List<VerdeAmancoSolicitation__c> listVerdeAmanco, Map<Id, VerdeAmancoSolicitation__c> oldMap){
        List<Id> salesAreaAddressSelected = new List<Id>();
        List<Id> acountAddressSelected = new List<Id>();
        List<Id> userAddressSelected = new List<Id>();
        List<AccountAreaSales__c> acct = new List<AccountAreaSales__c>();
        List<User> users = new List<User>();
        List<AccountAreaSales__c> totalSA = new List<AccountAreaSales__c>();
        List<ContentDocumentLink> files = new List<ContentDocumentLink>();
        
        for(VerdeAmancoSolicitation__c solic : listVerdeAmanco){
            
            if(solic.AddressTypeTxt__c=='Endereço do Cliente' && solic.AddressTypeTxt__c!=OldMap.get(solic.Id).AddressTypeTxt__c){
                salesAreaAddressSelected.add(solic.SalesAreaLkp__c);
                
            }
            if(solic.AddressTypeTxt__c=='Endereço do Solicitante' && solic.AddressTypeTxt__c!=OldMap.get(solic.Id).AddressTypeTxt__c){
                userAddressSelected.add(solic.CreatedById);
            }
        }
        
        if(!salesAreaAddressSelected.isEmpty()){
            totalSA = [Select Id, AccountLkp__c, AccountLkp__r.BillingStreet, AccountLkp__r.BillingState, AccountLkp__r.BillingCity, AccountLkp__r.BillingPostalCode
                       From AccountAreaSales__c
                       Where Id IN :salesAreaAddressSelected];
        }
        
        if(!userAddressSelected.isEmpty()){
            users = [Select Id, Street, State, City, PostalCode
                     From User
                     Where Id IN :userAddressSelected];
        }

        for(VerdeAmancoSolicitation__c solic : listVerdeAmanco){  
            
            if(solic.AddressTypeTxt__c=='Endereço do Cliente' && solic.AddressTypeTxt__c!=OldMap.get(solic.Id).AddressTypeTxt__c){ 
                if(!totalSA.isEmpty()){
                    for(AccountAreaSales__c acc : totalSA){ 
                        if(acc.Id==solic.SalesAreaLkp__c){ 
                            solic.ShippingAddressTxt__c=acc.AccountLkp__r.BillingStreet;
                            solic.StateTxt__c=acc.AccountLkp__r.BillingState;
                            solic.CityTxt__c=acc.AccountLkp__r.BillingCity;
                            solic.CEPTxt__c=acc.AccountLkp__r.BillingPostalCode;
                        }
                    }
                }
            }
            
            if(solic.AddressTypeTxt__c=='Endereço do Solicitante' && solic.AddressTypeTxt__c!=OldMap.get(solic.Id).AddressTypeTxt__c){
                if(!users.isEmpty()){
                    for(User us : users){                   
                        if(us.Id==solic.CreatedById){                     
                            solic.ShippingAddressTxt__c=us.Street;
                            solic.StateTxt__c=us.State;
                            solic.CityTxt__c=us.City;
                            solic.CEPTxt__c=us.PostalCode;
                        }
                    }
                }
            }
            
            if(solic.AddressTypeTxt__c=='Outro' && solic.AddressTypeTxt__c!=OldMap.get(solic.Id).AddressTypeTxt__c){
                solic.ShippingAddressTxt__c=Null;
                solic.StateTxt__c=Null;
                solic.CityTxt__c=Null;
                solic.CEPTxt__c=Null;                                     
            }
            
            if(solic.RequesterNameTxt__c == null){
				solic.RequesterNameTxt__c = UserInfo.getName();
            }
        }
        
        
        for(VerdeAmancoSolicitation__c solic : listVerdeAmanco){
            if(solic.StatusTxt__c=='Aguardando aprovação' && solic.StatusTxt__c!=OldMap.get(solic.Id).StatusTxt__c){
                files = [SELECT ContentDocumentId 
                         FROM ContentDocumentLink 
                         WHERE LinkedEntityId =: solic.Id];
                if(files.isEmpty()){
                    solic.addError('É necessário anexar imagens à solicitação antes de enviar para aprovação.');
                }
                if(files.size()>4){
                    solic.addError('O número máximo de imagens que podem ser enviadas para aprovação é 4.');
                }
            }
        }

    }
    public static void isBeforeDelete(List<VerdeAmancoSolicitation__c> listVerdeAmanco, Map<Id, VerdeAmancoSolicitation__c> oldMap){
        
    }
    public static void isAfterInsert(List<VerdeAmancoSolicitation__c> listVerdeAmanco, Map<Id, VerdeAmancoSolicitation__c> oldMap){

    }
    public static void isAfterUpdate(List<VerdeAmancoSolicitation__c> listVerdeAmanco, Map<Id, VerdeAmancoSolicitation__c> oldMap){

    }
    public static void isAfterDelete(List<VerdeAmancoSolicitation__c> listVerdeAmanco, Map<Id, VerdeAmancoSolicitation__c> oldMap){
        
    }
    

}