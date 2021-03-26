public without sharing class AccountSharingUtil {
    
    public static void processSalesAreaInsert(List<AccountAreaSales__c> records, Map<Id, AccountAreaSales__c> oldRecords){
        List<AccountTeamMember> atmInsert = new List<AccountTeamMember>();
        List<AccountShare> shareInsert = new List<AccountShare>();
        List<Id> listIds = new List<Id>();
        
        List<Id> listUserIds = new List<Id>();
        List<Id> listCoordIds = new List<Id>();
        List<Id> listManagerIds = new List<Id>();
        
        for(AccountAreaSales__c av : records){
            if(av.SellerLkp__c != null)
                listIds.add(av.Id);
        }
        if(!listIds.isEmpty()){
            Map<Id, AccountAreaSales__c> avList = new Map<Id, AccountAreASales__c> ([SELECT Id, AccountLkp__c, AccountLkp__r.CodeCustomerTxt__c, AccountLkp__r.OwnerId,
                                                                                     CampaignGroupLkp__c, CampaignGroupLkp__r.MainSalesAreaLkp__c, 
                                                                                     SellerLkp__c, SellerLkp__r.UserLkp__c, 
                                                                                     SellerLkp__r.ManagerLkp__c, SellerLkp__r.CoordinatorLkp__c 
                                                                                     FROM AccountAreaSales__c WHERE Id IN :listIds]);
            for(AccountAreaSales__c av : avList.values()){
                if(av.SellerLkp__r.UserLkp__c != null)
                    listUserIds.add(av.SellerLkp__r.UserLkp__c);
                if(av.SellerLkp__r.CoordinatorLkp__c != null)
                    listCoordIds.add(av.SellerLkp__r.CoordinatorLkp__c);
                if(av.SellerLkp__r.ManagerLkp__c != null)
                    listManagerIds.add(av.SellerLkp__r.ManagerLkp__c);
            }
            
            if(!listUserIds.isEmpty()){
                Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE ID IN :listUserIds]);                                
				Map<Id, User> mapCoords = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE ID IN :listCoordIds]);
                Map<Id, User> mapManagers = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE ID IN :listManagerIds]);
                
                for(AccountAreaSales__c av : avList.values()){
                    if(mapUsers.get(av.SellerLkp__r.UserLkp__c) != null)
                        AccountSharingUtil.addAccountTeam(av, mapUsers.get(av.SellerLkp__r.UserLkp__c), atmInsert, shareInsert, true);
                	if(mapCoords.get(av.SellerLkp__r.CoordinatorLkp__c) != null)
                        AccountSharingUtil.addAccountTeam(av, mapCoords.get(av.SellerLkp__r.CoordinatorLkp__c), atmInsert, shareInsert, false);
                    if(mapManagers.get(av.SellerLkp__r.ManagerLkp__c) != null)
                        AccountSharingUtil.addAccountTeam(av, mapManagers.get(av.SellerLkp__r.ManagerLkp__c), atmInsert, shareInsert, false);                                
                }
                                
                try{
                    insert atmInsert;
                }
                catch (exception e){
                    records[0].addError(e.getMessage());
                }
            }
        }
    }
    
    public static void processAccountUpdate(List<Account> records, Map<Id, Account> oldMap, String rtCampaign){
        List<Id> listIds = new List<Id>();
        List<Id> listAccsToRemove = new List<Id>();
        Map<Id, Id> mapAreasByAcc = new Map<Id, Id>();
        List<AccountTeamMember> atmInsert = new List<AccountTeamMember>();
        List<AccountTeamMember> atmDelete = new List<AccountTeamMember>();
        List<AccountShare> shareDelete = new List<AccountShare>(); 
        List<AccountShare> shareInsert = new List<AccountShare>();
        for(Account acc : records){
            if(acc.RecordTypeId == rtCampaign && acc.MainSalesAreaLkp__c != oldMap.get(acc.Id).MainSalesAreaLkp__c){
                listIds.add(acc.Id);
                mapAreasByAcc.put(acc.Id, acc.MainSalesAreaLkp__c);
            }
        }
        if(listIds.size() > 0){
            Map<Id, AccountAreaSales__c> mapAreas = new Map<Id, AccountAreaSales__C> ([SELECT Id, CampaignGroupLkp__c, AccountLkp__r.CodeCustomerTxt__c,
                                                                                       CampaignGroupLkp__r.MainSalesAreaLkp__c, SellerLkp__r.UserLkp__c, 
                                                                                       SellerLkp__r.UserLkp__r.Profile.Name 
                                                                                       FROM AccountAreaSales__c WHERE Id IN :mapAreasByAcc.values()]);
            //Map<Id, Account> mapAccounts = new Map<Id, Account> ([SELECT Id FROM Account WHERE Id IN :listIds]);
            for(Account acc : records){
                if(acc.MainSalesAreaLkp__c != null && oldMap.get(acc.Id).MainSalesAreaLkp__c == null){
                    system.debug(mapAreas.get(acc.AccountAreaSalesLkp__c));
                    AccountSharingUtil.addAccountTeamFromAcount(acc.Id, mapAreas.get(acc.MainSalesAreaLkp__c), atmInsert, shareInsert);
                }
                else if(acc.MainSalesAreaLkp__c == null){
                    listAccsToRemove.add(acc.Id);
                }
                else {
                    system.debug(mapAreas.get(acc.MainSalesAreaLkp__c));
                    listAccsToRemove.add(acc.Id);
                    AccountSharingUtil.addAccountTeamFromAcount(acc.Id, mapAreas.get(acc.MainSalesAreaLkp__c), atmInsert, shareInsert);
                }
            }
            for(AccountShare share : [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :listAccsToRemove AND RowCause = 'Manual']){
                shareDelete.add(share);
            }
            
            for(AccountTeamMember atm : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :listAccsToRemove]){
                atmDelete.add(atm);
            }
            try{
                delete shareDelete;
                delete atmDelete;
                insert atmInsert;
                insert shareInsert;
            }
            catch (exception e){
                records[0].addError(e.getMessage());
            }
        }
    }
    
    public static void processSalesAreaUpdate(List<AccountAreaSales__c> records, Map<Id, AccountAreaSales__c> oldRecords){
        List<AccountTeamMember> atmInsert = new List<AccountTeamMember>();
        List<AccountTeamMember> atmDelete = new List<AccountTeamMember>();
        List<AccountShare> shareDelete = new List<AccountShare>(); 
        List<AccountShare> shareInsert = new List<AccountShare>();
        List<Order__c> listOrder = new List<Order__c>();
        List<Opportunity> listOpp = new List<Opportunity>();
        
        //lista de avs e contas afetadas
        List<Id> listIds = new List<Id>();
		List<Id> listAffectedAccs = new List<Id>();
        
        //usuários novos a serem inseridos
        List<Id> listUserIds = new List<Id>();
        List<Id> listCoordIds = new List<Id>();
        List<Id> listManagerIds = new List<Id>();
        
        //vendedor antigo por AV
        Map<Id, Id> sellerIdByAv = new Map<Id, Id>();   
        
        //usado para tratar grupo de campanha
        List<Id> listAccIds = new List<Id>();
        
        //usuários antigos a serem removidos
        Map<Id, Id> oldUserByAcc = new Map<Id, Id>();
        Map<Id, Id> oldCoordByAcc = new Map<Id, Id>();
        Map<Id, Id> oldManagerByAcc = new Map<Id, Id>();
        
        for(AccountAreaSales__c av : records){
            if(av.SellerLkp__c != oldRecords.get(av.Id).SellerLkp__c){
                listAffectedAccs.add(av.AccountLkp__c);
                listIds.add(av.Id);
                if(oldRecords.get(av.Id).SellerLkp__c != null)	
                    sellerIdByAv.put(av.Id, oldRecords.get(av.Id).SellerLkp__c);
            }
        }
        for(Account acc : [SELECT Id, (SELECT Id, SellerLkp__c FROM AreasDeVendas__r WHERE Id NOT IN :listIds) FROM Account WHERE Id IN :listAffectedAccs]){
            for(AccountAreaSales__c av : acc.AreasDeVendas__r){
                listIds.add(av.Id);
                sellerIdByAv.put(av.Id, av.SellerLkp__c);
            }
        }
        system.debug(listIds.size());
        if(listIds.size() > 0){
            //sellers antigos, antes do update
            Map<Id, Seller__c> mapSeller = new Map<Id, Seller__c>([SELECT Id, UserLkp__c, ManagerLkp__c, CoordinatorLkp__c FROM Seller__c WHERE Id IN :sellerIdByAv.values()]);
            
            //AVs após update
            Map<Id, AccountAreaSales__c> avList = new Map<Id, AccountAreASales__c> ([SELECT Id, AccountLkp__c, CampaignGroupLkp__c, 
                                                                                     AccountLkp__r.OwnerId,
                                                                                     AccountLkp__r.CodeCustomerTxt__c,
                                                                                     CampaignGroupLkp__r.MainSalesAreaLkp__c, 
                                                                                     SellerLkp__r.UserLkp__c, 
                                                                                     SellerLkp__r.CoordinatorLkp__c, 
                                                                                     SellerLkp__r.ManagerLkp__c, 
                                                                                     SellerLkp__c 
                                                                                     FROM AccountAreaSales__c WHERE Id IN :listIds]);
            for(AccountAreaSales__c av : avList.values()){
                system.debug('vendedor da av: ' + av.SellerLkp__r.UserLkp__c);
                //adicionar usuários para adição
                if(av.SellerLkp__r.UserLkp__c != null){
                    listUserIds.add(av.SellerLkp__r.UserLkp__c);
                }
                if(av.SellerLkp__r.CoordinatorLkp__c != null){
                    listCoordIds.add(av.SellerLkp__r.CoordinatorLkp__c);
                }
                if(av.SellerLkp__r.ManagerLkp__c != null){
                    listManagerIds.add(av.SellerLkp__r.ManagerLkp__c);
                }
                //tratativa para grupo de campanha
                if( av.CampaignGroupLkp__c != null && av.Id == av.CampaignGroupLkp__r.MainSalesAreaLkp__c){
                    system.debug('Entrou Aqui!');
                    listAccIds.add(av.CampaignGroupLkp__c);
                    oldUserByAcc.put(av.CampaignGroupLkp__c, mapSeller.get(sellerIdByAv.get(av.Id)).UserLkp__c);
                }
                listAccIds.add(av.AccountLkp__c);
                //adicionar usuários para remoção
                if(oldRecords.containsKey(av.Id)){
                    if(mapSeller.get(sellerIdByAv.get(av.id))!=null){
                        system.debug('entrou aqui');
                        oldUserByAcc.put(av.AccountLkp__c, mapSeller.get(sellerIdByAv.get(av.Id)).UserLkp__c);                    
                        if(mapSeller.get(sellerIdByAv.get(av.Id)).CoordinatorLkp__c != null)
                            oldCoordByAcc.put(av.AccountLkp__c, mapSeller.get(sellerIdByAv.get(av.Id)).CoordinatorLkp__c);
                        if(mapSeller.get(sellerIdByAv.get(av.Id)).ManagerLkp__c != null)
                            oldManagerByAcc.put(av.AccountLkp__c, mapSeller.get(sellerIdByAv.get(av.Id)).ManagerLkp__c);
                    }
                }                    
            }
            if(!listUserIds.isEmpty()){
                Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE ID IN :listUserIds OR ID IN :listCoordIds OR Id IN :listManagerIds]);
                for(AccountAreaSales__c av : avList.values()){
                    if (mapUsers.containsKey(av.SellerLkp__r.UserLkp__c)) 
                        AccountSharingUtil.addAccountTeam(av, mapUsers.get(av.SellerLkp__r.UserLkp__c), atmInsert, shareInsert, true);
                    if (mapUsers.containsKey(av.SellerLkp__r.CoordinatorLkp__c)) 
                        AccountSharingUtil.addAccountTeam(av, mapUsers.get(av.SellerLkp__r.CoordinatorLkp__c), atmInsert, shareInsert, false);
                    if(mapUsers.containsKey(av.SellerLkp__r.ManagerLkp__c))
                        AccountSharingUtil.addAccountTeam(av, mapUsers.get(av.SellerLkp__r.ManagerLkp__c), atmInsert, shareInsert, false);
                }
                for(Order__c o : [SELECT Id, AccountAreaSalesLkp__c FROM Order__c WHERE AccountAreaSalesLkp__c IN :listIds]){
                    o.OwnerId = avList.get(o.AccountAreaSalesLkp__c).SellerLkp__r.UserLkp__c;
                    listOrder.add(o);
                }
                for(Opportunity opp : [SELECT Id, Opty_Sales_Area__c FROM Opportunity WHERE Opty_Sales_Area__c IN :listIds]){
                    opp.OwnerId = avList.get(opp.Opty_Sales_Area__c).SellerLkp__r.UserLkp__c;
                    listOpp.add(opp);
                }
                
                for(AccountShare share : [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :listAccIds AND RowCause = 'Manual']){
                    system.debug('share: ' + share);
                    for(Id accId : oldUserByAcc.keySet()){
                        if(share.AccountId == accId && (share.UserOrGroupId == oldUserByAcc.get(accId) || share.UserOrGroupId == oldManagerByAcc.get(accId) || share.UserOrGroupId == oldCoordByAcc.get(accId))){
                            shareDelete.add(share);
                        }
                    }
                }
                
                for(AccountTeamMember atm : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :listAccIds]){
                    system.debug('atm: ' + atm);
                    for(Id accId : oldUserByAcc.keySet()){
                        if(atm.AccountId == accId && (atm.UserId == oldUserByAcc.get(accId) || atm.UserId == oldManagerByAcc.get(accId) || atm.UserId == oldCoordByAcc.get(accId))){
                            atmDelete.add(atm);
                        }
                    }
                }
                
                try{
                    delete shareDelete;
                    delete atmDelete;
                    insert atmInsert;
                    insert shareInsert;
                    update listOrder;
                    update listOpp;
                }
                catch (exception e){
                    records[0].addError(e.getMessage());
                }
            }
        }
        
    }
    
    public static void processSalesAreaChangeAccount(List<AccountAreaSales__c> records, Map<Id, AccountAreaSales__c> oldRecords){
        List<AccountTeamMember> atmInsert = new List<AccountTeamMember>();
        List<AccountTeamMember> atmDelete = new List<AccountTeamMember>();
        List<AccountShare> shareDelete = new List<AccountShare>(); 
        List<AccountShare> shareInsert = new List<AccountShare>();
        List<Id> listAccIds = new List<Id>();
        list<Id> listIds = new list<Id>();

        List<Id> listSellerIds = new List<Id>();
        
        Map<Id, Id> oldUserByAcc = new Map<Id, Id>();
        Map<Id, Id> oldCoordByAcc = new Map<Id, Id>();
        Map<Id, Id> oldManagerByAcc = new Map<Id, Id>();
        
        for(AccountAreaSales__c av : records){
            listSellerIds.add(av.SellerLkp__c);
            listIds.add(av.Id);
        }
        
        Map<Id, Seller__c> mapSeller = new Map<Id, Seller__c>([SELECT Id, UserLkp__c, ManagerLkp__c, CoordinatorLkp__c FROM Seller__c WHERE Id IN :listSellerIds]);
        
        
        for(AccountAreaSales__c av : records){
            oldUserByAcc.put(oldRecords.get(av.Id).AccountLkp__c, mapSeller.get(av.SellerLkp__c).UserLkp__c);
            oldCoordByAcc.put(oldRecords.get(av.Id).AccountLkp__c, mapSeller.get(av.SellerLkp__c).CoordinatorLkp__c);
            oldManagerByAcc.put(oldRecords.get(av.Id).AccountLkp__c, mapSeller.get(av.SellerLkp__c).ManagerLkp__c);
            listAccIds.add(oldRecords.get(av.Id).AccountLkp__c);
        }               
        
        Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE ID IN :oldUserByAcc.values() OR ID IN :oldCoordByAcc.values() OR Id IN :oldManagerByAcc.values()]);
        
        for(AccountAreaSales__c av : [SELECT Id, AccountLkp__c, AccountLkp__r.CodeCustomerTxt__c, AccountLkp__r.OwnerId,
                                      SellerLkp__c, SellerLkp__r.UserLkp__c, SellerLkp__r.CoordinatorLkp__c, SellerLkp__r.ManagerLkp__c,
                                      CampaignGroupLkp__c, CampaignGroupLkp__r.MainSalesAreaLkp__c
                                      FROM AccountAreaSales__c 
                                      WHERE Id IN : listIds]){
            system.debug(av.AccountLkp__c);
            if (mapUsers.containsKey(av.SellerLkp__r.UserLkp__c)) 
                AccountSharingUtil.addAccountTeam(av, mapUsers.get(av.SellerLkp__r.UserLkp__c), atmInsert, shareInsert, true);            	
            if (mapUsers.containsKey(av.SellerLkp__r.CoordinatorLkp__c)) 
                AccountSharingUtil.addAccountTeam(av, mapUsers.get(av.SellerLkp__r.CoordinatorLkp__c), atmInsert, shareInsert, false);
            if(mapUsers.containsKey(av.SellerLkp__r.ManagerLkp__c))
                AccountSharingUtil.addAccountTeam(av, mapUsers.get(av.SellerLkp__r.ManagerLkp__c), atmInsert, shareInsert, false);
        }
        
        for(AccountShare share : [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :listAccIds AND RowCause = 'Manual']){
            system.debug('share: ' + share);
            for(Id accId : oldUserByAcc.keySet()){
                if(share.AccountId == accId && (share.UserOrGroupId == oldUserByAcc.get(accId) || share.UserOrGroupId == oldManagerByAcc.get(accId) || share.UserOrGroupId == oldCoordByAcc.get(accId))){
                    shareDelete.add(share);
                }
            }
        }
        
        for(AccountTeamMember atm : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :listAccIds]){
            system.debug('atm: ' + atm);
            for(Id accId : oldUserByAcc.keySet()){
                if(atm.AccountId == accId && (atm.UserId == oldUserByAcc.get(accId) || atm.UserId == oldManagerByAcc.get(accId) || atm.UserId == oldCoordByAcc.get(accId))){
                    atmDelete.add(atm);
                }
            }
        }
        
        try{
            delete shareDelete;
            delete atmDelete;
            insert atmInsert;
            insert shareInsert;
        }
        catch (exception e){
            records[0].addError(e.getMessage());
        }
        
    }
    
    public static void processAccountInsert(List<Account> records, Map<Id, Account> oldMap, String rtCampaign){
        List<Id> listIds = new List<Id>();
        List<Id> listAccsToRemove = new List<Id>();
        Map<Id, Id> mapAreasByAcc = new Map<Id, Id>();
        List<AccountTeamMember> atmInsert = new List<AccountTeamMember>();
        List<AccountShare> shareInsert = new List<AccountShare>();
        
        for(Account acc : records){
            if(acc.RecordTypeId == rtCampaign && acc.MainSalesAreaLkp__c != null){
                listIds.add(acc.Id);
                mapAreasByAcc.put(acc.Id, acc.MainSalesAreaLkp__c);
            }
        }
        if(listIds.size() > 0){
            Map<Id, AccountAreaSales__c> mapAreas = new Map<Id, AccountAreaSales__c> ([SELECT Id, SellerLkp__r.UserLkp__c, AccountLkp__r.CodeCustomerTxt__c, SellerLkp__r.UserLkp__r.Profile.Name FROM AccountAreaSales__c WHERE Id IN :mapAreasByAcc.values()]);
            //Map<Id, Account> mapAccounts = new Map<Id, Account> ([SELECT Id FROM Account WHERE Id IN :listIds]);
            for(Account acc : records){
                AccountSharingUtil.addAccountTeamFromAcount(acc.Id, mapAreas.get(acc.MainSalesAreaLkp__c), atmInsert, shareInsert);
            }
            try{
                insert atmInsert;
                insert shareInsert;
            }
            catch (exception e){
                records[0].addError(e.getMessage());
            }
        }
    }
    
    public static void processSalesAreaDelete(List<AccountAreaSales__c> records, Map<Id, AccountAreaSales__c> oldRecords){
        Map<Id, Id> sellerIdByAv = new Map<Id, Id>();
        List<AccountTeamMember> atmDelete = new List<AccountTeamMember>();
        List<AccountShare> shareDelete = new List<AccountShare>();
        List<Id> listAccIds = new List<Id>();
        Map<Id, Id> oldUserByAcc = new Map<Id, Id>();        
        for(AccountAreaSales__c av : oldRecords.values()){
            if(av.SellerLkp__c != null)
                sellerIdByAv.put(av.Id, av.SellerLkp__c);
        }
        Map<Id, Seller__c> mapSeller = new Map<Id, Seller__c>([SELECT Id, UserLkp__c FROM Seller__c WHERE Id IN :sellerIdByAv.values()]);
        
        for(AccountAreaSales__c av : oldRecords.values()){
            if(av.SellerLkp__c != null){
                listAccIds.add(av.AccountLkp__c);
                oldUserByAcc.put(av.AccountLkp__c, mapSeller.get(sellerIdByAv.get(av.Id)).UserLkp__c);
            }
        }
        
        for(AccountShare share : [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :listAccIds]){
            for(Id accId : oldUserByAcc.keySet()){
                if(share.AccountId == accId && share.UserOrGroupId == oldUserByAcc.get(accId)){
                    shareDelete.add(share);
                }
            }
        }
        
        for(AccountTeamMember atm : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :listAccIds]){
            for(Id accId : oldUserByAcc.keySet()){
                if(atm.AccountId == accId && atm.UserId == oldUserByAcc.get(accId)){
                    atmDelete.add(atm);
                }
            }
        }
        
        try{
            //delete shareDelete;
            delete atmDelete;
        }
        catch (exception e){
            
        }
    }
    
    private static void addAccountTeam(AccountAreaSales__c av, User u, List<AccountTeamMember> atmInsert, List<AccountShare> shareInsert, Boolean addToCampaign){
        InactiveAccounts__c inactiveAcc = InactiveAccounts__c.getInstance();
        
        if(av.AccountLkp__r.CodeCustomerTxt__c != inactiveAcc.InactiveAccountsCodeTxt__c){
            Id accId = av.AccountLkp__c;
            
            AccountTeamMember atm = new AccountTeamMember(AccountId = accId, 
                                                          UserId = u.Id,
                                                          TeamMemberRole = addToCampaign ? 'Vendedor da Conta' : 'Gerente de Conta');
            atmInsert.add(atm);
            if(av.CampaignGroupLkp__r != null && av.CampaignGroupLkp__r.MainSalesAreaLkp__c == av.Id && addToCampaign){
                atm = new AccountTeamMember(AccountId = av.CampaignGroupLkp__c,
                                            UserId = u.Id,
                                            TeamMemberRole = 'Vendedor da Conta'
                                           );
                atmInsert.add(atm);
                
                if(!u.Profile.Name.contains('ADM') && u.Id != av.AccountLkp__r.OwnerId){
                    AccountShare accShare = new AccountShare(AccountId = av.CampaignGroupLkp__c, 
                                                             UserOrGroupId = av.SellerLkp__r.UserLkp__c, 
                                                             AccountAccessLevel = 'Edit',
                                                             OpportunityAccessLevel='None'
                                                            );            
                    shareInsert.add(accShare);
                }
            }
            if(!u.Profile.Name.contains('ADM') && u.Id != av.AccountLkp__r.OwnerId){
                AccountShare accShare = new AccountShare(AccountId = accId, 
                                                         UserOrGroupId = av.SellerLkp__r.UserLkp__c, 
                                                         AccountAccessLevel = 'Edit',
                                                         OpportunityAccessLevel='None'
                                                        );            
                shareInsert.add(accShare);
            }
            
        }
    }
    
    private static void addAccountTeamFromAcount(String accId, AccountAreaSales__c av, List<AccountTeamMember> atmInsert, List<AccountShare> shareInsert){
        //Id accId = av.AccountLkp__c;
        InactiveAccounts__c inactiveAcc = InactiveAccounts__c.getInstance();
        
        
    
        AccountTeamMember atm = new AccountTeamMember(AccountId = accId, 
                                                      UserId = av.SellerLkp__r.UserLkp__c,
                                                      TeamMemberRole = 'Vendedor da Conta');
        if(!av.SellerLkp__r.UserLkp__r.Profile.Name.contains('ADM')){
            AccountShare accShare = new AccountShare(AccountId = accId, 
                                                     UserOrGroupId = av.SellerLkp__r.UserLkp__c, 
                                                     AccountAccessLevel = 'Edit',
                                                     OpportunityAccessLevel='None'
                                                    );
            shareInsert.add(accShare);
        }
        atmInsert.add(atm);
        
        //AccountShare as = [SELECT Id FROM AccountShare WHERE ]
    }
}