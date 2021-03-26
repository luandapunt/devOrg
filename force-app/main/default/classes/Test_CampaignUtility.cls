@isTest
private class Test_CampaignUtility {
    @isTest static void testResetCalculation(){
        Campaign__c cmp = TestData.createCompleteCampaign(true);
        
        CampaignUtility.resetCalculation(cmp.Id);
        
        List<AccountGoal__c> accGoalList = [SELECT Id, CreatedCreditNote__c, Status__c, FlexValueNmb__c, Realized__c, CalculationBasis__c FROM ACCOUNTGOAL__C WHERE CAMPAIGNLKP__R.ID = :cmp.Id];
        
        for (AccountGoal__c accGoal : accGoalList){
            System.debug(accGoal);
            System.assertEquals(false, accGoal.CreatedCreditNote__c);
            //System.assertEquals('', accGoal.Status__c);
            System.assertEquals(0, accGoal.FlexValueNmb__c);
            System.assertEquals(0, accGoal.Realized__c);
            System.assertEquals(0, accGoal.CalculationBasis__c);
        }
    }
    
    @isTest static void testCleanAccountGoals(){
        Campaign__c cmp = TestData.createCompleteCampaign(true);
        
        CampaignUtility.cleanAccountGoals(cmp.Id);
        
        List<AccountGoal__c> accGoalList = [SELECT Id, CreatedCreditNote__c, Status__c, FlexValueNmb__c, Realized__c, CalculationBasis__c FROM ACCOUNTGOAL__C WHERE CAMPAIGNLKP__R.ID = :cmp.Id];
        
        for (AccountGoal__c accGoal : accGoalList){
            System.debug(accGoal);
            System.assertEquals(false, accGoal.CreatedCreditNote__c);
            //System.assertEquals('', accGoal.Status__c);
            System.assertEquals(0, accGoal.FlexValueNmb__c);
            System.assertEquals(0, accGoal.CalculationBasis__c);
        }
    }
    
    @isTest static void testDeleteCampaignGoals(){
        Campaign__c cmp = TestData.createCompleteCampaign(true);
        CampaignUtility.deleteCampaignGoals(cmp.Id);
        List<AccountGoal__c> accGoalList = [SELECT Id, CreatedCreditNote__c, Status__c, FlexValueNmb__c, Realized__c, CalculationBasis__c FROM ACCOUNTGOAL__C WHERE CAMPAIGNLKP__R.ID = :cmp.Id];
        System.assertEquals(0, accGoalList.size());
    }
      
    @isTest static void testGenerateCampaignGoals(){
        Campaign__c cmp = TestData.createCompleteCampaign(false);
        CampaignUtility.generateCampaignGoals(cmp.Id);        
        List<AccountGoal__c> accGoalList = [SELECT Id, Name FROM ACCOUNTGOAL__C WHERE CAMPAIGNLKP__R.ID = :cmp.Id];
        System.assertEquals(4, accGoalList.size());
    }
    
    @isTest static void testGetAccountGoalList(){
        Campaign__c cmp = TestData.createCompleteCampaign(true);
        List<AccountGoal__c> goalList = CampaignUtility.getAccountGoalList(cmp.Id);
        System.assertNotEquals(0, goalList.size());
        goalList = CampaignUtility.getAccountGoalToFlexList(cmp.Id);
        System.assertNotEquals(0, goalList.size());
    }
    
    @isTest static void testGetNCDiscount(){
        TestData.createIntegrationData();
        MultiRequestMock mrm = new MultiRequestMock(new Map<String, StaticResourceCalloutMock>());
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_NcCompensated');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('NcCompensated', mock);
        Campaign__c cmp = TestData.createCompleteCampaignNcDiscount(true);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mrm);
        
        CampaignUtility.getNCDiscount(cmp.Id, Date.newInstance(2017, 10, 20));
        Test.stopTest();
    }
    
    @isTest static void testFlexAccountGoals(){
        Campaign__c cmp = TestData.createCompleteCampaign(true);
        CampaignUtility.startCampaign(cmp.Id);
        List<AccountGoal__c> goalList = CampaignUtility.getAccountGoalToFlexList(cmp.Id);
        List<AccountGoal__c> flexGoalList = new List<AccountGoal__c>();
        System.debug(goalList);
        for(Integer I = 0; I < goalList.size(); I++){
            if((Math.mod(I, 2) == 0) && (goalList[I].RealizedRlp__c < goalList[I].GoalRlp__c)) flexGoalList.add(goalList[I]);
        }
        System.debug('##flexGoalList');
        System.debug(flexGoalList);
       	String flexGoalListJSON = JSON.serialize(flexGoalList);
        String res = CampaignUtility.flexAccountGoals(cmp.Id, flexGoalListJSON);
        System.assertEquals('SUCCESS', res);
        
        List<AccountGoal__c> goalListUpdated = CampaignUtility.getAccountGoalList(cmp.Id);
        System.debug(goalListUpdated);
        for(Integer I = 0; I < goalListUpdated.size(); I++){
            if((Math.mod(I, 2) == 0)  && (goalList[I].RealizedRlp__c < goalList[I].GoalRlp__c)){
                System.assertEquals(goalListUpdated[I].RealizedRlp__c, goalListUpdated[I].GoalRlp__c);
 				System.assertEquals(goalList[I].GoalRlp__c - goalList[I].RealizedRlp__c, goalListUpdated[I].FlexValueRlp__c);
                System.assertEquals('Flexibilizado', goalListUpdated[I].Status__c);
            }
        }        
    }

    @isTest static void testComplete(){
        /*CREATING CAMPAIGN*/
        Campaign__c cmp = TestData.createCompleteCampaign(true);

        /*STARTING CAMPAIGN*/
      
        CampaignUtility.startCampaign(cmp.Id);  
        Campaign__c cmpAux = [SELECT Id, Active__c FROM Campaign__c WHERE Id = :cmp.Id];
        System.assertEquals(true, cmpAux.Active__c);
        
        System.Debug('TesteGoalList1');
        System.Debug(cmp.Id);

        /*CAMPAIGN CALCULATION*/
        CampaignUtility.computeRealized(cmp.Id, Date.newInstance(2017, 12, 20));
        List<AccountGoal__c> goalList = [SELECT Id, Name, Goal__c, Realized__c, RealizedRlp__c, CampaignCalculationLkp__r.Position__c 
                                         FROM ACCOUNTGOAL__C WHERE CampaignLkp__c = :cmp.Id
                                         ORDER BY CampaignCalculationLkp__r.Position__c];
        System.Debug('TesteGoalList');
        System.Debug(goalList[3].RealizedRlp__c);
        System.Debug(goalList);
        System.assertEquals(3000, goalList[3].RealizedRlp__c);
        
        /*CAMPAIGN RECOVERY*/
        CampaignUtility.campaignRecovery(cmp.Id);
        goalList = [SELECT Id, Name, Goal__c, Realized__c, CampaignCalculationLkp__r.Position__c, Status__c 
                    FROM ACCOUNTGOAL__C WHERE CampaignLkp__c = :cmp.Id
                    ORDER BY CampaignCalculationLkp__r.Position__c];
        System.assertEquals('Recuperado', goalList[0].Status__c);
        System.assertNotEquals('Recuperado', goalList[1].Status__c);
        System.assertNotEquals('Recuperado', goalList[2].Status__c);
        System.assertNotEquals('Recuperado', goalList[3].Status__c);
        
        /*CREATE CREDIT NOTE*/
        CampaignUtility.createCreditNote(cmp.Id, Date.newInstance(2017, 12, 20));
        goalList = [SELECT Id, Name, Goal__c, Realized__c, CampaignCalculationLkp__r.Position__c, Status__c, CreatedCreditNote__c 
                    FROM ACCOUNTGOAL__C WHERE CampaignLkp__c = :cmp.Id
                    ORDER BY CampaignCalculationLkp__r.Position__c];
		System.assertEquals(true, goalList[0].CreatedCreditNote__c);
        System.assertEquals(true, goalList[1].CreatedCreditNote__c);    
        System.assertEquals(false, goalList[2].CreatedCreditNote__c);    
        System.assertEquals(false, goalList[3].CreatedCreditNote__c);            
    }
}