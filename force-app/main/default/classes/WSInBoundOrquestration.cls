/**
    Inbound integration orquestrator
    SOAP/REST service
*/
@RestResource(urlMapping = '/wsinboundorquestration/*')
global with sharing class WSInBoundOrquestration {
    
    /*
        Vo for request's and response's integration 
    */
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
    
    /*
        Webservice integration method
    */
    webservice static WSInBoundOrquestrationVO execute(WSInBoundOrquestrationVO requestVO) {
        System.debug(requestVO); 
        pushToQueue(requestVO);
        return requestVO; 
    }
    
    @HttpPost
    global static WSInBoundOrquestrationVO executePost(WSInBoundOrquestrationVO requestVO) {
        System.debug('*** ' + requestVO);
        pushToQueue(requestVO);
        return requestVO;
    }
    
    /*
        Push data to integration queue
    */
    private static void pushToQueue(WSInBoundOrquestrationVO requestVO) {
        
        EventBuilder builder = new EventBuilder();
        
        builder.createEventFor(requestVO.integrationId)
                              .forObjectId('1')
                              .withInternalID ('2')
                              .withSender('SAP')
                              .withReceiver('SF')
                              .withPayload('[]');

        if (requestVO.isSync) {
            builder.isSync();
        }                      

        EventQueue evt = new EventQueue(builder.build());


        evt.addPayload('Payload', requestVO.content.unescapeEcmaScript());                      
        
        //store event;
        evt.save();
        
        //dispatch event;
        evt.dispatch();     
        
        //set queue item
        requestVo.queueItem = evt.getQueue().Id;
    }
    
}