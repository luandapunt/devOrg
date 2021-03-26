public with sharing class SendMail {
    /*
	public static void sendLogInterfaceMail(LogInterface__c logInterface) {
		
        List<String> 	   cc 	 		= new List<String>();
        List<String> 	   to 	 		= new List<String>();
		String 			   logMessage;

        // Retrieve all custom setting e-mails
        Map<String, SendToLogInformation__c> css = SendToLogInformation__c.getAll();

        Integer counter = 0;
        for (String cs : css.keySet()) {
            if (counter == 0) 
                to.add(css.get(cs).Email__c);
            else
                cc.add(css.get(cs).Email__c);
            
            counter++;
        }

        Map<String, Schema.SObjectField> fields = LogInterface__c.sObjectType.getDescribe().fields.getMap();
        
        logInterface = LogInterfaceBO.getInstance().getRecord(logInterface.id);
        
		logMessage = 	fields.get('Interface__c').getDescribe().getLabel()			+ ': ' + logInterface.Interface__c 			+ '\n' +
						fields.get('Status__c').getDescribe().getLabel() 			+ ': ' + logInterface.Status__c				+ '\n' +
				 	 	fields.get('Date__c').getDescribe().getLabel()				+ ': ' + logInterface.Date__c				+ '\n' +
				 	 	fields.get('FailQuantity__c').getDescribe().getLabel() 		+ ': ' + logInterface.FailQuantity__c		+ '\n' +
				 	 	fields.get('SuccessQuantity__c').getDescribe().getLabel()  	+ ': ' + logInterface.SuccessQuantity__c 	+ '\n' +
            			fields.get('TotalQuantity__c').getDescribe().getLabel()  	+ ': ' + logInterface.TotalQuantity__c 		+ '\n' +
				 	 	'Link'									  	+ ': ' + URL.getSalesforceBaseUrl().toExternalForm() + '/'  + logInterface.Id;
        
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setSaveAsActivity(false);
        message.setSubject('Informações de Log');
        message.setUseSignature(false);
        message.setPlainTextBody(logMessage);
        message.setToAddresses(to);
        message.setSenderDisplayName(UserInfo.getName());
        if (!cc.isEmpty())
            message.setCcAddresses(cc);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
       
	}
    */
}