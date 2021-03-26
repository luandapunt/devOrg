public with sharing class QMCreateQMRemoteCall implements integ_IRemoteCall{
	
	public Id qmId {get;set;}
	
	public QMCreateQMRemoteCall(Id qmId) {
		this.qmId = qmId;
	}
	
    
    public Object execute() {
    	return sendToSAP(this.qmId);   	
    }
    
    public String sendToSAP(Id qmId) {
    	HttpRequest req = new HttpRequest();

		//req.setEndpoint('http://brsml174:50000/RESTAdapter/SFDC/QM/Homologation');
		req.setEndpoint(ApexRedirectMap__c.getValues('WebServiceQM').UrlSufix__c);

		req.setMethod('POST');

		Set<Id> qmIdSet = new Set<Id>();
		qmIdSet.add(qmId);

		req.setBody(QMRequestJSONCreater.prepareQM(qmIdSet)); 

		// Specify the required user name and password to access the endpoint
		// As well as the header and header information

		//String username = 'USER_SFDC_HOMOLOG';
		//String password = 'homolog_2016*';
        String username = ApexRedirectMap__c.getInstance('WebServiceUser').UrlSufix__c;
        String password = ApexRedirectMap__c.getInstance('WebServicePassword').UrlSufix__c;
		Blob headerValue = Blob.valueOf(username + ':' + password);
		String authorizationHeader = 'Basic ' +
		EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);

		req.setTimeout(120000);

		// Create a new http object to send the request object
		// A response object is generated as a result of the request 

		Http http = new Http();

		HTTPResponse res = http.send(req);

		System.debug('>>>>> SAP RETURN TO QM SENT: ' + res.getBody());
		
		return res.getBody();
    }
}