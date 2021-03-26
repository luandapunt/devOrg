global with sharing class QMBO {
    webservice static void updateSentStatus(Id qmId) {
    	QM__c qm = new QM__c(Id = qmId);
    	qm.StatusTxt__c = 'QM enviada SAP';
    	update qm;
    }
}