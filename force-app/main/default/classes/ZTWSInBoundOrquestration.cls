@isTest
private class ZTWSInBoundOrquestration
{
    static testMethod void testAll()
    {
    	// Prepare test data
    	WSInBoundOrquestration.WSInBoundOrquestrationVO vo = new WSInBoundOrquestration.WSInBoundOrquestrationVO();
    	
    	// Start Test
		System.Test.startTest();
		
		try {
    		WSInBoundOrquestration.WSInBoundOrquestrationVO test01 = WSInBoundOrquestration.execute(vo);
		}
		catch (Exception ex) {}
		
		try {
    		WSInBoundOrquestration.WSInBoundOrquestrationVO test02 = WSInBoundOrquestration.executePost(vo);
		}
    	catch (Exception ex) {}
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		//System.assert(lstAccountAddress != null);
    }
}