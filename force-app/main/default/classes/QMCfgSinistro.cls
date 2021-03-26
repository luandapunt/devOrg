public with sharing class QMCfgSinistro extends QMCfgDefault {

	public override String getRecordTypeDevName() {
		return 'QMSinistro';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		return qm;
	}
    
}