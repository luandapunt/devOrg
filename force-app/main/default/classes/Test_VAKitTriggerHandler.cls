@isTest
private class Test_VAKitTriggerHandler {
    
    @isTest static void insertActiveKit(){
        Channel__c chn = TestData.createChannel('TES', null);
        VerdeAmancoKit__c kit = TestData.createVerdeAmancoKit('kitTES', chn.Id, true);
        chn = [Select Id, ActiveVerdeAmancoKitLkp__c
               From Channel__c
               Where Id = :chn.Id];
        System.assertEquals(kit.Id, chn.ActiveVerdeAmancoKitLkp__c);
        
    }
    
    @isTest static void updateActiveKit(){
        Channel__c chn = TestData.createChannel('TES', null);
        VerdeAmancoKit__c kit = TestData.createVerdeAmancoKit('kitTES', chn.Id, false);
        VerdeAmancoKit__c oldKit = TestData.createVerdeAmancoKit('oldKitTES', chn.Id, true);
        kit.ActiveBln__c = true;
        update kit;
        chn = [Select Id, ActiveVerdeAmancoKitLkp__c
               From Channel__c
               Where Id = :chn.Id];
        oldKit = [Select Id, ActiveBln__c
                  From VerdeAmancoKit__c
                  Where Id = :oldKit.Id];
        System.assertEquals(kit.Id, chn.ActiveVerdeAmancoKitLkp__c);
        System.assertEquals(false, oldKit.ActiveBln__c);
        
    }  

}