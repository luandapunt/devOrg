public with sharing class QMMeasureBO {
    public void setQMSapNumber(Set<Id> qmMeasureIdSet) {
    	List<QMMeasure__c> listMeasure = [Select QMSalesforceMdt__c, QMSAPTxt__c From QMMeasure__c where Id in :qmMeasureIdSet];
    	
    	Set<Id> qmIdSet = new Set<Id>();
    	for(QMMeasure__c auxQmM : listMeasure) {
    		qmIdSet.add(auxQmM.QMSalesforceMdt__c);
    	}
    	
    	List<QM__c> qmList = QMDAO.getById(qmIdSet);
    	
    	for(QM__c auxQM : qmList) {
    		for(QMMeasure__c auxQmM : listMeasure) {
    			if(auxQmM.QMSalesforceMdt__c == auxQm.Id) {
    				auxQM.QMSAPTxt__c =	auxQmM.QMSAPTxt__c;
    				auxQM.ErrorTxt__c = '';
    			}
    		}
    	}
    	update qmList;
    }

    public void concludeQM(Set<Id> qmMeasureIdSet) {
        List<QMMeasure__c> qmMeasureCandidateList = QMMeasureDAO.getById(qmMeasureIdSet);
        Set<Id> qmIdCandidateSet = new Set<Id>();
        String status;

        for(QMMeasure__c qmMeasureCandidate : qmMeasureCandidateList) {

            if(qmMeasureCandidate.StatusTxt__c != null) {

                status = qmMeasureCandidate.StatusTxt__c.toLowerCase();

                if((status == 'concluido') || (status == 'concluído')) {

                    qmIdCandidateSet.add(qmMeasureCandidate.QMSalesforceMdt__c);
                }
            }
        }

        // Creating a map to store the candidates to be concluded and its status.
        Map<Id, boolean> qmStatusMap = new Map<Id, boolean>();

        for(Id qmIdCandidate : qmIdCandidateSet) { 

            qmStatusMap.put(qmIdCandidate, true); 
        }

        List<QMMeasure__c> qmMeasureList = QMMeasureDAO.getByQmId(qmIdCandidateSet);

        // Deciding which candidates will be concluded.
        for(QMMeasure__c qmMeasure : qmMeasureList) {

            if(qmMeasure.StatusTxt__c != null) {

                status = qmMeasure.StatusTxt__c.toLowerCase();

                if((status != 'concluido') && (status != 'concluído')) {
                    qmStatusMap.put(qmMeasure.QMSalesforceMdt__c, false);
                }
            } 
            else {

                qmStatusMap.put(qmMeasure.QMSalesforceMdt__c, false);
            }
        }

        Set<Id> qmIdSet = new Set<Id>();

        // Creating list of selected candidates.
        for (Id id : qmStatusMap.keySet()) {

            if(qmStatusMap.get(id)) { qmIdSet.add(id); }
        }

        List<QM__c> qmList = QMDAO.getById(qmIdSet);

        // Concluding selected candidates.
        for(QM__c qm : qmList) {

            if(qm.StatusTxt__c != 'Concluído') {

                System.debug('*** Updating: ' + qm.id);
                qm.StatusTxt__c = 'Concluído';   
            }
        }

        update qmList;
    }
}