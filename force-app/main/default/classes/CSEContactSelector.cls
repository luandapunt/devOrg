public with sharing class CSEContactSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
    	return new List<Schema.SObjectField> {
    		Contact.Id,
    		Contact.Name,
    		Contact.Email,
    		Contact.Phone
    	};
    }
    
    public Schema.SObjectType getSObjectType() {
    	return Contact.sObjectType;
    }
    
    public List<Contact> selectById(Set<Id> idSet) {
    	String query = String.format(
    		' SELECT {0} ' +
    		' FROM {1}' +
    		' WHERE Id IN :idSet' +
    		' ORDER BY {2}',
    		new List<String>{
    			getFieldListString(),
                getSObjectName(),               
                getOrderBy()  
    		}
    	);
    	
    	return (List<Contact>)Database.query(query);
    }
}