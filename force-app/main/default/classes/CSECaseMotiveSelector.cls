public with sharing class CSECaseMotiveSelector extends fflib_SObjectSelector{

    public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			CaseMotive__c.Id,
			CaseMotive__c.Name,
			CaseMotive__c.CaseTypeTxt__c,
			CaseMotive__c.Profile__c,
			CaseMotive__c.ContactTxt__c,
			CaseMotive__c.NatureTxt__c,
			CaseMotive__c.Category__c
		};
	}
	
	public Schema.SObjectType getSObjectType() {
		return CaseMotive__c.sObjectType;
	}

    public List<CaseMotive__c> selectAll() {
    	
        String query = String.format(
            ' SELECT {0}' + 
            ' FROM {1}' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()              
            }
        );  
        return (List<CaseMotive__c>)Database.query(query);       
    }
	
}