public with sharing class CSECaseItemSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
    	return new List<Schema.SObjectField> {
    		CaseItem__c.Id,
    		CaseItem__c.CaseMdt__c,
    		CaseItem__c.ProductLkp__c,
    		CaseItem__c.QuantityNmb__c,
    		CaseItem__c.FailureTypeTxt__c,
    		CaseItem__c.CommentsTxt__c,
    		CaseItem__c.QualityProblemTxt__c,
    		CaseItem__c.ProductChangedLkp__c,
    		CaseItem__c.ManufacturingCenterTxt__c,
    		CaseItem__c.ProductSalesOrganizationTxt__c,
    		CaseItem__c.ProductDistributionChannelTxt__c,
    		CaseItem__c.ProductActivitySectorTxt__c,
    		CaseItem__c.ProductSalesOfficeTxt__c,
    		CaseItem__c.ProductSalesTeamTxt__c,
    		CaseItem__c.QMLkp__c
    	};
    }
    
    public Schema.SObjectType getSObjectType() {
    	return CaseItem__c.sObjectType;
    }
    
    public List<CaseItem__c> selectById(Set<Id> idSet) {
    	String query = String.format(
    		' SELECT {0}' +
    		' FROM {1}' +
    		' WHERE Id IN :idSet' +
    		' ORDER BY {2}',
    		new List<String>{
    			getFieldListString(),
    			getSObjectName(),
    			getOrderBy()
    		}
    	);
    	return (List<CaseItem__c>)Database.query(query);
    }
    
    public List<CaseItem__c> selectByCaseId(Id caseId) {
    	String query = String.format(
    		' SELECT {0}' +
    		' FROM {1}' +
    		' WHERE CaseMdt__c = :caseId' +
    		' ORDER BY {2}',
    		new List<String>{
    			getFieldListString(),
    			getSObjectName(),
    			getOrderBy()
    		}
    	);
    	return (List<CaseItem__c>)Database.query(query);
    }
}