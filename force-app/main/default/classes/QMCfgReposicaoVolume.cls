public virtual class QMCfgReposicaoVolume extends QMCfgDefault {

	public override String getRecordTypeDevName() {
		return 'QMReposicaoVolume';
	}
	
	 public override QM__c configure(QM__c qm, Case cse) {
	 	qm = super.configure(qm, cse);
		return qm;
	}
    
}