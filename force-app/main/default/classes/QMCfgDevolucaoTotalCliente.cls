public with sharing class QMCfgDevolucaoTotalCliente extends QMCfgDefault {
    public override String getRecordTypeDevName() {
		return 'QMDevolucaoTotalCliente';
	}
	
	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		return qm;
	}
}