global with sharing class QMService /*extends integ_SyncIntegrationServiceAbstract*/ {

	//public QMService() {
		//super(new integ_GenerictHttpRemoteService());
	//}
		
	/*
		Executes SYNC_QM_OUTBOUND syncrony
	*/
    
    @AuraEnabled
    public static String sendSyncToSAPCmp(Id qmId) {
        system.debug('qmid>>>>>'+ qmId );
    	QMCreateQMRemoteCall remoteCall = new QMCreateQMRemoteCall(qmId);
        String result = (String)remoteCall.execute();
        
        if((''+result).indexOf('E_RESPONSE') != -1 && (''+result).indexOf('100') != -1){
            QMBO.updateSentStatus(qmId);
        }
        system.debug('resultqmservive>>>>>'+ result ); //100 - Enviado Com sucesso, mas não necessariamente Chegou ao SAP
    	return result;
    	//return (String)super.execute(IntegrationIds.SYNC_QM_OUTBOUND.name(), remoteCall);
    }
    
    @AuraEnabled
    webservice static String sendSyncToSAP(Id qmId) {
    	QMCreateQMRemoteCall remoteCall = new QMCreateQMRemoteCall(qmId);
    	return (String)remoteCall.execute();
    	//return (String)super.execute(IntegrationIds.SYNC_QM_OUTBOUND.name(), remoteCall);
    }
}