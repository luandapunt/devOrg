public with sharing class QMCfgDevolucaoParcial extends QMCfgDefault {

	public override String getRecordTypeDevName() {
		return 'QMDevolucaoParcial';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		//qm.AditionalDataTxt__c = cse.DataCollectionAdditionalTxt__c;
		//qm.NumberClientInvoiceTxt__c = cse.InvoiceCustomerDevolutionTxt__c;
		//qm.VolumeNmb__c = cse.OrderLkp__r.VolumeNmb__c;
		//qm.GrossWeightNmb__c = cse.OrderLkp__r.WeightNmb__c;
		//qm.ClientInvoiceBln__c = true;
		//qm.DevolutionTxt__c = 'Parcial';
		return qm;
	}
    
}