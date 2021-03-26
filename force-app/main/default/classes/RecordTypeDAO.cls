public with sharing class RecordTypeDAO {
	
	public static List<RecordType> getBySObjectName(String sObjectTypeName) {
        return [SELECT Id,
                       DeveloperName,
                       Name,
                       SobjectType 
                  FROM RecordType 
                 WHERE SobjectType = :sObjectTypeName];
	}
 	
 	// Key is objectName
 	public static Map<String, Map<String, Id>> mapRecordTypeDevNameCache = new Map<String, Map<String, Id>>();
 	
 	// Cached version
	// Return a map of recordTypes by DevName
	public static Map<String, Id> selectRecordTypeDevNameMapByObjectNameSetCached(Set<String> setObjectName)
	{
		// Check if the object is cached or not
		Set<String> setObjectNameToSearch = new Set<String>();
		for (String objectName : setObjectName)
		{
			if (!mapRecordTypeDevNameCache.containsKey(objectName)) {
				 setObjectNameToSearch.add(objectName);
			}
		}
		
		// Fetch values from DB
		if (!setObjectNameToSearch.isEmpty())
		{
        	List<RecordType> lstRecordType = [SELECT Id, Name, DeveloperName, SObjectType
                                                FROM RecordType
                                                WHERE SObjectType IN :setObjectName];
        	for (RecordType recType : lstRecordType)
        	{
        		Map<String, Id> mapRecType = mapRecordTypeDevNameCache.get(recType.SObjectType);
        		if (mapRecType == null)
        			mapRecType = new Map<String, Id>();	
        		mapRecType.put(recType.DeveloperName, recType.Id);
        		
        		mapRecordTypeDevNameCache.put(recType.SObjectType, mapRecType);
        	}
		}
		
		// Return values
		Map<String, Id> mapRecordTypeToReturn = new Map<String, Id>(); 
		for (String objectName : setObjectName) {
			mapRecordTypeToReturn.putAll(mapRecordTypeDevNameCache.get(objectName));	
		}
		return mapRecordTypeToReturn;	
	}  

	public static Map<String, Id> getRecordTypeMap (String sObjectType) {

		Map<String, Id> recordMap = new Map<String, Id>();

		List<RecordType> recordTyp = [SELECT Id, DeveloperName FROM RecordType where SobjectType = :sObjectType];
    	
        for(RecordType rec : recordTyp) {
            
    		recordMap.put(rec.DeveloperName, rec.Id);
    	}

    	return recordMap;
	} 
}