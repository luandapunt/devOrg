public with sharing class CSERecordTypeSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
    	return new List<Schema.SObjectField> {
    		RecordType.Id,
    		RecordType.Name
    	};
    }
    
    public Schema.SObjectType getSObjectType() {
    	return RecordType.getSObjectType();
    }
    
    public List<RecordType> selectById(Set<Id> idSet) {
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
    	return (List<RecordType>)Database.query(query);
    }
}