@istest
public class Test_RESTCreditNoteController {
    
    static testMethod void  testEchoMyType(){    
        
        String jsonInput = '{"integrationId":"SYNC_OPENITEMS_INBOUND","content":"[{\\"KUNNR\\":\\"203761\\",\\"VKORG\\":\\"AM01\\",\\"CREDRETURN\\":\\"0.00 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"163.00 \\",\\"CREDGENERAL\\":\\"0.00 \\",\\"REFDATE\\":\\"20180319\\"},{\\"KUNNR\\":\\"203915\\",\\"VKORG\\":\\"0143\\",\\"CREDRETURN\\":\\"0.00 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"913.00 \\",\\"CREDGENERAL\\":\\"0.00 \\",\\"REFDATE\\":\\"20180319\\"},{\\"KUNNR\\":\\"203929\\",\\"VKORG\\":\\"AM01\\",\\"CREDRETURN\\":\\"0.00 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"154.00 \\",\\"CREDGENERAL\\":\\"0.00 \\",\\"REFDATE\\":\\"20180319\\"},{\\"KUNNR\\":\\"204062\\",\\"VKORG\\":\\"AM01\\",\\"CREDRETURN\\":\\"0.00 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"1500.00 \\",\\"CREDGENERAL\\":\\"0.00 \\",\\"REFDATE\\":\\"20180319\\"},{\\"KUNNR\\":\\"204181\\",\\"VKORG\\":\\"AM01\\",\\"CREDRETURN\\":\\"0.00 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"0.00 \\",\\"CREDGENERAL\\":\\"1707.22 \\",\\"REFDATE\\":\\"20180319\\"},{\\"KUNNR\\":\\"204222\\",\\"VKORG\\":\\"AM01\\",\\"CREDRETURN\\":\\"0.00 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"583.00 \\",\\"CREDGENERAL\\":\\"0.00 \\",\\"REFDATE\\":\\"20180319\\"},{\\"KUNNR\\":\\"204252\\",\\"VKORG\\":\\"AM01\\",\\"CREDRETURN\\":\\"0.00 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"0.00 \\",\\"CREDGENERAL\\":\\"1243.56 \\",\\"REFDATE\\":\\"20180319\\"},{\\"KUNNR\\":\\"204254\\",\\"VKORG\\":\\"AM01\\",\\"CREDRETURN\\":\\"0.00 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"20000.00 \\",\\"CREDGENERAL\\":\\"0.00 \\",\\"REFDATE\\":\\"20180319\\"},{\\"KUNNR\\":\\"204262\\",\\"VKORG\\":\\"AM01\\",\\"CREDRETURN\\":\\"0.00 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"0.00 \\",\\"CREDGENERAL\\":\\"81.95 \\",\\"REFDATE\\":\\"20180319\\"},{\\"KUNNR\\":\\"204466\\",\\"VKORG\\":\\"AM01\\",\\"CREDRETURN\\":\\"0.00 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"0.00 \\",\\"CREDGENERAL\\":\\"411.00 \\",\\"REFDATE\\":\\"20180319\\"},{\\"KUNNR\\":\\"204480\\",\\"VKORG\\":\\"0099\\",\\"CREDRETURN\\":\\"7590.00 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"0.00 \\",\\"CREDGENERAL\\":\\"0.00 \\",\\"REFDATE\\":\\"20180319\\"},{\\"KUNNR\\":\\"204736\\",\\"VKORG\\":\\"AM01\\",\\"CREDRETURN\\":\\"1388.25 \\",\\"CREDPRICE\\":\\"0.00 \\",\\"CREDTRADE\\":\\"0.00 \\",\\"CREDGENERAL\\":\\"0.00 \\",\\"REFDATE\\":\\"20180319\\"}]","access_token":"00DL0000002ANxI!AQ8AQInOqZ9aGzeIVEMXICMQgJ5e7d_ryPMg1iC3Nj73tpUvWi9rlL_z0Xs_qeJzymIZxC7OdcTebeBXOguFbcbR6F3OwV7c","isSync":true,"instance_url":"https:\\/\\/mexichem--prehomolog.cs8.my.salesforce.com","token_type":"Bearer"}';
        RESTCreditNoteController.WSInBoundOrquestrationVO jsonObj = (RESTCreditNoteController.WSInBoundOrquestrationVO) JSON.deserialize(jsonInput, RESTCreditNoteController.WSInBoundOrquestrationVO.class);
        
        Channel__c channel = TestData.createChannel('VJ1', null);
        Account conta1 = TestData.createAccount('Conta 1', channel.id);
        Account conta2 = TestData.createAccount('Conta 2', channel.Id);
        Account conta3 = TestData.createAccount('Conta 3', channel.Id);
        Account conta4 = TestData.createAccount('Conta 4', channel.Id);
        
        conta1.CodeCustomerTxt__c = '203761';
        conta2.CodeCustomerTxt__c = '203915';
        conta3.CodeCustomerTxt__c = '203929';
        conta4.CodeCustomerTxt__c = '204062';
        
        update conta1;
        update conta2;
        update conta3;
        update conta4;
        
        AccountAreaSales__c sa1 = TestData.createAccountAreaSales(conta1, channel.Id);
        AccountAreaSales__c sa2 = TestData.createAccountAreaSales(conta2, channel.Id);
        AccountAreaSales__c sa3 = TestData.createAccountAreaSales(conta3, channel.Id);
        AccountAreaSales__c sa4 = TestData.createAccountAreaSales(conta4, channel.Id);
        
        sa1.CustomIDTxt__c = conta1.CodeCustomerTxt__c + sa1.CodeSalesOrganizationTxt__c;
        sa2.CustomIDTxt__c = conta2.CodeCustomerTxt__c + sa2.CodeSalesOrganizationTxt__c;
        sa3.CustomIDTxt__c = conta3.CodeCustomerTxt__c + sa3.CodeSalesOrganizationTxt__c;
        sa4.CustomIDTxt__c = conta4.CodeCustomerTxt__c + sa4.CodeSalesOrganizationTxt__c;
        
        update sa1;
        update sa2;
        update sa3;
        update sa4;
        
        Pricebook__c pb = TestData.createPricebook('TestPricebook');
        OrderType__c ot = TestData.createOrderType('ZNOV');
        
        Order__c ord1 = TestData.createOrder(sa1.Id, conta1.Id, ot.Id, pb.Id, '321312313223');
        Order__c ord2 = TestData.createOrder(sa1.Id, conta1.Id, ot.Id, pb.Id, '321312313233');
        Order__c ord3 = TestData.createOrder(sa2.Id, conta2.Id, ot.Id, pb.Id, '321312313243');
        Order__c ord4 = TestData.createOrder(sa2.Id, conta2.Id, ot.Id, pb.Id, '321312313253');
        
        Test.startTest();
        
        RESTCreditNoteController.ResponseWrapper resWrap = RESTCreditNoteController.echoMyType(jsonObj);
        System.assertEquals(3, resWrap.RECORD_QTY);
        
        Test.stopTest();
        
        
    }
}