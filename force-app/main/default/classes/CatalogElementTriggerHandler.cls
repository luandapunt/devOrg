public class CatalogElementTriggerHandler {
    @future
    public static void processOrder(List<Id> listIds){
        List<CatalogElement__c> listParentElems = [SELECT Id, 
                                                   (SELECT ID, IndexNmb__c FROM ChildElements__r ORDER BY IndexNmb__c, Name) 
                                                   FROM CatalogElement__c WHERE Id IN :listIds];
        system.debug(listParentElems);
        List<Pricebook__c> listPb = [SELECT Id,
                                    (SELECT ID, IndexNmb__c FROM CatalogElements__r ORDER BY IndexNmb__c, Name)
                                    FROM Pricebook__c WHERE Id IN :listIds];
		//system.debug(listPb[0].CatalogElements__r);        
        List<CatalogElement__c> listChildElems = new List<CatalogElement__c>();
        for(CatalogElement__c parentElem : listParentElems){
            if(parentElem.ChildElements__r.size() > 1){
                Id firstChildId = parentElem.ChildElements__r[0].Id;
                Id lastChildId = parentElem.ChildElements__r[parentElem.ChildElements__r.size()-1].Id;
                for(Integer i = 0; i < parentElem.ChildElements__r.size(); i++){
                    CatalogElement__c currentElem = parentElem.ChildElements__r[i];
                    currentElem.PreviousElementLkp__c = (i == 0) ? lastChildId : parentElem.ChildElements__r[i-1].Id;
                    currentElem.NextElementLkp__c = (i == parentElem.ChildElements__r.size() - 1) ? firstChildId : parentElem.ChildElements__r[i+1].Id;
                    listChildElems.add(currentElem);
                }
            }
        }
        
        for(Pricebook__c pb : listPb){
            if(pb.CatalogElements__r.size() > 1){
                Id firstChildId = pb.CatalogElements__r[0].Id;
                Id lastChildId = pb.CatalogElements__r[pb.CatalogElements__r.size()-1].Id;
                for(Integer i = 0; i < pb.CatalogElements__r.size(); i++){
                    CatalogElement__c currentElem = pb.CatalogElements__r[i];
                    currentElem.PreviousElementLkp__c = (i == 0) ? lastChildId : pb.CatalogElements__r[i-1].Id;
                    currentElem.NextElementLkp__c = (i == pb.CatalogElements__r.size() - 1) ? firstChildId : pb.CatalogElements__r[i+1].Id;
                    listChildElems.add(currentElem);
                }
            }
        }
        
        update listChildElems;
    }

}