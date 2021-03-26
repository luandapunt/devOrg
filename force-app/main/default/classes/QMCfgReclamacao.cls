public with sharing class QMCfgReclamacao extends QMCfgDefault {
	
	public override String getRecordTypeDevName() {
		return 'QMReclamacao';
	}

	public override QM__c configure(QM__c qm, Case cse) {
		qm = super.configure(qm, cse);
		//qm.TechnicianLkp__c = cse.TecnicianLkp__c;
		//qm.OrderNumberTxt__c = cse.OrderNumberTxt__c;
		//qm.OriginTxt__c = cse.Origin;
		//qm.AccountIssuerLkp__c = cse.AccountIssuerLkp__c;
		//qm.ProductLkp__c = cse.CaseItem__r.ProductLkp__c;
		//qm.ManufacturingCenterTxt__c = cse.CaseItem__r.ManufacturingCenterTxt__c;
		//qm.QuantityNmb__c = cse.CaseItem__r.QuantityNmb__c;
		//qm.PriorityTxt__c = cse.Priority;
		//qm.StartDateDte__c = cse.StartDateDte__c;  
		//qm.FinishDateDte__c = cse.StartFinishDte__c;
		//qm.CoordinatorTxt__c = cse.CoordinatorTxt__c;
		//qm.ProductSalesOrganizationTxt__c = cse.CaseItem__r.ProductSalesOrganizationTxt__c;
		//qm.ProductDistributionChannelTxt__c = cse.CaseItem__r.ProductDistributionChannelTxt__c; 
		//qm.ProductActivitySectorTxt__c = cse.CaseItem__r.ProductActivitySectorTxt__c; 
		//qm.ProductSalesOfficeTxt__c = cse.CaseItem__r.ProductSalesOfficeTxt__c; 
		//qm.ProductSalesTeamTxt__c = cse.CaseItem__r.ProductSalesTeamTxt__c; 
		return qm;
	}
    
}