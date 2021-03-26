@isTest
private class ZTProfileDAO
{
    static testMethod void testAll()
    {
    	// Start Test
		System.Test.startTest();
		
    	Profile aProfile = ProfileDAO.selectProfileByNameForTests('Administrador do sistema');
    	
    	// Stop Test
		System.Test.stopTest();
		
		// Verify data
		System.assert(aProfile != null);
    }
}