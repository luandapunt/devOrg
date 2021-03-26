@isTest
private class Test_Schedule_CleanInvoice {
    
    @isTest static void schedule(){
        ExpurgoNotaFiscal__c numDias = TestData.createExpurgoNotaFiscal('DaysToPurgeInvoice', 730);
        Datetime purgeDate = Date.today().addDays(-Integer.valueOf(numDias.Dias_para_expurgo__c+1));
        Invoice__c nota = TestData.createInvoice('Nome de Teste');
        Test.setCreatedDate(nota.Id, purgeDate);
        nota = [Select Id, CreatedDate From Invoice__c Where Id =: nota.Id];
        Test.startTest();
        Schedule_CleanInvoice sci = new Schedule_CleanInvoice();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('TestCleanInvoice', CRON_EXP, sci);
        Test.stopTest();

    }

}