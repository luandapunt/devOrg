public with sharing class CSEEmailMessageDOM extends fflib_SObjectDomain implements ITestAble {
    CSEEmailMessageBO emailMessageBO = new CSEEmailMessageBO();
    public CSEEmailMessageDOM(List<EmailMessage> sObjectList){
        super((List<SObject>)sObjectList);
    }

    public override void onAfterInsert(){
     	emailMessageBO.setStatus((List<EmailMessage>)records);
    }
      
     public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
    	if (existingRecords != null) {
    		List<EmailMessage> auxCase = new List<EmailMessage>();
    		
    		for(Id aux : existingRecords.keySet()) {
    			auxCase.add((EmailMessage)existingRecords.get(aux));
    		}
    		
			emailMessageBO.setStatus((List<EmailMessage>)records);
			
    	}
    }
    
    
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CSEEmailMessageDOM(sObjectList);
        }
    }

    public static EmailMessage getSampleObject() {
        return new EmailMessage ();
    }
}