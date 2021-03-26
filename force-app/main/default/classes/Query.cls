public without sharing class Query {

	public enum QueryConditionType {
		EQUALS, NOT_EQUALS
	}
	
	public class QueryCondition {
		public Schema.SObjectField field;
		public QueryConditionType conditionType;
		public Object value;
		
		public QueryCondition(Schema.SObjectField field, QueryConditionType conditionType, Object value){
			this.field = field;
			this.conditionType = conditionType;
			this.value = value;
		}
	}
	
	private List<QueryCondition> conditionList;
	private Integer queryLimit;
	private String queryOrderByField;
	private Map<String, String> relationShipNameMap;
    private Schema.DescribeSObjectResult sobjectDescribeResult;
    
    private Map<QueryConditionType, String> mapSymbol = new Map<QueryConditionType, String>{
    	QueryConditionType.EQUALS => 'IN',
    	QueryConditionType.NOT_EQUALS => 'NOT IN'
    };
    
    public Query(Schema.sObjectType soType){
    	this.sobjectDescribeResult = soType.getDescribe();
    	this.conditionList = new List<QueryCondition>();
    	this.relationShipNameMap = new Map<String, String>();
    	this.queryOrderByField = 'Name';
    	this.queryLimit = 10000;
    }
    
    public Query find(List<QueryCondition> conditionList){
    	System.debug('conditionList' + conditionList);
    	this.conditionList.addAll(conditionList);
    	return this;
    }

/*    public Query findOne(List<QueryCondition> conditionList){
    	return this;
    }

    public Query findOne(){
    	return this;
    }

    public Query findAll(Set<Id> idSet){
    	this.conditionList.add(new QueryCondition(DocumentoPrecomite__c.Id, QueryConditionType.EQUALS, idSet));
    	return this;
    }*/

    public Query wherez(){
    	return this;
    }

    public Query with(List<String> relationShipNameList){
    	for (String relName : relationShipNameList) {
    		this.relationShipNameMap.put(relName, relName);
    	}
    	return this;
    }
    
    public Query limitTo(Integer lmit){
    	this.queryLimit = lmit;
    	return this;
    }

    public Query orderBy(String field){
    	this.queryOrderByField = field;
    	return this;
    }

    public Query with(String relationShipName){
    	this.relationShipNameMap.put(relationShipName, relationShipName);
    	return this;
    }
    
    public List<SObject> all(){
    	this.limitTo(50000);
    	System.debug(this.toSOQL());
    	return Database.query(this.toSOQL());
    }
    
    public String toSOQL(){
    	
    	Soql soqlGenerator = new Soql();
    	
    	//add field list of main SObject
    	soqlGenerator.addLine(String.format('SELECT {0} ', new List<String>{
    		this.toCommaSeparateString(this.getFieldList())
    	}));
		
		//add relationship
		List<Schema.ChildRelationship> relatedList = this.sobjectDescribeResult.getChildRelationships();
		for (Schema.ChildRelationship rel : relatedList) {
			
			Schema.DescribeSObjectResult childDescResult = rel.getChildSObject().getDescribe();
			Query qry = new Query(rel.getChildSObject());
			if (this.relationShipNameMap.containsKey(rel.getRelationshipName()) 
				&& rel.getRelationshipName() != null 
				&& childDescResult.isAccessible()) {
					//todo refator to use query
					soqlGenerator.addLine(String.format(', (SELECT {0} FROM {1} ) ', new List<String>{
						qry.getFieldListAsString(new List<String>{'Id', 'OwnerId'}),
						rel.getRelationshipName()		
					})); 	
			}
			
		}

		//add from statement
		soqlGenerator.addLine(' FROM ' + sobjectDescribeResult.getName());
		
		List<String> expList = new List<String>(); 
		System.debug(this.conditionList);
		
		if (!conditionList.isEmpty()){
			soqlGenerator.addLine(' WHERE ');
		}
		
		for (Integer i = 0; i < this.conditionList.size(); i++) {
			
			//apex can bind array position like this.coditionList[0]
			//so we need convert values to string
			QueryCondition cond = this.conditionList[0];
			String vString = '';
			if (cond.value instanceof Set<String>){
				List<String> strList = new List<String>((Set<String>)cond.Value);
				vString = '(\'' + String.join((List<String>)cond.value, '\',\'') + '\')';
			} if (cond.value instanceof Set<Id>){
				List<String> strList = new List<String>();
				for (Id id : (Set<Id>)cond.Value){
					strList.add(id);
				}
				vString = '(\'' + String.join(strList, '\',\'') + '\')';
			} else if (cond.value instanceof List<String>) {
				vString = '(\'' + String.join((List<String>)cond.value, '\',\'') + '\')';
			}
			
			expList.add(cond.field.getDescribe().getName() + ' ' + this.mapSymbol.get(cond.conditionType) + ' ' + vString);
		}

		//add where statements
		soqlGenerator.addLine(String.join(expList, ' AND '));
		
		soqlGenerator.addLine(' ORDER BY ' + this.queryOrderByField);
		soqlGenerator.addLine(' LIMIT ' + this.queryLimit);
		return soqlGenerator.toString();		
    	
    }
    
    private String getFieldListAsString(List<String> stringList) {
    	List<String> newFieldList = new List<String>();
    	Map <String, Schema.SObjectField> fieldMap = this.sobjectDescribeResult.fields.getMap(); 
    	for (String fieldName : stringList) {
    		if (fieldMap.containsKey(fieldName)){
    			Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();
    			if (field.isAccessible()){
    				newFieldList.add(field.getName());
    			}
    		}
    	}
    	return toCommaSeparateString(newFieldList);
    }

    private String getFieldListAsString() {
    	return toCommaSeparateString(new List<String>(this.sobjectDescribeResult.fields.getMap().keySet()));
    }
    
    public List<String> getFieldList() {
    	
    	List<String> stringList = new List<String>();
    	for (Schema.SObjectField  fieldToken : this.sobjectDescribeResult.fields.getMap().values()) {
    		Schema.DescribeFieldResult field = fieldToken.getDescribe();
	    		if (field.isAccessible()) {
	    			stringList.add(field.getName());
	    		}
    	}
    	
    	return stringList;
    }

    private String toCommaSeparateString(List<String> stringList) {
    	return String.join(stringList, ',');
    }
    
}