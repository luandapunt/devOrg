public without sharing class QM {
	
	public class QMException extends Exception {}
	
	private QMMapping mapping;
	private List<QM__c> qmList;
	
	public QM(List<QM__c> qmList) {
		this.mapping = new QMMapping();
		this.qmList = qmList;
	}	
	
	/*
		Loads aditional information by record type
	*/
	public QM enrich(){
		
		Set<Id> caseIdSet = new Set<Id>();
		for (QM__c qm : this.qmList) {
			caseIdSet.add(qm.CaseLkp__c);
		}
		
		List<Case> caseList = new List<Case>();
		caseList = CaseDAO.getById(caseIdSet);
		Map<Id, Case> caseMap = new Map<Id, Case>(caseList);
		
		for (QM__c qm : qmList) {
			//get configuration according to qm's recordtype
			IQMConfigurator cfg = mapping.findByRecordTypeId(qm.RecordTypeId);
			System.debug(LoggingLevel.FINEST, '*** IQMConfigurator: ' + cfg);
			if (cfg == null) {
				throw new QMException('QM configurator not found for [' + qm.RecordTypeId + '] recordtypeId.');
			}
			
			//get related case to QM
			Case relatedCase = caseMap.get(qm.CaseLkp__c);
			//do configuration
			cfg.configure(qm, relatedCase);
		}
		
		return this;
	}
	
	public QM save() {
		upsert this.qmList;
		return this;
	}
	
	public static void setExternalIdQM(Set<Id> qmIdSet) {
		List<QM__c> auxList = QMDAO.getById(qmIdSet);
		for(QM__c aux : auxList) {
			aux.SalesforceQMTxt__c = aux.CaseLkp__r.CaseNumber + aux.Name;
		}
		update auxList;
	}
	
	public static void checkSentStatus(List<QM__C> qmList) {
		for(QM__c aux : qmList) {
			if(aux.ErrorTxt__c != null && !aux.ErrorTxt__c.equals('')) {
				aux.StatusTxt__c = 'QM com erro';
			} else if(aux.QMSAPTxt__c != null && !aux.QMSAPTxt__c.equals('') && aux.StatusTxt__c != 'Concluído'){
				aux.StatusTxt__c = 'QM criada SAP';
			}
		}
	}
	public static void setStatusInCase(List<QM__C> qmList){
		
		Set<Id> caseIdSet = new Set<Id>();
		for (QM__c qm : qmList) {
			caseIdSet.add(qm.CaseLkp__c);
		}
		
		Map<String, Id> recordMap = new Map<String, Id>();
		List<RecordType> recordType = [SELECT Id, Name FROM RecordType  where SobjectType = 'Case'];
    	for(RecordType rec : recordType) {
    		recordMap.put(rec.Name, rec.Id);
    	}
		
		List<Case> caseList = new List<Case>();
		caseList = CaseDAO.getById(caseIdSet);
		Map<Id, Case> caseMap = new Map<Id, Case>(caseList);
		
		for (QM__c qm : qmList) {
			
			Case relatedCase = caseMap.get(qm.CaseLkp__c);
			
			if (relatedCase.RecordTypeId != recordMap.get('Reclamação') && relatedCase.Status != 'Encerrado' && relatedCase.Status != 'Cancelado' && relatedCase.Status != 'Aguardando encerramento'){
					
				relatedCase.Status = 'QM em andamento';
				
				update relatedCase;
			}
		}
	}
}