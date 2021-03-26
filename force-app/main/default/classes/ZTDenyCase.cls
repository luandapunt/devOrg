@isTest
private class ZTDenyCase {
    static testMethod void testAll() {
    	System.Test.startTest();
    	
    	PageReference pageRef = Page.DenyCase;
    	Test.setCurrentPage(pageRef);
    
    	DenyCaseCtrl pagina = new DenyCaseCtrl();
    	pagina.redirect();
    
    	System.Test.stopTest();
    }
}