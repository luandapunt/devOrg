public without sharing class EmailManager
{
	public static void sendEmails(List<EmailQueue.EmailVO> emailVOList)
	{
		// Enviando emails assíncronamente.
        System.enqueueJob(new EmailQueue(emailVOList));
	}

    public static void sendEmailTemplate(Id templateId, Id caseId, Id senderId, List<String> emails, List<Attachment> attachments, Id ownerId) 
    {
        OrgWideEmailAddress emailOrg = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName like 'Mexichem' LIMIT 1];
        List <String> toAddresses;
        List <String> ccAddresses = new List <String> ();

        Messaging.reserveSingleEmailCapacity(2);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        if (!emails.isEmpty()) 
        {
            List <String> emailsValidos = new List < String > ();

            for (String email: emails) 
            {
                if (isValidEmail(email)) 
                {
                    emailsValidos.add(email);
                }
            }

            toAddresses = emailsValidos;
        }

        String[] bccAddresses = new String[] {};

        mail.setToAddresses(toAddresses == null ? null : toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setBccAddresses(bccAddresses);

        mail.setTargetObjectId(senderId != null ? senderId : ownerId);

        mail.setOrgWideEmailAddressId(emailOrg.Id);
        mail.setReplyTo(emailOrg.Address);

        mail.setBccSender(false);
        mail.setUseSignature(false);

        mail.setTemplateId(templateId);
        mail.setWhatId(caseId);
        mail.setSaveAsActivity(true);

        List <Messaging.EmailFileAttachment> emailFileList = new List<Messaging.EmailFileAttachment>();

        if (attachments != null) 
        {
            for (Attachment attach: attachments) 
            {
                emailFileList.add(createEmailAttachment(attach));
            }

            mail.setFileAttachments(emailFileList);
        }

        //mail

        //Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail }, true);


    }

    public static Messaging.EmailFileAttachment createEmailAttachment(Attachment file) 
    {
        Messaging.EmailFileAttachment emailFile = new Messaging.EmailFileAttachment();
        emailFile.setFileName(file.Name);
        emailFile.setContentType(file.ContentType);
        emailFile.setBody(file.Body);

        return emailFile;
    }

    public static Boolean isValidEmail(String emailAddress) 
    {
        Boolean valid = (emailAddress != null && emailAddress.contains('@'));

        if (!valid) 
        {
            System.debug('Email ' + emailAddress + ' is not valid.');
        }

        return valid;
    }
}