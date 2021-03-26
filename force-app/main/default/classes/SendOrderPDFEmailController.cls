public with sharing class SendOrderPDFEmailController{
    
    public String subject { get; set; }
    public String body { get; set; }
    public String emailid{get; set;}
    public String mailBody{get; set;}
    public String salesOrg{get; set;}
    private final Order__c Order;
    
    public string fileExtension {get;set;}
    
    
    public SendOrderPDFEmailController(ApexPages.StandardController controller) {
        Order= [SELECT Name, CustomIdTxt__c, id, AccountAreaSalesLkp__r.SalesOrganizationTxt__c, AccountLkp__c, AccountLkp__r.Name,
                SellerLkp__r.Name, SellerLkp__r.UserLkp__r.Email, SellerLkp__r.SellerPhoneTxt__c, AccountLkp__r.EmailNFTxt__c
              	FROM Order__c
              	WHERE Id=:ApexPages.currentPage().getParameters().get('id')];
        
        emailid = Order.AccountLkp__r.EmailNFTxt__c;
    }
    
    public Order__c getOrder() {
        return Order;
    }
    
    public list<SelectOption> getFileExtensions (){
        List<SelectOption> fileExtensions = new List<SelectOption>();       
        
        fileExtensions.add(new SelectOption('PDF', 'PDF'));
		fileExtensions.add(new SelectOption('CSV', 'CSV'));
		fileExtensions.add(new SelectOption('XLS', 'XLS'));
       
        return fileExtensions;
    }
    
    public void send() {       
        
        try{
            if(Order.AccountAreaSalesLkp__r.SalesOrganizationTxt__c !=null){
            	salesOrg = Order.AccountAreaSalesLkp__r.SalesOrganizationTxt__c;
            } else {
                salesOrg = 'Mexichem';
            }
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            Blob b;
            
            if(fileExtension=='PDF'){
                PageReference pdf =  Page.OrderPDFView;                
                pdf.getParameters().put('id',(String)Order.id);
                pdf.setRedirect(true);
                
                if(Test.isRunningTest()){
                    b = Blob.valueOf('UnitTest');
                }
                else{
                    b = pdf.getContentAsPdf();
                }                                                
                                
                efa.setContentType('application/pdf');
                efa.setFileName(salesOrg + ' - Ordem ' + Order.CustomIdTxt__c + '.pdf');
                efa.setBody(b);
            }
            
            if(fileExtension=='CSV'){
                PageReference csv = page.OrderCSVExport;
                csv.getParameters().put('id',(String)Order.id);
                csv.setRedirect(true);
                
                if(Test.isRunningTest()){
                    b = Blob.valueOf('UnitTest');
                }
                else{
                    b = csv.getContent();
                }
                
                efa.setContentType('text/csv');
                efa.setFileName(salesOrg + ' - Ordem ' + Order.CustomIdTxt__c + '.csv');
                efa.setBody(b);
                
            }
            
            if(fileExtension=='XLS'){
                PageReference xls =  Page.OrderXLSExport;                
                xls.getParameters().put('id',(String)Order.id);
                xls.setRedirect(true);
                
                if(Test.isRunningTest()){
                    b = Blob.valueOf('UnitTest');
                }
                else{
                    b = xls.getContent();
                }                                                
                                
                efa.setContentType('application/vnd.ms-excel');
                efa.setFileName(salesOrg + ' - Ordem ' + Order.CustomIdTxt__c + '.xls');
                efa.setBody(b);
            }
            
            Contact sendFileToCon = new Contact(); 
            Contact sendFileToNewCon = new Contact(FirstName = 'Destinatário Ordem:', LastName = emailid, Email = emailid, AccountId = Order.AccountLkp__c);
            List<Contact> sendFileToExistingCon = [SELECT Id, Name, Email FROM Contact WHERE Email =: emailid AND AccountId =: Order.AccountLkp__c LIMIT 1];                                 
            if(sendFileToExistingCon.size() > 0){
                sendFileToCon.id 	= sendFileToExistingCon[0].Id;                
            } else {
                sendFileToCon = sendFileToNewCon;
                insert sendFileToCon;
            }
            
            //String addresses;
            //addresses=emailid;
            //String[] toAddresses = addresses.split(';', 0);
            
            string subject = salesOrg + ' - Ordem ' + Order.CustomIdTxt__c;
            string sellerPhone = '';
            if(Order.SellerLkp__r.SellerPhoneTxt__c != null){
                sellerPhone = Order.SellerLkp__r.SellerPhoneTxt__c;
            }            
            
            email.setSubject( subject );
            //email.setToAddresses( toAddresses );            
            email.setHtmlBody(                
                'Prezado <b>'+ Order.AccountLkp__r.Name + ',</b> <br/>' +
                '<br/>' +
                'Segue anexo a cotação solicitada.<br/>' +
                'Estamos à disposição para esclarecer eventuais dúvidas.<br/>' +
                '<br/>' +
                'Ciente de sua atenção, desde já agradeço.<br/>' +
                '<br/>' +
                '<b>'+ Order.SellerLkp__r.Name + '</b><br/>' +
                Order.SellerLkp__r.UserLkp__r.Email + '<br/>' +
                sellerPhone);
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            email.setTargetObjectId(sendFileToCon.Id);
            email.setWhatId(Order.Id);
            email.setSaveAsActivity(true);
            
            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'O email foi enviado com sucesso!'));
            
            string taskSubject = 'Email: ' + salesOrg + ' - Ordem ' + Order.CustomIdTxt__c;
            List<Task> emailTasks = [SELECT Id FROM Task WHERE Subject =: taskSubject AND WhatId =: Order.Id ORDER BY CreatedDate DESC LIMIT 1];
            Task emailTask = !emailTasks.isEmpty() ? emailTasks[0] : null;
            Attachment attchmnt = new Attachment();
            attchmnt.body = b;
            attchmnt.name = salesOrg + ' - Ordem ' + Order.CustomIdTxt__c + '.pdf';
            attchmnt.parentId = emailTask.id;
            insert attchmnt;
                        
        } catch (exception ex){
            ApexPages.addMessages(ex);
        }
        
    }
}