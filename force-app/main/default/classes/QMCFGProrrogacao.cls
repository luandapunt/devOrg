public with sharing class QMCFGProrrogacao extends QMCfgDefault {

	public override String getRecordTypeDevName() {
		return 'QMProrrocacao';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		//qm.ShipmentDateDte__c = cse.InvoiceLkp__r.RemittanceLkp__r.ShipmentTransitDte__c;
		//qm.DeliveryDateDte__c = cse.InvoiceLkp__r.RemittanceLkp__r.ShipmentDeliveredDte__c;
		//qm.DaysDueNmb__c = cse.InvoiceLkp__r.DaysDueNmb__c; 
		return qm;
	}
    
}