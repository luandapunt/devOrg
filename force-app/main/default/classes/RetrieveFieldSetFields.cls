@RestResource(urlMapping='/FieldSetFields/*') 
global with sharing class RetrieveFieldSetFields {

@HttpGet
    global static void getter(){
        String jsonResponse = getFields('SBQQ__QuoteLine__c', 'Apply_Fields');
        //return jsonResponse;
        /*Schema.FieldSet fs = Schema.SObjectType.SBQQ__QuoteLine__c.fieldSets.getMap().get('Apply_Fields');
        String query = 'SELECT ';
        for (Schema.FieldSetMember f: fs.getFields()){
            query += f.getFieldPath() + ', ';
        }
        query += */
    }
    
    public class CustomFieldDefinition{
        public String fieldName;
        public Boolean isRequired;
    }
    
    public static String getFields(String sobjectName, String fieldsetName){
       
        List<CustomFieldDefinition> resultList = new List<CustomFieldDefinition>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(sobjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
       
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
       
        List<Schema.FieldSetMember> fieldsetMembers = fieldSetObj.getFields();
        for(Schema.FieldSetMember member : fieldsetMembers){
            CustomFieldDefinition fd = new CustomFieldDefinition();
            fd.fieldName = member.getFieldPath();
            fd.isRequired = member.getRequired();
            system.debug(fd);
            resultList.add(fd);
        }
        return JSON.serialize(resultList);
    }
}