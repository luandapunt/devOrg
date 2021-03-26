public with sharing class QMRequestJSONCreater {
    public static String prepareQM(Set<Id> qmIdSet) {
    	List<QM__c> qmList = new List<QM__c>();
		qmList = QMDAO.getById(qmIdSet);
		
		List<QMRequestJSON> listQmJson = new List<QMRequestJSON>();
		
		for(QM__c auxList : qmList) {
			QMRequestJSON aux = new QMRequestJSON(auxList);
			listQmJson.add(aux);
		}
		String jsonData = JSON.serialize(listQmJson);
		
		jsonData = jsonData.replace('{', '{"request": {').replace('}', '}}').replace('[', '').replace(']','');
		
		System.debug('>>>>>>>> JSON DATA - ' + jsonData);
		
		return jsonData;
    }
}