@RestResource(urlMapping='/CreditNote/*')
global with sharing class RESTCreditNoteController {
    
    @HttpPost
    global static ResponseWrapper echoMyType(WSInBoundOrquestrationVO requestVO) {
        System.debug(requestVO.content.unescapeEcmaScript());
        String jsonString = requestVO.content.unescapeEcmaScript();
        List<MyUserDefinedClass> creditList = (List<MyUserDefinedClass>)JSON.deserializeStrict(jsonString, List<MyUserDefinedClass>.class);
        System.debug(creditList);
       
    //global static ResponseWrapper echoMyType(List<MyUserDefinedClass> CRED_VALUES) {
        //System.debug(CRED_VALUES);
        //System.debug(JSON.serialize(CRED_VALUES));
        ResponseWrapper resWrap = new ResponseWrapper();
        
        try{
            Map<String, MyUserDefinedClass> creditValueMap = new Map<String, MyUserDefinedClass>();
            List<String> clientKeyList = new List<String>();
            
            for(MyUserDefinedClass creditValue : creditList){
                String accountCode;
                if(creditValue.KUNNR != null && creditValue.VKORG != null){
                    accountCode = StringUtils.removeLeftPadZeros(creditValue.KUNNR); 
                    String clientKey = accountCode + creditValue.VKORG;
                    
                    creditValueMap.put(clientKey, creditValue);
                    clientKeyList.add(clientKey+'%');
                }else{
                    resWrap.E_ERRORMSG.add('KUNNR e VKORG não podem ser nulos.');
                    resWrap.E_ERROR = 'X';
                }
            }
            
            List<AccountAreaSales__c> clientList = [SELECT Id, Name, CustomIDTxt__c, SAPCodeFml__c, CodeSalesOrganizationTxt__c, AccountLkp__r.Name FROM AccountAreaSales__c WHERE CustomIDTxt__c LIKE :clientKeyList AND AccountLkp__r.Name != null];
            System.debug(clientList);
            
            Integer processedRecords = 0;
            
            for(AccountAreaSales__c client : clientList){
                String clientKey = client.SAPCodeFml__c + client.CodeSalesOrganizationTxt__c;
                if(creditValueMap.containsKey(clientKey)){
                    System.debug(clientKey+': '+creditValueMap.get(clientKey).CREDGENERAL+': '+creditValueMap.get(clientKey).CREDPRICE+': '+creditValueMap.get(clientKey).CREDRETURN+': '+creditValueMap.get(clientKey).CREDTRADE);
                    client.GeneralCreditNmb__c = creditValueMap.get(clientKey).CREDGENERAL;
                    client.PriceCreditNmb__c = creditValueMap.get(clientKey).CREDPRICE;
                    client.ReturnCreditNmb__c = creditValueMap.get(clientKey).CREDRETURN;
                    client.TradeCreditNmb__c = creditValueMap.get(clientKey).CREDTRADE;
                    processedRecords++;
                }
            }
            resWrap.RECORD_QTY = processedRecords;
            System.debug(clientList);
            update clientList;
        }catch(Exception e){
            resWrap.E_ERRORMSG.add(e.getMessage());
            resWrap.E_ERROR = 'X';            
        }        
        
        return resWrap;
    }

    global class MyUserDefinedClass {
        private String KUNNR;
        private String VKORG;
        private Double CREDRETURN { get; set; }
        private Double CREDPRICE { get; set; }
        private Double CREDTRADE { get; set; }
        private Double CREDGENERAL { get; set; }
        private String REFDATE { get; set; }
    }
    
    global class WSInBoundOrquestrationVO {
        //integration id
        global String integrationId;      
        //data 
        global String content;
        //determine transaction context
        global Boolean isSync;
        //
        global Id queueItem;
        //is true if sucess
        global Boolean success;
        //possible messages
        global String message;
        //return job id if is assync
        global String jobId;
        //global String log;
        global String access_token;
        global String instance_url;
        global String token_type;    
    }
    
    global class ResponseWrapper{
        public String E_ERROR;
        public List<String> E_ERRORMSG;
        public Integer RECORD_QTY;
        public ResponseWrapper(){
            E_ERRORMSG = new List<String>();
            E_ERROR = '';
            RECORD_QTY = 0;
        }
        
    }
}