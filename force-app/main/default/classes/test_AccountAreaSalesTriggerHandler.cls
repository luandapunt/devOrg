@isTest
private class test_AccountAreaSalesTriggerHandler {
    
    @isTest static void testInsertAndUpdate(){   
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSACAcc = rt.rtmap.get('Account').get('BusinessAccountSAC');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User oldUserSeller = TestData.createUser('TestUser', null, null, prof.Id, 'testUser321@test.com');
        oldUserSeller.CommunityNickname = 'TestCommunityNicknameX';
        update oldUserSeller;
        User newUserSeller = TestData.createUser('TestUser2', null, null, prof.Id, 'testUser2321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', oldUserSeller.Id);
        Seller__c oldSeller = TestData.returnSeller('TestSeller', oldUserSeller.Id, so.Id);
        insert oldSeller;
        Account acct = TestData.createAccount('Test Account', null, null, rtSACAcc);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, null, oldSeller.Id); 
        AccountTeamMember atm = [SELECT Id, AccountId, UserId 
                                 FROM AccountTeamMember 
                                 WHERE AccountId =: acct.Id];
        System.assertEquals(oldUserSeller.Id, atm.UserId);   
        
        Seller__c newSeller = TestData.returnSeller('TestSeller2', newUserSeller.Id, so.Id);
        insert newSeller;
        salesArea.SellerLkp__c = newSeller.Id;
        update salesArea;
        atm = [SELECT Id, AccountId, UserId 
               FROM AccountTeamMember 
               WHERE AccountId =: acct.Id];
        System.assertEquals(newUserSeller.Id, atm.UserId);
        
        delete salesArea;
        AccountAreaSales__c deletedSalesArea = [Select Id, IsDeleted
                                                From AccountAreaSales__c
                                                Where Id =: salesArea.Id ALL ROWS];
        System.assertEquals(deletedSalesArea.IsDeleted, true);
    }

    @isTest static void testInsertUpdateAcc(){
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSACAcc = rt.rtmap.get('Account').get('BusinessAccountSAC');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User oldUserSeller = TestData.createUser('TestUser', null, null, prof.Id, 'testUser321@test.com');
        oldUserSeller.CommunityNickname = 'TestCommunityNicknameX';
        update oldUserSeller;
        User newUserSeller = TestData.createUser('TestUser2', null, null, prof.Id, 'testUser2321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', oldUserSeller.Id);
        Seller__c oldSeller = TestData.returnSeller('TestSeller', oldUserSeller.Id, so.Id);
        insert oldSeller;
        Account acct = TestData.createAccount('Account', null, null, rtSACAcc);
        acct.CNPJTxt__c = '623994827364987';
        update acct;
        Account acct2 = TestData.createAccount('Account2', null, null, rtSACAcc);
        acct2.CNPJTxt__c = '623984827364987';
        update acct2;
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, null, oldSeller.Id); 
        Account cmpAcc = TestData.createAccount('CampaignGroup', null, salesArea.Id, rt.rtMap.get('Account').get('CampaignGroup'));
        
        Seller__c newSeller = TestData.returnSeller('TestSeller2', newUserSeller.Id, so.Id);
        insert newSeller;
        salesArea.SellerLkp__c = newSeller.Id;
        update salesArea;
        
        AccountAreaSales__c salesArea2 = TestData.createAccountAreaSales(acct.Id, null, oldSeller.Id); 
        cmpAcc.MainSalesAreaLkp__c = salesArea2.Id;
        update cmpAcc;
        salesArea2.AccountLkp__c = acct2.Id;
        update salesArea2;
    }
    
}