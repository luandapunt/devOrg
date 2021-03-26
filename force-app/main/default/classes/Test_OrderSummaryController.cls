@isTest
private class Test_OrderSummaryController {
    
    @isTest static void testGetSystemsAndGroups(){
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
		Product2 prod = TestData.createProduct('TestProduct');
        OrderItem__c ordi = TestData.createOrderItem(prod.Id, ord.Id, null, null);
        
        //Teste Caio 20/04
        ordi.OriginalROBNoIPINmb__c = 120;
        ordi.TotalGrossCostNmb__c = 150;
        ordi.LiquidNmb__c = 120;
        update ordi;
        
        string testSystem = OrderSummaryController.getSystems(ord.Id);
        string testGroup = OrderSummaryController.getGroups(ord.Id);
        system.debug(testSystem);
        system.debug(testGroup);
        System.assertEquals('[{"weight":5.5,"systemDscrp":"Água Fria","systemCode":"1000","itemCount":1,"grossAmountWOIPI":120.0,"grossAmountIPI":150.0,"amountWTaxes":120.0}]', testSystem);
        System.assertEquals('[{"weight":5.5,"itemCount":1,"groupDscrp":"Tubos","groupCode":"01","grossAmountWOIPI":120.0,"grossAmountIPI":150.0,"amountWTaxes":120.0}]', testGroup);
    }

}