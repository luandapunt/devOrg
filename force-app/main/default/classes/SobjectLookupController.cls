/**
	ClassName   : SobjectLookupController
	Description : Used as Typeahead lightning component's controller.
*/
public class SobjectLookupController 
{
    /**  
        @MethodName : getIconDetails
        @Param      : Object Name 
        @Description: Fetch ICON details using describeTabs via LightningUtility helper class.
    **/
	@AuraEnabled
    public static LightningUtility.TabIconDetails getIconDetails(String objectName) 
    {
        return LightningUtility.fetchTabIconDetails(objectName); 
    }
    
    /**  
        @MethodName : getSearchedArray
        @Param      : Object Name, Search Term
        @Description: Fetch Records based on search term
    **/
    @AuraEnabled
    public static String getSearchedArray(String objName, String searchTerm) 
    { 
        List<LookupWrapper> lstArr = new List<LookupWrapper>();
        String query = 'SELECT Id, Name FROM '+ objName; 
        if(String.isNotBlank(searchTerm))
        {
            query += ' WHERE Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'';
        }
        query += ' ORDER BY Name ASC LIMIT 500';
        
        //get records based the search-term
        for(sObject objsObject : Database.query(query)) {
            lstArr.add(new LookupWrapper(String.valueOf(objsObject.get('Name')), String.valueOf(objsObject.get('Id'))));
        }  
        return JSON.serialize(lstArr);
    }
    
    public class LookupWrapper 
    {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String id {get;set;}
        
        public LookupWrapper(String label, String id) 
        {
            this.label = label;
            this.id = id;
        }
    }
}