public class RecordTypeMap {
    private static RecordTypeMap instance = null;
    public Map<String, Map<String, Id>> rtMap {get; private set;}
    
    private RecordTypeMap(){
        List<RecordType> recTypeList= [SELECT DeveloperName, SobjectType, Id FROM RecordType];
        rtMap = new Map<String, Map<String, Id>>();
        
        for(RecordType rt : recTypeList){
            if(rtMap.containsKey(rt.SobjectType)){
                rtMap.get(rt.SobjectType).put(rt.DeveloperName, rt.Id);
            }
            else{
                Map<String, Id> mapSObjectType = new Map<String, Id>();
                mapSObjectType.put(rt.DeveloperName, rt.Id);
                rtMap.put(rt.SobjectType, mapSObjectType);
            }
        }

        /*for (String KeyObjType : rtMap.keySet()) {
            Map<String, Id> mapObjType = rtMap.get(KeyObjType);
            System.debug('MAPA: '+KeyObjType);
            for(String KeyDevName : mapObjType.keySet()){
                System.debug(keyDevName+' - '+mapObjType.get(KeyDevName));
            }
        }*/      
    }
            
    public static RecordTypeMap getInstance(){
        if(instance == null) instance = new RecordTypeMap();
        return instance;
    }
}