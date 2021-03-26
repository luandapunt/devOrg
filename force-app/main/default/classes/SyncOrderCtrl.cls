public with sharing class SyncOrderCtrl {

    private CSEOrderSelector orderSelector = new CSEOrderSelector();

    public String orderCode {get;set;}
    public List<Order__c> orderList {get;set;}

    public SyncOrderCtrl() {

    }

    public PageReference findOrder(){

        this.orderList = new List<Order__c>();

        try {
    
            //At first time try to find in db
            this.orderList = this.retrieveOrderFromDB(orderCode);

            //if didnt find in db
            //try to find in sap
            if (/*this.orderList.isEmpty()*/true) {

                //load form sap
                this.syncOrderFromSAP(this.orderCode);

                //after sap sync try again to find in db
                this.orderList = this.retrieveOrderFromDB(orderCode);

            }


        } catch (Exception ex) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, ex.getMessage());
            ApexPages.addMessage(errMsg);
        }
        
        return null;
    }

    private List<Order__c> retrieveOrderFromDB(String orderNumber){
        return orderSelector.selectByNumber(orderNumber);
    }

    private void syncOrderFromSAP(String orderNumber){
        OrderService.getInvoiceListByOrderNumber(orderNumber);
    }

}