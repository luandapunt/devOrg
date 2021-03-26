public virtual class QMCfgQMReposicaoItemI extends QMCfgDefault {

	public override String getRecordTypeDevName() {
		return 'QMReposicaoItemI';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		//qm.RetWithoutRemTxt__c = cse.DevolutionWithoutShippingTxt__c;
		//qm.ClientInvoiceBln__c = true;
		//qm.DevolutionTxt__c = 'Parcial';
		//qm.NumberClientInvoiceTxt__c = cse.InvoiceCustomerDevolutionTxt__c;
		//qm.VolumeNmb__c = cse.OrderLkp__r.VolumeNmb__c;
		//qm.GrossWeightNmb__c = cse.OrderLkp__r.WeightNmb__c;
		//qm.AditionalDataTxt__c = cse.OrderLkp__r.DataCollectionAdditionalTxt__c;
		//qm.GrossWeightNmb__c = cse.OrderLkp__r.WeightNmb__c;
		return qm;
	}
    
}