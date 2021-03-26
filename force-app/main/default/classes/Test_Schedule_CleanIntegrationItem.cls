@isTest
private class Test_Schedule_CleanIntegrationItem {
		
    @isTest public static void TestSchedule(){
        ExpurgoItemDaIntegracao__c numDias = TestData.createExpurgoItemDaIntegracao('DaysToPurgeIntegrationItem', 365);
        Datetime purgeDate = Date.today().addDays(-Integer.valueOf(numDias.DiasParaExpurgo__c+1));
        Queue__c integrationItem = TestData.createQueue('Nome de Teste');
        Test.setCreatedDate(integrationItem.Id, purgeDate);
        integrationItem = [Select Id, CreatedDate From Queue__c Where Id =:integrationItem.Id];
        Test.startTest();
        Schedule_CleanIntegrationItem sci = new Schedule_CleanIntegrationItem();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('TestCleanIntegrationItem', CRON_EXP, sci);
        Test.stopTest();
    }
}