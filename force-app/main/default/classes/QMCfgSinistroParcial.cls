public with sharing class QMCfgSinistroParcial extends QMCfgDefault {
    public override String getRecordTypeDevName() {
		return 'QMSinistroParcial';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		return qm;
	}
}