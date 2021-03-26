public with sharing class CaseInvoiceItemsDAO {
	public String id {get;set;}
    public String invoiceNumber {get;set;}
    public String invoiceLpk {get;set;}
    public String mandate {get;set;}
    public Decimal quota {get;set;}
    public Decimal daysToExtend {get;set;}
    public String orderLkp {get;set;}
    public Decimal credit {get;set;}
    public Boolean selected {get;set;}
    public Id caseId {get;set;}
   
    public CaseInvoiceItemsDAO(String invoiceNumber, String invoiceLpk, Id caseId) {
    	this.id = '';
    	this.invoiceNumber = invoiceNumber;
    	this.mandate = '';
    	this.quota = 0;
    	this.daysToExtend = 0;
    	this.credit = 0.0;
    	this.orderLkp = '';
    	this.selected = false;
    	this.invoiceLpk = invoiceLpk;
    	this.caseId = caseId;
    }
    
    public CaseInvoiceItemsDAO(String invoiceNumber, String invoiceLpk, String mandate, String orderLkp, Id caseId) {
    	this.id = '';
    	this.invoiceNumber = invoiceNumber;
    	this.mandate = mandate;
    	this.quota = 0;
    	this.daysToExtend = 0;
    	this.credit = 0.0;
    	this.orderLkp = orderLkp;
    	this.selected = false;
    	this.invoiceLpk = invoiceLpk;
    	this.caseId = caseId;
    }
    
    public CaseInvoiceItemsDAO(Id id, String invoiceNumber, Id invoiceLpk, String mandate, Id orderLkp, Decimal quota, Decimal daysToExtend, Decimal credit, Id caseId) {
    	this.id = id;
    	this.invoiceNumber = invoiceNumber;
    	this.mandate = mandate;
    	this.quota = quota;
    	this.daysToExtend = daysToExtend;
    	this.credit = credit;
    	this.orderLkp = orderLkp;
    	this.selected = false;
    	this.invoiceLpk = invoiceLpk;
    	this.caseId = caseId;
    }
    
}