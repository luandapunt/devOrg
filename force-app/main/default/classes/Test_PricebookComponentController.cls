@isTest
public class Test_PricebookComponentController {

    @isTest
    public static void testCatalog(){
        Product2 prod1 = TestData.createProduct('Tubo 1');
        Product2 prod2 = TestData.createProduct('Tubo 2');
        
        Pricebook__c pb = TestData.createPricebook('Catálogo Classe de Teste');
        CatalogElement__c rootElem1 = TestData.createCatalogElement('root1', 1, pb.id, null);
        CatalogElement__c rootElem2 = TestData.createCatalogElement('root2', 2, pb.Id, null);
        
        CatalogElement__c childElem1 = TestData.createCatalogElement('child1', 1, null, rootElem1.Id);
        CatalogElement__c childElem2 = TestData.createCatalogElement('child2', 1, null, rootElem2.Id);
        
        ElementProduct__c elPrd1 = TestData.createElementProduct(prod1, childElem1);
        ElementProduct__c elPrd2 = TestData.createElementProduct(prod2, childElem2);
        
        PricebookComponentController.findProductsPricebook(pb.Id);
        
        System.assertEquals(2, PricebookComponentController.getElementList(pb.Id, null, null).size());
        System.assertEquals(1, PricebookComponentController.getElementList(null, null, rootElem1.Id).size());
        
        System.assertEquals(2, PricebookComponentController.getProducts(pb.Id, null, null, null).size());
        System.assertEquals(0, PricebookComponentController.getProducts(null, rootElem2.Id, 'child1', null).size());
        
    }
    
    @isTest
    public static void testOrder(){
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
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        Pricebook__c pb = TestData.createPricebook('TestPricebook');
        OrderType__c ot = TestData.createOrderType('ZNOV');
        Order__c ord = TestData.createOrder(salesArea.Id, acc.Id, ot.Id, pb.Id, '321312313213');
        
        SuggestedProduct__c sugProd = new SuggestedProduct__c(ChannelLkp__c = channel.Id, SalesOfficeTxt__c = salesArea.SalesOfficeTxt__c, ProductLkp__c = prod2.Id);
        insert sugProd;
        ComplementaryProduct__c cmpProd = new ComplementaryProduct__c(ProductLkp__c = prod1.Id, ComplementaryLkp__c = prod2.Id);
        insert cmpProd;
        
        PricebookComponentController.addProduct(prod1.Id, ord.Id, 10, false);
        
        System.assertEquals(1, [SELECT Id FROM OrderItem__c WHERE OrderMdt__c = :ord.Id].size());
        System.assertEquals(1, PricebookComponentController.suggestedProduct(ord.Id).size());
        System.assertEquals(1, PricebookComponentController.complementaryProduct(ord.Id).size());
        
    }
    
}