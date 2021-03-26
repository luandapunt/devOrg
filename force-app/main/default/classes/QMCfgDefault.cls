public virtual class QMCfgDefault implements IQMConfigurator {
	
	public virtual String getRecordTypeDevName() {
		return null;
	}
	
	public virtual QM__c configure(QM__c qm, Case cse) {
		qm.CaseLkp__c = cse.Id;
		//qm.ManufacturingCenterTxt__c = cse.OrderLkp__r.CodeSalesOrganizationTxt__c;
		//qm.SellerLkp__c = cse.OrderLkp__r.SellerLkp__c;
		//qm.ClientOrderTxt__c = cse.OrderLkp__r.Name;
		//qm.ComplaintReasonTxt__c = cse.ComplaintNatureTxt__c;
		//qm.RecordTxt__c = cse.RecordTxt__c;
		//qm.NonConformityTxt__c = cse.NonConformityTxt__c;
		//qm.InvoiceLkp__c = cse.InvoiceLkp__c;
		return qm;
	}
    
}