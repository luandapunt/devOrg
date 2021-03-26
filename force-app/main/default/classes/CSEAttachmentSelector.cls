public with sharing class CSEAttachmentSelector extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Attachment.Id,
			Attachment.Name,
			Attachment.Body,
			Attachment.ContentType,
			Attachment.ParentId
		};
	}
	
	public Schema.SObjectType getSObjectType() {
		return Attachment.sObjectType;
	}

    public List<Attachment> selectById(Set<Id> idSet) {

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
        return (List<Attachment>)Database.query(query);       
    }
	
    public List<Attachment> selectByCase(Set<Id> idSet) {

        String query = String.format(
            ' SELECT {0}' + 
            ' FROM {1}' +
            ' WHERE ParentId IN :idSet ' +
            ' ORDER BY {2}',
            new List<String>{
                getFieldListString(),
                getSObjectName(),               
                getOrderBy()            
            }
        );  
        return (List<Attachment>)Database.query(query);       
    }
}