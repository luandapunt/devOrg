public with sharing class QMCfgSustacao extends QMCfgDefault {

	public override String getRecordTypeDevName() {
		return 'QMSustacao';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		return qm;
	}
    
}