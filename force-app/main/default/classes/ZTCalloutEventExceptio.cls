@isTest
private class ZTCalloutEventExceptio {
    static testMethod void testOne()
    {
    	String xml = '<Errors>' +
						'<Error>' +
							'<errorCode>INVALID_SESSION_ID</errorCode>' +
							'<message>Session expired or invalid</message>' +
						'</Error>' +
					 '</Errors>';
		
		Dom.Document doc = new Dom.Document();		 
		doc.load(xml);			 
					 
    	System.Test.startTest();
    	
    	try {
    		Integer i = 5/0;
    	} catch(Exception ex) {
    		CalloutEventException exp = new CalloutEventException(doc, ex);
    	}
    	
    	System.Test.stopTest();
    }
    
    static testMethod void testTwo()
    {
    						    
		System.Test.startTest();			    
					   
		CalloutEventException exp = new CalloutEventException('teste', 'teste');			   
					     	
    	System.Test.stopTest();
    }
    
    static testMethod void testThree()
    {
    	String xml = '<Errors>' +
						'<Error>' +
							'<errorCode>INVALID_SESSION_ID</errorCode>' +
							'<message>Session expired or invalid</message>' +
						'</Error>' +
					 '</Errors>';
		
		Dom.Document doc = new Dom.Document();		 
		doc.load(xml);			 
					 
    	System.Test.startTest();
    	    	
    	CalloutEventException exp = new CalloutEventException(doc, 'teste');    	
    	    	
    	System.Test.stopTest();
    }
}