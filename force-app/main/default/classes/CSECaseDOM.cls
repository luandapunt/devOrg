public without sharing class CSECaseDOM extends fflib_SObjectDomain implements ITestAble {
    
    private CSECaseBO caseBo = new CSECaseBO();
    
    public CSECaseDOM(List<Case> sObjectList){
        super((List<SObject>)sObjectList);
    }

	/*
	public override ICustomFieldConfigurator getCustomIdConfigurator() {
		return new UniqueIdConfigurator();
	}
	
	//define customized id for case
	public override Schema.SObjectField getCustomIdFieldName() {
		//return Case.CustomIdTxt__c;
		return null;
	}
	
    //configure field that compose customed id
    public override List<Schema.SObjectField> getCustomIdFieldList() {
		return new List<Schema.SObjectField>{
			Case.CaseNumber
		};
	}
	*/
    
    public override void onBeforeInsert(){
     	//caseBo.setCarrierAndAccountEmail((List<Case>)records);
     	caseBO.setInitialStatusReposicao((List<Case>)records);
     	
     	caseBO.setEntitlement((List<Case>)records);
        
        caseBO.setInvoiceData((List<Case>) records);
     	
         //RSILVA 10/01/2018
        caseBO.setInvoiceData((List<Case>) records);
        
        //GOLIVEIRA 19/01/2018
        caseBO.setAreaSalesData((List<Case>) records);
    }
    
    public override void onAfterInsert() { 
    	Set<Id> caseIdSet = new Set<Id>();
        for (Case cse : (List<Case>)records){
        	caseIdSet.add(cse.Id);
        }
        caseBo.setExternalId(caseIdSet);
        
        //this sections force the class to send an email always when you create a case and the status is described in class
        List<Case> workAroundList = new List<Case>();
        workAroundList.add(new Case(Status = ' '));
              
        caseBo.sendEmail(workAroundList, (List<Case>)records);
    }
    
    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {	
    	if (existingRecords != null) {
    		List<Case> auxCase = new List<Case>();
    		
    		for(Id aux : existingRecords.keySet()) {
    			auxCase.add((Case)existingRecords.get(aux));
    		}
    		
			//caseBo.sendEmailPart2(auxCase, (List<Case>)records);
			
    	}
    	
    	
    } 
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
    	if (existingRecords != null) {
    		List<Case> auxCase = new List<Case>();
    		
    		for(Id aux : existingRecords.keySet()) {
    			auxCase.add((Case)existingRecords.get(aux));
    		}
    		
			caseBo.sendEmail(auxCase, (List<Case>)records);			
    	}
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CSECaseDOM(sObjectList);
        }
    }
    
    public static Case getSampleObject() {
        return new Case (); 
    } 
}