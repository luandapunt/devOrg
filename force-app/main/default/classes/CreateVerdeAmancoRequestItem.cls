public class CreateVerdeAmancoRequestItem {

    private final VerdeAmancoSolicitation__c ri;
    public List<KitItemWrapper> kititemList {get;set;}
    public Integer createdItemsCount {get;set;}

    public CreateVerdeAmancoRequestItem(ApexPages.StandardController stdController) {
        this.ri = (VerdeAmancoSolicitation__c)stdController.getRecord();
        kititemList = new list<KitItemWrapper>();
        kititemList = itemsGet();
        system.debug(kitItemList);
    }
    

	public class KitItemWrapper {
		public VerdeAmancoKitItem__c kititem {get; set;}
		public Boolean selected {get; set;}
        public Integer amount {get;set;}
        public Boolean requestItemCreated {get;set;}        
        
		public KitItemWrapper(VerdeAmancoKitItem__c ki, Integer maxAmount){
			kititem = ki;
			selected = true;
            amount = maxAmount;
            requestItemCreated = false;
		}
	}	

	
	public List<KitItemWrapper> itemsGet() {
        List<VerdeAmancoSolicitation__c> kit =   [SELECT VerdeAmancoKitLkp__c, HasItemsBln__c 
            FROM VerdeAmancoSolicitation__c
            WHERE Id =:ri.Id];
        List<KitItemWrapper> listAux = new List<KitItemWrapper>();

        if(kit!=null){
	        List<VerdeAmancoKitItem__c> results =   [SELECT Id, Name, MaximumAmountNmb__c
	            FROM VerdeAmancoKitItem__c
	            WHERE VerdeAmancoKitLkp__c = :kit[0].VerdeAmancoKitLkp__c
                Order By Name];

	        for(VerdeAmancoKitItem__c ki : results){
	        	listAux.add(new KitItemWrapper(ki, Integer.valueOf(ki.MaximumAmountNmb__c)));
	        }
	    }
		return listAux;
	}


	public void saveSelected() {

		List<VerdeAmancoKitItem__c> selectedKititems = new List<VerdeAmancoKitItem__c>();
		List<VerdeAmancoRequestItem__c> requestitems = new List<VerdeAmancoRequestItem__c>();
        List<Integer> amountitems = new List<Integer>();
        List<VerdeAmancoRequestItem__c> requestItemToUpdate = new List<VerdeAmancoRequestItem__c>();
        List<VerdeAmancoRequestItem__c> requestItemToDelete = new List<VerdeAmancoRequestItem__c>();
        List<VerdeAmancoRequestItem__c> createdRIs = [Select Id, AmountNmb__c, VerdeAmancoKitItemLkp__c, VerdeAmancoKitItemLkp__r.MaximumAmountNmb__c
                                                      From VerdeAmancoRequestItem__c
                                                      Where VerdeAmancoSolicitationIdLkp__c = :ri.Id];
        
		createdItemsCount = 0;		
        
        for(KitItemWrapper kiw: kititemList) {
            for(VerdeAmancoRequestItem__c item: createdRIs){
                if(kiw.kititem.Id == item.VerdeAmancoKitItemLkp__c && kiw.selected == true){ 
                    kiw.requestItemCreated = true;
                    item.AmountNmb__c = kiw.amount;
                    requestItemToUpdate.add(item);
                    createdItemsCount += 1;
                }
                if(kiw.kititem.Id == item.VerdeAmancoKitItemLkp__c && kiw.selected == false){
                    requestItemToDelete.add(item);
                }
            }
        }
        
        for(KitItemWrapper kiw: kititemList) {
            system.debug(kiw);
			if(kiw.selected == true && kiw.requestItemCreated == false) {
				selectedKititems.add(kiw.kititem);
                amountitems.add(kiw.amount);
                createdItemsCount += 1;
			}
		}
        
        ri.HasItemsBln__c = createdItemsCount != 0 ? true : false;
        
        if(!selectedKititems.isEmpty() || !requestItemToUpdate.isEmpty() || !requestItemToDelete.isEmpty()){
            for(VerdeAmancoKitItem__c ki : selectedKititems){
                requestitems.add(new VerdeAmancoRequestItem__c());
            }
            
            for(Integer i=0;i<requestitems.size();i++){
                requestitems[i].VerdeAmancoSolicitationIdLkp__c = ri.Id;
                requestitems[i].VerdeAmancoKitItemLkp__c = selectedKititems[i].Id;
                requestitems[i].Name = selectedKititems[i].Name;
                requestitems[i].AmountNmb__c = amountitems[i];                
            }

            try{
                system.debug(requestitems);
                system.debug(requestItemToUpdate);                
                update ri;
                upsert requestitems;
                update requestItemToUpdate;
                delete requestItemToDelete;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Os itens selecionados foram incluídos na solicitação!'));
            }
            catch (exception e){
                ApexPages.addMessages(e);
                
            }
             
        }
       	//kititemList=null; 
        
        system.debug('Qtde de itens criados: ' + createdItemsCount);
        system.debug('Possui Itens? ' + ri.HasItemsBln__c);
	}
        
}