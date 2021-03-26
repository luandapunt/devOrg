@isTest
public class Test_AddSalesPlan {

    @isTest static void testAll(){
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User u = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', u.Id);
        Seller__c sel = TestData.createSeller('TestSeller', u.Id, so.Id);
		Account acc = TestData.createAccount('TestAccount', null, null, rtSAPAcc);
        Channel__c channel = TestData.createChannel('VJ1', null);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        AccountAreaSales__c salesArea2 = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        
        SummarizedRevenue__c sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2018, 01, 1), '01');
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 02, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 03, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 04, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 05, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 06, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 07, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 08, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 09, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 10, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 11, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 12, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 01, 1), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 12, 10), 100);   
		sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2018, 01, 10), 100);  
        
        sumRev = TestData.createSummarizedRevenue(salesArea2, System.today().addMonths(-8), '01');
        sumRev = TestData.createSummarizedRevenue(salesArea2, Date.newInstance(System.today().year(), System.today().month(), 15), '02');
        
        Quota__c quota = TestData.createQuota(sel, '2018', '01', 'Atingimento de Cota', u);
        
        Event evt = new Event(WhatId = salesArea.Id,                              
                              StartDateTime = Datetime.newInstance(2018, 01, 10,10,10,10),
                              DurationInMinutes = 120);
    
        insert evt;
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(quota);
        AddSalesPlan controller = new AddSalesPlan(stdCon);
        controller.getRemainingAmount();
        
		controller.getFilterOptions();
        controller.planFilter = 'AccountCityTxt__c';
        controller.getFilterValues();
        controller.planFilter = 'AccountPostalCodeTxt__c';
        controller.getFilterValues();
        controller.planFilter = 'CampaignLkp__c';
        controller.getFilterValues();
        controller.planFilter = 'ChannelPVCTxt__c';
        controller.getFilterValues();
        controller.planFilter = 'FidelityTxt__c';
        controller.getFilterValues();
        
        controller.planFilterValue = channel.Id;
        controller.getPlanList();
               
        controller.getCustomerLossReason();
        controller.getPageNums();
        controller.getPriority1();
        controller.getPriority2();
        controller.getTrdMktActions();
        
        controller.doSave();
        
        /*String salesAreaId, String dateTimeString, String durationString, String trdMktActionString, String priority1String, String priority2String,
            String priority3String, String customerLossReasonString, String guestId, Boolean isRecurrent, string recurrenceTypeString, string limitDateString
          */   
        AddSalesPlan.doSaveEventRemote(salesArea.Id, '2018-01-01', '12', 'Ação1', 'priority1String', 'priority2String', 'priority3String', 'customerLossReasonString',
                                      null, true, 'Semanal', '2018-01-19');
        //System.assertEquals(2, [SELECT Id FROM Event WHERE QuotaLkp__c = :quota.Id].size());
        
        Quota__c quota2 = TestData.createQuota(sel, '2017', '05', 'Atingimento de Cota', u);
        stdCon = new ApexPages.StandardController(quota2);
        AddSalesPlan controller2 = new AddSalesPlan(stdCon);
        
        /*Quota__c quota3 = TestData.createQuota(sel, '2017', '09', 'Atingimento de Cota', u);
        stdCon = new ApexPages.StandardController(quota3);
        AddSalesPlan controller3 = new AddSalesPlan(stdCon);
        
        Quota__c quota4 = TestData.createQuota(sel, '2017', '11', 'Atingimento de Cota', u);
        stdCon = new ApexPages.StandardController(quota4);
        AddSalesPlan controller4 = new AddSalesPlan(stdCon);*/
    }
    
    @isTest static void test2ndSemester(){
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User u = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', u.Id);
        Seller__c sel = TestData.createSeller('TestSeller', u.Id, so.Id);
		Account acc = TestData.createAccount('TestAccount', null, null, rtSAPAcc);
        Channel__c channel = TestData.createChannel('VJ1', null);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        AccountAreaSales__c salesArea2 = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        
        SummarizedRevenue__c sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2018, 08, 1), '01');
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 02, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 03, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 04, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 05, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 06, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 07, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 08, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 09, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 10, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 11, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 12, 15), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 01, 1), 100);
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2017, 12, 10), 100);  
		sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(2018, 08, 10), 100);  
        
        sumRev = TestData.createSummarizedRevenue(salesArea2, System.today().addMonths(-8), '01');
        sumRev = TestData.createSummarizedRevenue(salesArea2, Date.newInstance(System.today().year(), System.today().month(), 15), '02');
        
        Quota__c quota = TestData.createQuota(sel, '2018', '08', 'Atingimento de Cota', u);
        
        Event evt = new Event(WhatId = salesArea.Id,                              
                              StartDateTime = Datetime.newInstance(2018, 08, 10,10,10,10),
                              DurationInMinutes = 120);
    
        insert evt;
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(quota);
        AddSalesPlan controller = new AddSalesPlan(stdCon);
        controller.getRemainingAmount();
        
		controller.getFilterOptions();
        controller.planFilter = 'AccountCityTxt__c';
        controller.getFilterValues();
        controller.planFilter = 'AccountPostalCodeTxt__c';
        controller.getFilterValues();
        controller.planFilter = 'CampaignLkp__c';
        controller.getFilterValues();
        controller.planFilter = 'ChannelPVCTxt__c';
        controller.getFilterValues();
        controller.planFilter = 'FidelityTxt__c';
        controller.getFilterValues();
        
        controller.planFilterValue = channel.Id;
        controller.getPlanList();
               
        controller.getCustomerLossReason();
        controller.getPageNums();
        controller.getPriority1();
        controller.getPriority2();
        controller.getTrdMktActions();
        
        controller.doSave();
        
        /*String salesAreaId, String dateTimeString, String durationString, String trdMktActionString, String priority1String, String priority2String,
            String priority3String, String customerLossReasonString, String guestId, Boolean isRecurrent, string recurrenceTypeString, string limitDateString
          */   
        AddSalesPlan.doSaveEventRemote(salesArea.Id, '2018-08-01', '12', 'Ação1', 'priority1String', 'priority2String', 'priority3String', 'customerLossReasonString',
                                      null, true, 'Mensal', '2018-11-19');
        //System.assertEquals(2, [SELECT Id FROM Event WHERE QuotaLkp__c = :quota.Id].size());
        
        Quota__c quota2 = TestData.createQuota(sel, '2017', '12', 'Atingimento de Cota', u);
        stdCon = new ApexPages.StandardController(quota2);
        AddSalesPlan controller2 = new AddSalesPlan(stdCon);
        
        /*Quota__c quota3 = TestData.createQuota(sel, '2017', '09', 'Atingimento de Cota', u);
        stdCon = new ApexPages.StandardController(quota3);
        AddSalesPlan controller3 = new AddSalesPlan(stdCon);
        
        Quota__c quota4 = TestData.createQuota(sel, '2017', '11', 'Atingimento de Cota', u);
        stdCon = new ApexPages.StandardController(quota4);
        AddSalesPlan controller4 = new AddSalesPlan(stdCon);*/
    }
    
}