public abstract class RestBaseServiceAbstraction {
	
	private String endpoint;

	public RestBaseServiceAbstraction() {
		this.endpoint = ApexRedirectMap__c.getValues('WebServiceInvoice').UrlSufix__c;
    }

	public RestBaseServiceAbstraction(String endpoint) {
		this.endpoint = endpoint;
	}

	abstract String getBodyContent();

	public String callService(String method) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setBody(this.getBodyContent()); 

        //String username = 'USER_SFDC_HOMOLOG';
        //String password = 'homolog_2016*';
        String username = ApexRedirectMap__c.getInstance('WebServiceUser').UrlSufix__c;
        String password = ApexRedirectMap__c.getInstance('WebServicePassword').UrlSufix__c;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);

        req.setTimeout(120000);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        System.debug('*** request: ' + req);
        System.debug('*** request body: ' + req.getBody());
        System.debug('**** response body: ' + res.getBody());
        System.debug('***** response: '+ res);

        return res.getBody();

	}

}