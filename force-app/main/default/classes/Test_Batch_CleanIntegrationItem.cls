@isTest
private class Test_Batch_CleanIntegrationItem {
    @isTest static  void testDeleteIntegrationItem(){
        ExpurgoItemDaIntegracao__c numDias = TestData.createExpurgoItemDaIntegracao('DaysToPurgeIntegrationItem', 365);
        Datetime purgeDate = Date.today().addDays(-Integer.valueOf(numDias.DiasParaExpurgo__c+1));
        Queue__c integrationItem = TestData.createQueue('Nome de Teste');
        Test.setCreatedDate(integrationItem.Id, purgeDate);
        integrationItem = [Select Id, CreatedDate From Queue__c Where Id =:integrationItem.Id];
        Test.startTest();
            Batch_CleanIntegrationItem obj = new Batch_CleanIntegrationItem();
            DataBase.executeBatch(obj); 
        Test.stopTest(); 
        integrationItem = [Select Id, isDeleted From Queue__c Where Id =:integrationItem.Id ALL ROWS];
        System.assertEquals(true, integrationItem.IsDeleted);
    }
}