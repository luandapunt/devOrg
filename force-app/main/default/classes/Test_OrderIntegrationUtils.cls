@isTest
public class Test_OrderIntegrationUtils {
    
    @isTest static void testQuote(){
        TestData.createIntegrationData();
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
        Order__c ord = TestData.createOrder(salesArea.Id, acc.Id, ot.Id, pb.Id, null, null, term281);
        ord.InvoiceHeaderTxt__c = 'TEST Inv';
        ord.CommercialRemarkTxt__c = 'TEST commercial';
        ord.RepresentativeRemarkTxt__c = 'TEST representative';
        update ord;
        
        MultiRequestMock mrm = new MultiRequestMock(new Map<String, StaticResourceCalloutMock>());
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_CreateQuotation');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('Quotation', mock);

        Test.setMock(HttpCalloutMock.class, mrm);
        
        Test.startTest();
        OrderIntegrationUtils.resendQuoteHeader(ord.Id);
        Test.stopTest();
        
        System.assertEquals('60480006', [SELECT CustomIdTxt__c FROM Order__C WHERE Id = :ord.Id].CustomIdTxt__c);
        
    }
    
    @isTest static void testSingleItem(){
        TestData.createIntegrationData();
        TestData.createSkipValidations();
        Product2 prod1 = TestData.createProduct('Tubo 1');
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
        OrderType__c ot = TestData.createOrderType('ZOPU', true, true, true, false);
        PaymentTerm__c term281 = TestData.createPaymentTerm('C281', 1, 28);
        PaymentTerm__c term282 = TestData.createPaymentTerm('C282', 2, 28);
        Order__c ord = TestData.createOrder(salesArea.Id, acc.Id, ot.Id, pb.Id, '60480006', null, term281);
        ord.InvoiceHeaderTxt__c = 'TEST Inv';
        ord.CommercialRemarkTxt__c = 'TEST commercial';
        ord.RepresentativeRemarkTxt__c = 'TEST representative';
        update ord;
        
        
        OrderItem__c item1 = new OrderItem__c (OrderMdt__c = ord.Id, OrderQuantityNmb__c = 800, ProductLkp__c = prod1.Id);
        insert item1;
        
        MultiRequestMock mrm = new MultiRequestMock(new Map<String, StaticResourceCalloutMock>());
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_QuotationChange');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('QuotationChange', mock);
        
        mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_OrderGetDetail');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('OrderGetDetail', mock);
        
        mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_S666');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('S666', mock);
        
        mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_ZPH_FCUR');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('ZPH_FCUR', mock);
        
        mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_KONH');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('KONH', mock);
        
        mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_Order');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('Order', mock);
        
        Test.setMock(HttpCalloutMock.class, mrm);
        
        Test.startTest();
        OrderIntegrationUtils.createItemOnSAPFuture(ord.Id, item1.id);
        OrderIntegrationUtils.convertQuoteIntoOrder(ord.Id);
        ord = OrderIntegrationUtils.getOrder(ord.Id);
        Test.stopTest();
        
        
    }
    
    @isTest static void testMultipleItems(){
        TestData.createIntegrationData();
        Product2 prod1 = TestData.createProduct('Tubo 1');
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
        ExpeditionCenter__c expCenter = TestData.createExpeditionCenter('0070', '0700');
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        Pricebook__c pb = TestData.createPricebook('TestPricebook');
        OrderType__c ot = TestData.createOrderType('ZNOV', true, true, true, false);
        PaymentTerm__c term281 = TestData.createPaymentTerm('C281', 1, 28);
        PaymentTerm__c term282 = TestData.createPaymentTerm('C282', 2, 28);
        Order__c ord = TestData.createOrder(salesArea.Id, acc.Id, ot.Id, pb.Id, '60480006', null, term281);
        
        OrderItem__c item1 = new OrderItem__c (OrderMdt__c = ord.Id, OrderQuantityNmb__c = 800, ProductLkp__c = prod1.Id);
        insert item1;
        OrderItem__c item2 = new OrderItem__c (OrderMdt__c = ord.Id, OrderQuantityNmb__c = 400, ProductLkp__c = prod2.Id);
        insert item2;
        
        MultiRequestMock mrm = new MultiRequestMock(new Map<String, StaticResourceCalloutMock>());
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_QuotationChange_Mult');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('QuotationChange', mock);
        
        mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_OrderGetDetail_Mult');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('OrderGetDetail', mock);
        
        Test.setMock(HttpCalloutMock.class, mrm);
        
        Test.startTest();
        OrderIntegrationUtils.resendItems(ord.Id);
        Test.stopTest();
        
    }
    
    
    @isTest static void deleteItem(){
        TestData.createIntegrationData();
        Product2 prod1 = TestData.createProduct('Tubo 1');
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
        ExpeditionCenter__c expCenter = TestData.createExpeditionCenter('0070', '0700');
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        Pricebook__c pb = TestData.createPricebook('TestPricebook');
        OrderType__c ot = TestData.createOrderType('ZNOV', true, true, true, false);
        PaymentTerm__c term281 = TestData.createPaymentTerm('C281', 1, 28);
        PaymentTerm__c term282 = TestData.createPaymentTerm('C282', 2, 28);
        Order__c ord = TestData.createOrder(salesArea.Id, acc.Id, ot.Id, pb.Id, '60480006', null, term281);
        
        OrderItem__c item1 = new OrderItem__c (OrderMdt__c = ord.Id, OrderQuantityNmb__c = 800, ProductLkp__c = prod1.Id);
        insert item1;
        OrderItem__c item2 = new OrderItem__c (OrderMdt__c = ord.Id, OrderQuantityNmb__c = 400, ProductLkp__c = prod2.Id);
        insert item2;
        
        MultiRequestMock mrm = new MultiRequestMock(new Map<String, StaticResourceCalloutMock>());
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Mock_QuotationChange');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        mrm.addRequestMock('QuotationChange', mock);
        
        Test.setMock(HttpCalloutMock.class, mrm);
        
        Test.startTest();
        OrderIntegrationUtils.deleteItemOnSAPFuture(ord.Id, new List<Id>{item1.id});
        Test.stopTest();
    }
    
}