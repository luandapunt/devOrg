@isTest
public class Test_OrderComponentController {

    @isTest static void testOrder(){
        Product2 prod1 = TestData.createProduct('Tubo 1');
        prod1.SpecialProductBln__c = true;
        prod1.StandardPackageAmountNmb__c = 10;
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
        OrderType__c ot = TestData.createOrderType('ZNOV', true, false, true, false);
        PaymentTerm__c term281 = TestData.createPaymentTerm('C281', 1, 28);
        PaymentTerm__c term282 = TestData.createPaymentTerm('C282', 2, 28);
        Order__c ord = TestData.createOrder(salesArea.Id, acc.Id, ot.Id, pb.Id, '321312313213', null, term281);
        
        String response = OrderComponentController.addProductFromCart(ord.Id, prod1.ProductCodeTxt__c, 10, true);
        System.assertEquals('SUCCESS:', response);
        List<OrderItem__c> listItems = OrderComponentController.getOrderItems(ord.Id);
        System.assertEquals(100, listItems[0].OrderQuantityNmb__c);
        
        for(OrderItem__c item : listItems){
            item.LiquidNmb__c = 10;
            item.LiquidIpiNmb__c = 11;
            item.PVCPriceNmb__c = 10;
            item.PVCPriceIPINmb__c = 11;
            item.UnitPriceNmb__C = 10;
            item.UnitPriceIPINmb__C = 11;
        }
        update listItems;
        response = OrderComponentController.saveDiscountGlobal(ord.Id, 'XXES__c', 2);
        System.assertEquals('SUCCESS', response);
        listItems = OrderComponentController.getOrderItems(ord.Id);
        System.assertEquals(2, listItems[0].XXES__c);
        System.assertEquals(9.8, listItems[0].UnitPriceNmb__c);
        
        response = OrderComponentController.applyDiscount(listItems[0].id, 0, 0, 0, 50);
        listItems = OrderComponentController.getOrderItems(ord.Id);
        System.assertEquals(0, listItems[0].XXES__c);
        System.assertEquals(10, listItems[0].UnitPriceNmb__c);
        System.assertEquals(50, listItems[0].OrderQuantityNmb__c);
        
        response = OrderComponentController.deleteProduct(listItems[0].Id);
        System.assertEquals('SUCCESS', response);
        System.assertEquals(0, OrderComponentController.getOrderItems(ord.Id).size());
        
        List<PaymentTerm__c> listTerms = OrderCOmponentController.getPaymentTerms(ord.Id);
        system.assertEquals(2, listTerms.size());
        
    }
    
    @isTest static void testShipping(){
        
        Product2 prod1 = TestData.createProduct('Tubo 1');
        prod1.LoadPercentageNmb__c = 0.143;
        prod1.StandardPackageAmountNmb__c = 5;
        prod1.GrossWeightNmb__c = 5;
        prod1.UnitWeightTxt__c = 'G';
        prod1.IrrigationItemBln__c = true;
        update prod1;
        
        Product2 prod2 = TestData.createProduct('Tubo 2');
        prod2.LoadPercentageNmb__c = 0.1;
        prod2.StandardPackageAmountNmb__c = 10;
        prod2.GrossWeightNmb__c = 5;
        prod2.UnitWeightTxt__c = 'G';
        prod2.IrrigationItemBln__c = true;
        update prod2;
        
        Product2 prod20159 = TestData.createProduct('20159');
        prod20159.LoadPercentageNmb__c = 0.001;
        prod20159.StandardPackageAmountNmb__c = 1;
        prod20159.GrossWeightNmb__c = 1;
        prod20159.UnitWeightTxt__c = 'G';
        prod20159.IrrigationItemBln__c = true;
        update prod20159;
        
        Product2 prod20109 = TestData.createProduct('20109');
        prod20109.LoadPercentageNmb__c = 0.001;
        prod20109.StandardPackageAmountNmb__c = 1;
        prod20109.GrossWeightNmb__c = 1;
        prod20109.UnitWeightTxt__c = 'G';
        prod20109.IrrigationItemBln__c = true;
        update prod20109;
        
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
        ExpeditionCenter__c expCenter = TestData.createExpeditionCenter('0070', '0700');
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        Pricebook__c pb = TestData.createPricebook('TestPricebook');
        OrderType__c ot = TestData.createOrderType('ZNOV', true, true, true, false);
        PaymentTerm__c term281 = TestData.createPaymentTerm('C281', 1, 28);
        PaymentTerm__c term282 = TestData.createPaymentTerm('C282', 2, 28);
        Order__c ord = TestData.createOrder(null, acc.Id, ot.Id, pb.Id, '321312313213', null, term281);
        
        //String response = OrderComponentController.addProductFromCart(ord.Id, prod2.ProductCodeTxt__c, 1000, false);
        //System.assertEquals('SUCCESS:', response);
        
        OrderItem__c item2 = new OrderItem__c (OrderMdt__c = ord.Id, OrderQuantityNmb__c = 1150, ProductLkp__c = prod2.Id);
        item2.ExpeditionCenterLkp__c = expCenter.Id;
        item2.DistributionCenterTxt__c = '0700';
        item2.OriginalROBNoIPINmb__c = 23000;
        item2.TotalGrossCostNmb__c = 23000;
        item2.BottleneckDaysNmb__c = 2;
        /*
        item2.LiquidNmb__c = 20;
        item2.LiquidIpiNmb__c = 22;
        item2.PVCPriceNmb__c = 20;
        item2.PVCPriceIPINmb__c = 22;
        item2.UnitPriceNmb__C = 20;
        item2.UnitPriceIPINmb__C = 22;
*/
        //Teste Caio
        //item2.OrderQuantityNmb__c = 30;
        //item2.OriginalROBNoIPINmb__c = 200;
        //item2.OriginalQuantityNmb__c = 20;
        //
        insert item2;
        
        //response = OrderComponentController.addProductFromCart(ord.Id, prod1.ProductCodeTxt__c, 800, false);
        //System.assertEquals('SUCCESS:', response);
        
        OrderItem__c item1 = new OrderItem__c (OrderMdt__c = ord.Id, OrderQuantityNmb__c = 800, ProductLkp__c = prod1.Id);
        item1.ExpeditionCenterLkp__c = expCenter.Id;
        item1.DistributionCenterTxt__c = '0700';
        item1.OriginalROBNoIPINmb__c = 8000;
        item1.TotalGrossCostNmb__c = 8500;
        item1.BottleneckDaysNmb__c = 45;
        /*
        item1.LiquidNmb__c = 10;
        item1.LiquidIpiNmb__c = 11;
        item1.PVCPriceNmb__c = 10;
        item1.PVCPriceIPINmb__c = 11;
        item1.UnitPriceNmb__C = 10;
        item1.UnitPriceIPINmb__C = 11;
*/
        //Teste Caio
        //item1.OrderQuantityNmb__c = 3;
        //item1.OriginalROBNoIPINmb__c = 1;
        //item1.OriginalQuantityNmb__c = 1;
        //
        insert item1;
        
        Test.startTest();
        
        String remessas = OrderComponentController.getRemessas(ord.Id, false);
        remessas = OrderComponentController.getRemessas(ord.Id, true);
        system.debug(remessas);
        
        String response = OrderComponentController.alocateKits(ord.Id, remessas);
        System.assertEquals('SUCCESS', response);
        
        //System.assertEquals(8, [SELECT Id FROM OrderItem__c WHERE OrderMdt__c = :ord.Id].size());
                        
        response = OrderComponentController.saveRemessas(ord.Id, remessas);
        System.assertEquals('SUCCESS', response);
        response = OrderComponentController.saveRemessas(ord.Id, remessas);
        
        OrderItem__c item3 = [SELECT Id FROM OrderItem__c WHERE ProductLkp__c = :prod2.Id AND OrderQuantityNmb__c = 150];
        
        remessas = OrderComponentController.getRemessas(ord.Id, true);
        system.debug(remessas);

        OrderComponentController.modifyRemessas(remessas, item1.Id, 1, 6);
        OrderComponentController.modifyRemessas(remessas, item2.Id, 3, 1);
        OrderComponentController.modifyRemessas(remessas, item3.Id, 4, 3);
        
        //System.assertEquals(true, [SELECT ShippingSplitDoneBln__c FROM Order__c Where Id = :ord.Id].ShippingSplitDoneBln__c);
        System.assertEquals(12, [SELECT Id FROM OrderItem__c WHERE OrderMdt__c = :ord.Id].size());
        
        ord.SuggestedDoneBln__c = true;
        update ord;
        
        response = OrderComponentController.convertQuoteIntoOrderAsync(ord.Id);
        response = OrderComponentController.convertQuoteIntoOrder(ord.Id);
        system.debug(response);
        
        Test.stopTest();
        
        
    }
    
}