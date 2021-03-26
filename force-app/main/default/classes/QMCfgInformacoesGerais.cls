public with sharing class QMCfgInformacoesGerais extends QMCfgDefault {

	public override String getRecordTypeDevName() {
		return 'QMInformacoesGerais';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		return qm;
	}
    
}