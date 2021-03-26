public with sharing class SyncCustomerCtrl {

    public String dateToTxt {get;set;}
    public String dateFromTxt {get;set;}
    
    public Date dateTo {get;set;}
    public Date dateFrom {get;set;}
    
    public Account acc {get;set;}

    public SyncCustomerCtrl(ApexPages.StandardController stdController) {
        Id id = ApexPages.currentPage().getParameters().get('id');

        this.dateFrom = System.today().addDays(-30);
        this.dateFromTxt = this.dateFrom.format();

        this.dateTo = System.today();
        this.dateToTxt = this.dateTo.format();
        
        this.acc = new CSEAccountSelector().selectById(new Set<Id>{id})[0];
    }
    
    public PageReference goBack() {
        return new PageReference('/' + this.acc.Id);
    }
    
    public PageReference doSync() {
         
        this.dateFrom = Date.parse(this.dateFromTxt);
        this.dateTo = Date.parse(this.dateToTxt);
        
        try {
            CustomerService.getOrderByCustomer(this.acc.CodeCustomerTxt__c, this.dateFrom, this.dateTo);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Sincronizado com sucesso.'));
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
            return null;
        }

        return new PageReference('/' + this.acc.Id);
    }
    
}