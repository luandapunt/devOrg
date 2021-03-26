public with sharing class CaseDAO {
	
	public static List<Case> getById(Set<Id> idSet) {
		return [SELECT 
					Id,
					ComplaintNatureTxt__c,
					NonConformityTxt__c ,
					OrderLkp__c,
					OrderLkp__r.VolumeNmb__c,
					OrderLkp__r.WeightNmb__c,
					Status,
					RecordTypeId
				FROM Case 
				WHERE Id IN :idSet];
	}
    
    public static Map<Id, Case> selectByIdSet(Set<Id> idSet)
    {
		Map<Id, Case> caseById = new Map<Id, Case>(
			[SELECT Id, RecordTypeId, Status, Type
			   FROM Case 
			  WHERE Id IN :idSet]);
		return caseById;
	}
}