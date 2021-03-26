global with sharing class OrderService extends integ_SyncIntegrationServiceAbstract  {
    
    global static OrderService instance;
    
    public OrderService(){
        
    }
    
    //************************************************************//
    
    @AuraEnabled
    public static Order__c getorder(Id orderId) {
        system.debug('orderId'+ orderId);      
        
        List<Order__c> order = [
            
            SELECT Id, Name, CustomIDTxt__c, QuotationBln__c, OrderStatusTxt__c 
            FROM Order__c 
            WHERE Id = :orderId
        ];
        system.debug('order'+ order);
        if(order.size()>0)
            return order[0];
        else
            return null;     
    }
    
    @AuraEnabled
    public static Remittance__c getorderRemittance(Id remittanceId) {
        system.debug('remittanceId'+ remittanceId);      
        
        List<Remittance__c> orderRemittance = [
            
            SELECT Id, Name, OrderLkp__r.CustomIDTxt__c 
            FROM Remittance__c 
            WHERE Id = :remittanceId
            LIMIT 1
        ];
        system.debug('orderRemittance'+ orderRemittance);
        if(orderRemittance.size()>0)
            return orderRemittance[0];
        else
            return null;     
    }
    
    @AuraEnabled
    public static Invoice__c getinvoice(Id invoiceId) {
        system.debug('invoiceId'+ invoiceId);      
        
        List<Invoice__c> invoice = [
            
            SELECT Id, Name, AccountLkp__r.CodeCustomerTxt__c 
            FROM Invoice__c 
            WHERE Id = :invoiceId
            LIMIT 1
        ];
        system.debug('invoice'+ invoice);
        if(invoice.size()>0)
            return invoice[0];
        else
            return null;     
    }
    //************************************************************//
    
    public static OrderService getInstance() {
        if (instance == null) {
            instance = new OrderService();
        }
        return instance;
    }
    
    /*
Executes SYNC_ORDER_OUTBOUND syncrony
*/
    @AuraEnabled
    webservice static List<Invoice__c> getInvoiceList(String invoiceNumber, String customerCode){
        return getInstance().retrieveInvoiceFromSAP(invoiceNumber, customerCode, null);
    }
    @AuraEnabled
    webservice static List<Invoice__c> getInvoiceListByOrderNumber(String orderNumber){
        System.debug('*** ' + orderNumber);
        return getInstance().retrieveInvoiceFromSAP(null, null, orderNumber);
    }
    @AuraEnabled
    webservice static List<Invoice__c> getInvoiceListLast30Days(String customerCode){
        return getInstance().retrieveInvoiceFromSAP(null, customerCode, null);
    }
    
    @future(callout=true)
    public static void getInvoiceListByOrderNumberFuture(String orderNum){
        getInvoiceListByOrderNumber(orderNum);
    }
    
    private List<Invoice__c> retrieveInvoiceFromSAP(String invoiceNumber, String customerCode, String orderNumber) {
        OrderRemoteCall remoteCall = new OrderRemoteCall(invoiceNumber, customerCode, orderNumber);
        return (List<Invoice__c>)super.execute(IntegrationIds.SYNC_ORDER_OUTBOUND.name(), remoteCall);
    }
    
}