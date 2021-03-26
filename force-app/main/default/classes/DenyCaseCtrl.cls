public with sharing class DenyCaseCtrl {
		
    public DenyCaseCtrl() {
    	
    }
    
    public PageReference redirect() {
    	PageReference page = new PageReference('/500'); 
        page.setRedirect(true);  	
    	      	
        return page;
    }
}