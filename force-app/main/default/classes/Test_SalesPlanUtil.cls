@isTest
private class Test_SalesPlanUtil {
    
    @isTest static void testProcessSummarizedRevenue(){
        RecordTypeMap rt = RecordTypeMap.getInstance();
        String rtSACAcc = rt.rtmap.get('Account').get('BusinessAccountSAC');
        Account acct = TestData.createAccount('Test Account', null, null, rtSACAcc);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, null, null);
        SummarizedRevenue__c sr = TestData.createSummarizedRevenue('TestSummarizedRevenue', '1132143', salesArea.Id);
        sr.ROBNmb__c = 100.10;
        sr.DateDt__c = Date.Today();
        update sr;
        List<SummarizedRevenue__c> srList = new List<SummarizedRevenue__c>();
        srList.add(sr);
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User u = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', u.Id);
        Seller__c sel = TestData.createSeller('TestSeller', u.Id, so.Id);
		Quota__c quota = TestData.createQuota(sel, '2018', '01', 'Atingimento de Cota', u);        
        //SalesPlanning__c sp = TestData.createSalesPlanning(salesArea.Id, null, null);
        SalesPlanning__c sp = TestData.createSalesPlanning(salesArea.Id, null, quota.Id);
        
        Date myDate = Date.Today();
        sp.CurrentYearTxt__c = String.valueOf(myDate.year());
        sp.CurrentMonthTxt__c = '0' + String.valueOf(myDate.month());
        update sp;
        SalesPlanUtil.processSummarizedRevenue(srList);
        sp = [Select RevenueNmb__c
              From SalesPlanning__c
              Where Id =: sp.Id];
        System.assertEquals(100.10, sp.RevenueNmb__c);
    }

}