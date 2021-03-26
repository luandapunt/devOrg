public with sharing class CSEOrderDOM extends fflib_SObjectDomain implements ITestAble {
    CSEOrderBO orderBO = new CSEOrderBO();
    public CSEOrderDOM(List<Order__c> sObjectList){
        super((List<SObject>)sObjectList);
    }
    
    public override void onBeforeInsert(){
        
        orderBO.setCarrierDescription((List<Order__c>) records);
        
        orderBO.setSalesAreaOrAccount((List<Order__c>) records);
        
        orderBo.setOwner((List<Order__c>) records);
        
        List<Order__c> listOrders = new List<Order__c>();
        for(Order__c o : (List<Order__c>) records){
            if((o.PaymentTermLkp__c == null && o.PaymentTermTxt__c != null) || (o.OrderTypeLkp__c == null && o.OrderTypePicklistTxt__c != null))
                listOrders.add(o);
        }
        if(listOrders.size() > 0)
            orderBO.setPaymentTermAndOrderType((List<Order__c>) listOrders);
        
        orderBO.validateOrderType((List<Order__c>) records);
                
        for(Order__c o : (List<Order__c>) records){
            if(o.OpportunityLkp__c != null) o.PrimaryBln__c = true;
        }
        //orderBO.setAccountReceiver((List<Order__c>) records);
      
    }

    public override void onAfterInsert(){
     	// Set status in Case
     	//orderBO.setStatusCase((List<Order__c>)records);
     	
     	// Set Order in Caso, field CreatedOrderLkp__c
     	orderBO.setOrderInCase((List<Order__c>)records);
        
        
        List<Id> listPrimary = new List<Id>();
        List<Order__c> listNewOrders = new List<Order__c>();
        
        for(Order__c o : (List<Order__c>)records){
            if(o.AccountLkp__c != null && o.AccountAreaSalesLkp__c != null && o.CustomIdTxt__c == null && !System.Test.isRunningTest()){
                OrderIntegrationUtils.createQuoteOnSAPFuture(o.Id);
            }
            if(o.AccountLkp__c != null){
                listNewOrders.add(o);
            }
            if(o.OpportunityLkp__c != null && o.PrimaryBln__c == true){
                listPrimary.add(o.Id);
            }
        }
        try{
            orderBO.setPrimaryOrders(listPrimary);
            orderBO.setPurchaseDateAccount(listNewOrders);
        }
        catch(Exception e){
            records[0].addError(e.getMessage());
        }
    }
    
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords){
        orderBO.setCarrierDescription((List<Order__c>) records);
        
        List<Order__c> listOrders = new List<Order__c>();
        for(Order__c o : (List<Order__c>)records){
            Order__c oldOrder = (Order__c) existingRecords.get(o.Id);
            if(oldOrder.PaymentTermTxt__c != o.PaymentTermTxt__c || oldOrder.OrderTypePicklistTxt__c != o.OrderTypePicklistTxt__c){
                listOrders.add(o);
            }
        }
        try{
            orderBO.setPaymentTermAndOrderType(listOrders);
        }
        catch(Exception e){
            records[0].addError(e.getMessage());
        }
    }
    
    public override void onAfterUpdate(Map<Id,SObject> existingRecords){
    	if (existingRecords != null) {
            //orderBO.setStatusCase((List<Order__c>)records);
            List<Order__c> listChangedPaymentTerm = new List<Order__c>();
            //List<Order__c> listSentToSAP = new List<Order__c>();
            List<Id> listPrimary = new List<Id>();
            
            orderBO.setOrderInCase((List<Order__c>)records);
            
            for(Order__c o : (List<Order__c>)records){
                Order__c oldOrder = (Order__c) existingRecords.get(o.Id);
                if(o.OpportunityLkp__c != null && o.PrimaryBln__c == true && oldOrder.PrimaryBln__c == false){
                    listPrimary.add(o.Id);
                }
                
                if(oldOrder.PaymentTermTxt__c != o.PaymentTermTxt__c && o.OrderStatusTxt__c == 'Rascunho'){
                    listChangedPaymentTerm.add(o);
                }
                /*if(o.CustomIDTxt__c != null && o.OrderStatusTxt__c == 'SentToSAP' && o.OrderStatusTxt__c != oldOrder.OrderStatusTxt__c)
                    listSentToSAP.add(o);
*/
            }
            try{
                orderBO.setPrimaryOrders(listPrimary);
                orderBO.recalculatePrices(listChangedPaymentTerm);
                //orderBO.updateOrderSAP(listSentToSAP);
            }
            catch(Exception e){
                records[0].addError(e.getMessage());
            }
        }
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new CSEOrderDOM(sObjectList);
        }
    }

    public static Order__c getSampleObject() {
        return new Order__c();
    }
}