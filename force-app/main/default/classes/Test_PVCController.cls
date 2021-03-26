@isTest
public class Test_PVCController {

    @isTest
    public static void testOrder(){
        Product2 prod1 = TestData.createProduct('Tubo 1');
        prod1.SpecialProductBln__c = true;
        update prod1;
        Product2 prod2 = TestData.createProduct('Tubo 2');
        
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', salesOfficeManager.Id, so.Id);
		Account acc = TestData.createAccount('TestAccount', null, null, rtSAPAcc);
        Channel__c channel = TestData.createChannel('VJ1', null);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        Pricebook__c pb = TestData.createPricebook('TestPricebook');
        OrderType__c ot = TestData.createOrderType('ZNOV');
        Order__c ord = TestData.createOrder(salesArea.Id, acc.Id, ot.Id, pb.Id, '321312313213');
        ord.PVCStringTxt__c = '[{"Scale":[{"Target":0,"Amount":5.000000000}],"Description":"Desconto de Canal","Code":"ZPVC"},' + 
        '"Scale":[{"Target":10000.000000000,"Amount":1.000000000},{"Target":20000.000000000,"Amount":2.000000000}],"Description":"Desconto Por Volume","Code":"YPVO"},' +
        '{"Scale":[{"Target":3.000000000,"Amount":2.000000000},{"Target":6.000000000,"Amount":4.000000000}],"Description":"Desconto de Política","Code":"YPXI"}]';
        update ord;
        
        PricebookComponentController.addProduct(prod1.Id, ord.Id, 10, false);
        ord = PVCController.getOrderData(ord.Id);
        List<OrderItem__c> listItems = [SELECT Id FROM OrderItem__c WHERE OrderMdt__c = :ord.Id];
        for(OrderItem__c oItem : listItems){
            //oItem.LiquidNmb__c = 10;
            //oItem.LiquidIPINmb__c = 10;
            oItem.OriginalROBNoIPINmb__c = 100;
        }
        update listItems;
        system.debug(listItems);
        System.assertEquals(100, PVCController.getOrderAmount(ord.Id, 'YPVO'));
        System.assertEquals(0, PVCController.getOrderAmount(ord.Id, 'YPME'));
        System.assertEquals(0, PVCController.getOrderAmount(ord.Id, 'YPMX'));
        System.assertEquals(0, PVCController.getOrderAmount(ord.Id, 'YPXI'));
        System.assertEquals(1, PVCController.getOrderAmount(ord.Id, 'YPSO'));
        String result = PVCController.applyDiscounts(ord.Id, 'YPVO', 2, 2);

        listItems = [SELECT Id, ZPVO__c FROM OrderItem__c WHERE OrderMdt__c = :ord.Id];
        
        
        System.assertEquals('SUCCESS', result);
        System.assertEquals(2, listItems[0].ZPVO__c);
        
    }
    
    @isTest
    public static void testAccountData(){
        Product2 prod1 = TestData.createProduct('Tubo 1');
        prod1.SpecialProductBln__c = true;
        update prod1;
        Product2 prod2 = TestData.createProduct('Tubo 2');
        
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', salesOfficeManager.Id, so.Id);
		Account acc = TestData.createAccount('TestAccount', null, null, rtSAPAcc);
        Channel__c channel = TestData.createChannel('VJ1', null);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        Pricebook__c pb = TestData.createPricebook('TestPricebook');
        OrderType__c ot = TestData.createOrderType('ZNOV');
        Order__c ord = TestData.createOrder(salesArea.Id, acc.Id, ot.Id, pb.Id, '321312313213');
        
        SummarizedRevenue__c sumRev = TestData.createSummarizedRevenue(salesArea, System.today().addMonths(-2), '01');
        sumRev = TestData.createSummarizedRevenue(salesArea, Date.newInstance(System.today().year(), System.today().month(), 15), '02');
        PVCController.getAccountHistory(salesArea.Id, ord.Id);
    }
    
}