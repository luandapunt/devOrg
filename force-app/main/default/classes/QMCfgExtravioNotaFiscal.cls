public with sharing class QMCfgExtravioNotaFiscal extends QMCfgDefault {

	public override String getRecordTypeDevName() {
		return 'QMExtravioNotaFiscal';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		return qm;
	}
    
}