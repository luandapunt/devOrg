@isTest
private class ZTSyncCustomerCtrl
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account', 'Contact', 'Case'});
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;
    	
    	ApexRedirectMap__c apexRedirectMap = ULTestData.createApexRedirectMap('WebServiceCustomer', 'http://127.0.0.1:50000/customer');
		insert apexRedirectMap;
    	
    	Test.setMock(HttpCalloutMock.class, new ZTWebServiceCustomerMockImpl());
    	
    	// Start Test
		System.Test.startTest();
		
		Apexpages.currentPage().getParameters().put('Id', account.Id);
		ApexPages.StandardController std = new ApexPages.StandardController(account);
    	SyncCustomerCtrl ctrl = new SyncCustomerCtrl(std);
    	
    	ctrl.goBack();
        ctrl.doSync();
		
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(ctrl != null);
    }
}