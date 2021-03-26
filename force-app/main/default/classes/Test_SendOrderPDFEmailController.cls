@isTest
private class Test_SendOrderPDFEmailController {
    
    @isTest static void TestSendOrderPDFEmailController(){
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Account acct = TestData.createAccount('Test Account', null, null, rtSAPAcc);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, null, null);
        OrderType__c ordType = TestData.createOrderType('ZNOV');
        Order__c ord = TestData.createOrder(salesArea.Id, null, ordtype.Id, null, '131242114');
        PageReference myVfPage = Page.SendOrderPDFEmail;
		Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('id',ord.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(ord);
        SendOrderPDFEmailController controller = new SendOrderPDFEmailController(stdController);
        controller.subject = 'testsubject@test.com';
        controller.body = 'testbody';
        controller.emailid = 'testemail@test.com';
        controller.mailBody = 'testmailbody';
        
        List<String> fileList = new List<String>();
        fileList.add('PDF');
        fileList.add('CSV');
        fileList.add('XLS');
  		Test.startTest();        
        for(String ext : fileList){
            
            controller.fileExtension = ext;
            //Test.startTest();
            controller.send();
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            //Test.stopTest();
            for(ApexPages.Message msg : msgList){
                System.assertEquals('O email foi enviado com sucesso!', msg.getSummary());
                System.assertEquals(ApexPages.severity.CONFIRM, msg.getSeverity());
            }   
        
        }
        Test.stopTest();
    }

}