public with sharing class QMCfgTranstornoNaEntrega extends QMCfgDefault {
    public override String getRecordTypeDevName() {
		return 'QMTranstornoNaEntrega';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		return qm;
	}
}