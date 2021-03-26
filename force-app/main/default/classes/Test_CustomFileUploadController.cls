@isTest
private class Test_CustomFileUploadController {
    @isTest static void testAll(){
        RecordTypeMap rt = RecordTypeMap.getInstance();
        Product2 prod1 = TestData.createProduct('11544', 10);
        Product2 prod2 = TestData.createProduct('11560', 8);
        Product2 prod3 = TestData.createProduct('11609', 5);
        Product2 prod4 = TestData.createProduct('11586', 5);
        Product2 prod5 = TestData.createProduct('11587', 5);
        Product2 prod6 = TestData.createProduct('11588', 5);
        Product2 prod7 = TestData.createProduct('11589', 5);
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Account acct = TestData.createAccount('Test Account', null, null, rtSAPAcc);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acct.Id, null, null);
        
        OrderType__c ordType = TestData.createOrderType('ZCOV');
        //zcov -- ZNOV
        system.debug('ZCOV');
        system.debug(ordtype.Id);
        Order__c ord = TestData.createOrder(salesArea.Id, null, ordtype.Id, null, '131242114');
        
        //ord.OrderTypeLkp__r.Category__c='Cotação';
        
        PageReference myVfPage = Page.fileupload;
		Test.setCurrentPage(myVfPage);
        
        
        ApexPages.currentPage().getParameters().put('id',ord.Id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(ord);
        CustomFileUploadController controller = new CustomFileUploadController(stdController);
        controller.contentType='application/vnd.ms-excel';
        
        String myString = 'Item;Quantidade;Preco \n' + 
            				'11544;600;10 \n' +
            				'11560;600;10 \n' +
							'11585;70;11 \n' +
            				'11586;70;A \n' +
            				'11587;70;0 \n' +
            				'11588;70,4;11 \n' +
           					'11589;7;11 \n' +
							'11609;500;1,5';
        System.debug(myString);
		Blob myBlob = Blob.valueof(myString);
        
        controller.contentFile=myBlob;
        //ApexPages.currentPage().getParameters().put('contentType','application/vnd.ms-excel');
		//String sContentFile = 'Item;Quantidade;Preco';
		//Blob ContentBlob = Blob.valueof(sContentFile);       
        //ApexPages.currentPage().getParameters().put('contentFile',sContentFile);
        
        system.debug(controller.contentType);       
        
        controller.ReadFile();
        
        controller.AdjustDiscounts();
        
        myString = 'Item;Quantidade \n' + 
            '11544;600 \n' +
            '11560;600 \n' +
            '11585;70 \n' +
            '11609;500';
        myBlob=Blob.valueof(myString);
        //ord.OrderTypeLkp__r.Category__c='Cotação';
        
        //System.debug(myString);
        //Blob myBlob = Blob.valueof(myString);
        controller.ReadFile();
    }
     
}