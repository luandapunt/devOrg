@istest
public class ZTCreateNewCaseCtrl {
 
    static testMethod void testcreatecase()
    {
        // Prepare test data
        RecordTypeMap rt = RecordTypeMap.getInstance();
        
        Seller__c seller = TestData.createSeller('TestSellerName');
        
        String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        
        Account account = TestData.createAccount('TestNameAccount',null, null,rtSAPAcc);
        account.CodeCustomerTxt__c = '2345678';
        update account;
        
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(account.Id, null, seller.Id);
                
        Carrier__c carrier = TestData.createCarrier ('TestNameCarrier', 'carrier@email.com.br');
        
        Order__c order = TestData.createOrder(salesArea.Id, account.Id, null, null,  '135795', seller.Id);
        
        Remittance__c remittance = TestData.createRemittance('TestNameRemittance', order.Id, carrier.Id);
                
        Invoice__c invoice = TestData.createInvoice('TestNameInvoice', account.Id,remittance.Id);

        Invoice__c inv2 = CreateNewCaseCtrl.getinvoice(invoice.Id);
        
        Order__c order2 = CreateNewCaseCtrl.getorder(order.Id);
        
        String rtCase1 = rt.rtmap.get('Case').get('Devolucao');
        String rtCase2 = rt.rtmap.get('Case').get('AlteracaoPedido');
        String rtCase3 = rt.rtmap.get('Case').get('IndicacaoVendedor');
        
        List<RecordType> rt1 = CreateNewCaseCtrl.getcaserecordtype();
        List<RecordType> rt2 = CreateNewCaseCtrl.getcaserecordtypeO();
        List<RecordType> rt3 = CreateNewCaseCtrl.getcaserecordtypeA();
       
        order = [SELECT Name FROM Order__c WHERE id =: order.Id];
        
        // Verify data
       
        System.assert(rtCase1 != null);
        System.assert(rtCase2 != null);
        System.assert(rtCase3 != null);
        System.debug('invoice.Name :'+invoice.Name+'inv2.Name :'+inv2.Name);
        System.assert(invoice.Name == inv2.Name);
        System.debug('order.Name :'+order.Name +'>>'+'order2.Name :'+'>>'+order2.Name);
        System.assert(order.Name == order2.Name);
        
    }
}