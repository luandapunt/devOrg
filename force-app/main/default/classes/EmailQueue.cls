public class EmailQueue implements Queueable 
{
	public class EmailVO
	{
		public Id templateId { get; set; }
		public Id caseId { get; set; }
		public Id senderId { get; set; }
		public List<String> emails { get; set; }
		public List<Attachment> attachments { get; set; }
		public Id ownerId { get; set; }
        
	}

	private List<EmailVO> emailVOList;
	private OrgWideEmailAddress emailOrg;

	public EmailQueue(List<EmailVO> emailVOList)
	{
		this.emailVOList = emailVOList;
		this.emailOrg = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName like 'Mexichem' LIMIT 1];
	}
	
	public void execute(QueueableContext context) 
	{
		List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();

		for(EmailVO emailVO : this.emailVOList)
		{
			Messaging.SingleEmailMessage emailMessage = createSingleEmailMessage(emailVO);
			emailMessageList.add(emailMessage);
		}

		List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
		for(Messaging.SingleEmailMessage emailMessage : emailMessageList)
		{
			singleEmailMessageList.add(emailMessage);
		}
		Messaging.sendEmail(singleEmailMessageList, true);
	}

    private Messaging.SingleEmailMessage createSingleEmailMessage(EmailVO emailVO) 
    {
        List<String> toAddresses;
        List<String> ccAddresses = new List<String>();

        Messaging.reserveSingleEmailCapacity(2);

        Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();

        if (!emailVO.emails.isEmpty()) 
        {
            List <String> emailsValidos = new List < String > ();

            for (String email : emailVO.emails) 
            {
                if (isValidEmail(email)) { emailsValidos.add(email); }
            }

            toAddresses = emailsValidos;
        }

        String[] bccAddresses = new String[]{};

        singleEmailMessage.setToAddresses(toAddresses == null ? null : toAddresses);

        singleEmailMessage.setCcAddresses(ccAddresses);
        singleEmailMessage.setBccAddresses(bccAddresses);
       
        singleEmailMessage.setTargetObjectId(emailVO.senderId != null ? emailVO.senderId : emailVO.ownerId);

        singleEmailMessage.setOrgWideEmailAddressId(this.emailOrg.Id);
        singleEmailMessage.setReplyTo(this.emailOrg.Address);

        singleEmailMessage.setBccSender(false);
        singleEmailMessage.setUseSignature(false);
     

        singleEmailMessage.setTemplateId(emailVO.templateId);
        singleEmailMessage.setWhatId(emailVO.caseId);
        singleEmailMessage.setSaveAsActivity(true);

        List<Messaging.EmailFileAttachment> emailFileList = new List<Messaging.EmailFileAttachment>();

        if (emailVO.attachments != null) 
        {
            for (Attachment attach : emailVO.attachments) 
            {
                emailFileList.add(createEmailAttachment(attach));
            }

            singleEmailMessage.setFileAttachments(emailFileList);
        }

        return singleEmailMessage;
    }

    private Messaging.EmailFileAttachment createEmailAttachment(Attachment file) 
    {
        Messaging.EmailFileAttachment emailFile = new Messaging.EmailFileAttachment();
        emailFile.setFileName(file.Name);
        emailFile.setContentType(file.ContentType);
        emailFile.setBody(file.Body);

        return emailFile;
    }

    private Boolean isValidEmail(String emailAddress) 
    {
        Boolean valid = (emailAddress != null && emailAddress.contains('@'));

        if (!valid) 
        {
            System.debug('Email ' + emailAddress + ' is not valid.');
        }

        return valid;
    }
}