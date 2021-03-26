@isTest
private class Test_OrderItemTriggerHandler {
    
    @isTest static void testOrderItem(){
        StatusItemOrdem__c statusItem = new StatusItemOrdem__c(Name = 'LIMITE CREDITO', StatusValue__c = 1);
        insert statusItem;
        statusItem = new StatusItemOrdem__c(Name = 'POLITICA COMERCIAL', StatusValue__c = 2);
        insert statusItem;
        statusItem = new StatusItemOrdem__c(Name = 'AJUSTE DE ORDEM', StatusValue__c = 3);
        insert statusItem;
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Account acct = TestData.createAccount('Test Account', null, null, rtSAPAcc);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, null, null);
        OrderType__c ordType = TestData.createOrderType('ZNOV');
        Order__c ord = TestData.createOrder(salesArea.Id, null, ordtype.Id, null, '131242114214');
        OrderItem__c ordItem = TestData.createOrderItem(null, ord.Id, null, null);
        ordItem.StatusTxt__c = 'POLITICA COMERCIAL';
        update ordItem;
        ordItem = new OrderItem__c(OrderMdt__c = ord.Id, StatusTxt__c = 'LIMITE CREDITO');
        ordItem.TotalGrossCostNmb__c = 12;
        insert ordItem;
        ordItem.StatusTxt__c = 'AJUSTE DE ORDEM';
        ordItem.DistributionCenterTxt__c = '0100';
        /*ordItem = TestData.createOrderItem(null, ord.Id, null, null);
        ordItem.StatusTxt__c = 'LIMITE CREDITO';
        update ordItem;
        ordItem.StatusTxt__c = 'CADASTRO';
        ordItem.DistributionCenterTxt__c = '0100';*/
        update ordItem;

        delete ordItem;
        
    }

}