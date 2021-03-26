@isTest
private class ZTCSEAccountAreaSalesSelector
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	Map<String, Id> mapRecType = RecordTypeDAO.selectRecordTypeDevNameMapByObjectNameSetCached(new Set<String>{'Account'});
    	
    	Seller__c seller = ULTestData.createSeller('John Doe', '1000');
    	insert seller;
    	
    	Account account = ULTestData.createAccount(mapRecType.get('BusinessAccountSAC'), 'Testador da pagina', '26830528000181');
    	insert account;   
    	
		AccountAreaSales__c accountAreaSales = ULTestData.createAccountAreaSales(account.Id, seller.Id, '999333AM01RVPR00009090');
    	insert accountAreaSales;
    	
    	// Start Test
		System.Test.startTest();
		
		List<AccountAreaSales__c> test1 = new CSEAccountAreaSalesSelector().selectById(new Set<Id>{accountAreaSales.Id});
    	
    	List<AccountAreaSales__c> test2 = new CSEAccountAreaSalesSelector().selectByAccountId(new Set<Id>{accountAreaSales.Id});
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(test1 != null);
		System.assert(test2 != null);
    }
}