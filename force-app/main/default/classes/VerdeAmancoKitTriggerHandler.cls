public class VerdeAmancoKitTriggerHandler {
    public static void isBeforeInsert(List<VerdeAmancoKit__c> listVerdeAmancoKit, Map<Id, VerdeAmancoKit__c> oldMap){

    }
    public static void isBeforeUpdate(List<VerdeAmancoKit__c> listVerdeAmancoKit, Map<Id, VerdeAmancoKit__c> oldMap){
        
    }
    public static void isBeforeDelete(List<VerdeAmancoKit__c> listVerdeAmancoKit, Map<Id, VerdeAmancoKit__c> oldMap){

    }
    public static void isAfterInsert(List<VerdeAmancoKit__c> listVerdeAmancoKit, Map<Id, VerdeAmancoKit__c> oldMap){
            List<Id> listActiveKits = new List<Id>();
            
            
            for(VerdeAmancoKit__c o : listVerdeAmancoKit){
                //VerdeAmancoKit__c oldKit = oldMap.get(o.Id);
                //if(o.ChannelLkp__c != null && o.ActiveBln__c == true && oldKit.ActiveBln__c == false){
                //    listActiveKits.add(o.Id);
                //}
                if(o.ChannelLkp__c != null && o.ActiveBln__c == true){
                    listActiveKits.add(o.Id);
                }
            }
            try{
                setActiveKits(listActiveKits);
            }
            catch(Exception e){
                listVerdeAmancoKit[0].addError(e.getMessage());
            }
        
        
    }
    public static void isAfterUpdate(List<VerdeAmancoKit__c> listVerdeAmancoKit, Map<Id, VerdeAmancoKit__c> oldMap){
            List<Id> listActiveKits = new List<Id>();
            
            
            for(VerdeAmancoKit__c o : listVerdeAmancoKit){
                VerdeAmancoKit__c oldKit = oldMap.get(o.Id);
                if(o.ChannelLkp__c != null && o.ActiveBln__c == true && oldKit.ActiveBln__c == false){
                    listActiveKits.add(o.Id);
                }
            }
            try{
                setActiveKits(listActiveKits);
            }
            catch(Exception e){
                listVerdeAmancoKit[0].addError(e.getMessage());
            }
        
    }
    public static void isAfterDelete(List<VerdeAmancoKit__c> listVerdeAmancoKit, Map<Id, VerdeAmancoKit__c> oldMap){
        
    }
    
    public static void setActiveKits(List<Id> listActiveKitIds){
        List<VerdeAmancoKit__c> listkits = [SELECT Id, ChannelLkp__c, ActiveBln__c FROM VerdeAmancoKit__c WHERE Id IN :listActiveKitIds];
        List<VerdeAmancoKit__c> kitsToUpdate = new List<VerdeAmancoKit__c>();
        List<Channel__c> channelToUpdate = new List<Channel__c>();
        List<Id> listChnIds = new List<Id>();
        
        for(VerdeAmancoKit__c o : listkits){
            listChnIds.add(o.ChannelLkp__c);
           channelToUpdate.add(new Channel__c(Id = o.ChannelLkp__c, ActiveVerdeAmancoKitLkp__c = o.Id));
        }
        for(VerdeAmancoKit__c o : [SELECT Id FROM VerdeAmancoKit__c WHERE ChannelLkp__c IN :listChnIds AND Id NOT IN :listActiveKitIds]){
            o.ActiveBln__c = false;
           kitsToUpdate.add(o);
        }
        
        upsert channelToUpdate;
        upsert kitsToUpdate;
        
    }
}