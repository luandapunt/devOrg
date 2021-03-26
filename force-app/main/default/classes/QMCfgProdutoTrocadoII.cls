public with sharing class QMCfgProdutoTrocadoII extends QMCfgDefault {

	public override String getRecordTypeDevName() {
		return 'QMProdutoTrocadoII';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		return qm;
	}
    
}