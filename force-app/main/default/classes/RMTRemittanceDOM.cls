public with sharing class RMTRemittanceDOM extends fflib_SObjectDomain implements ITestAble {
    
    RMTRemittanceBO remittanceBo = new RMTRemittanceBO();
    
    public RMTRemittanceDOM(List<Remittance__c> sObjectList){
        super((List<SObject>)sObjectList);
    }
    
    public override void onAfterInsert() { 
    	Set<Id> remittanceIdSet = new Set<Id>();
        for (Remittance__c rmt : (List<Remittance__c>)records){
        	remittanceIdSet.add(rmt.Id);
        }
        remittanceBo.verifyAndSetInvoiceToCase(remittanceIdSet);
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
    	if (existingRecords != null) {
    		    		
			remittanceBo.verifyAndSetInvoiceToCase(existingRecords.keySet());
			
    	}
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new RMTRemittanceDOM(sObjectList);
        }
    }
    
    public static Remittance__c getSampleObject() {
        return new Remittance__c(); 
    } 
    
}