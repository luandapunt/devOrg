@isTest
private class Test_OrderPDFViewController {
    
    @isTest static void TestgetDynamicFormatString(){
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', salesOfficeManager.Id, so.Id);
		Account acc = TestData.createAccount('TestAccount', null, null, rtSAPAcc);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, null, sel.Id);
        Pricebook__c pb = TestData.createPricebook('TestPricebook');
        OrderType__c ot = TestData.createOrderType('ZNOV');
        Order__c ord = TestData.createOrder(salesArea.Id, acc.Id, ot.Id, pb.Id, '321312313213');
        ApexPages.StandardController stdController = new ApexPages.StandardController(ord);
        OrderPDFViewController testClass = new OrderPDFViewController(stdController);
        String text = testClass.getDynamicFormatString();
        System.assertEquals('{0,number,#.###.###.###.###.##0,00}', text);

     
    }

}