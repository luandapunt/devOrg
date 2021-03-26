@isTest
private class Test_Batch_CleanInvoice {
    @isTest static  void testDeleteInvoice(){
        ExpurgoNotaFiscal__c numDias = TestData.createExpurgoNotaFiscal('DaysToPurgeInvoice', 730);
        Datetime purgeDate = Date.today().addDays(-Integer.valueOf(numDias.Dias_para_expurgo__c+1));
        Invoice__c nota = TestData.createInvoice('Nome de Teste');
        Test.setCreatedDate(nota.Id, purgeDate);
        nota = [Select Id, CreatedDate From Invoice__c Where Id =: nota.Id];
        Test.startTest();
            Batch_CleanInvoice obj = new Batch_CleanInvoice();
            DataBase.executeBatch(obj); 
        Test.stopTest();   
        nota = [Select Id, isDeleted From Invoice__c Where Id =: nota.Id ALL ROWS];
        System.assertEquals(true, nota.IsDeleted);
    }
        
}