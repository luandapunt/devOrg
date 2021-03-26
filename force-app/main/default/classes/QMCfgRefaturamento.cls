public with sharing class QMCfgRefaturamento extends QMCfgDefault {

	public override String getRecordTypeDevName() {
		return 'QMRefaturamento';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		//qm.RetWithoutRemTxt__c = cse.DevolutionWithoutShippingTxt__c;
		return qm;
	}
    
}