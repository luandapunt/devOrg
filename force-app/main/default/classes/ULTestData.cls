public class ULTestData
{
	public static Account createAccount(Id recordtypeId, String name, String cnpj)
	{
		Account account = new Account(
			RecordTypeId = recordTypeId,
			Name = name,
			CNPJTxt__c = cnpj);
    	return account;
	}
	
	public static Account createAccountPF(Id recordtypeId, String lastName, String cpf)
	{
		Account account = new Account(
			RecordTypeId = recordTypeId,
			LastName = lastName,
			CPFTxt__c = cpf);
    	return account;
	}
	
	public static Contact createContact(Id recordtypeId, Id accountId, String firstName, String lastName)
	{
		Contact contact = new Contact(
			RecordTypeId = recordtypeId,
			AccountId = accountId, 
			FirstName = firstName,
			LastName = lastName); 
    	return contact;
	}
	
	public static Carrier__c createCarrier(String name, String email)
	{
		Carrier__c carrier = new Carrier__c(
			Name = name,
			EmailTxt__c = email);
    	return carrier;
	}
    
    public static Invoice__c createInvoice(Id carrierId, String name)
    {
    	Invoice__c invoice = new Invoice__c(
    		CarrierLkp__c = carrierId,
    		Name = name);
    	return invoice;
    }
    
    public static InvoiceItem__c createInvoiceItem(Id invoiceId, Id productId, String customID, Integer quantity)
    {
    	InvoiceItem__c invoiceItem = new InvoiceItem__c(
    		InvoiceMdt__c = invoiceId,
    		ProductLkp__c = productId,
    		CustomIDTxt__c = customID,
    		QuantityNmb__c = quantity);
    	return invoiceItem;
    }
    
    public static Case createCase(Id recordTypeId, Id accountId, Id contactId, Id invoiceId, String clouseReason, String status, String aType, 
    	String origin, String contactType, String sellerEmail, String carrierEmail)
    {
    	Case acase = new Case(
    		RecordTypeId = recordTypeId,
    		AccountId = accountId,
    		ContactId = contactId,
    		InvoiceLkp__c = invoiceid,
    		ClouseReasonTxt__c = clouseReason,
    		Status = status,
    		Type = aType,
    		Origin = origin,
    		ContactTypeTxt__c = contactType,
    		SellerEmailEml__c = sellerEmail,
    		CarrierEmailEml__c = carrierEmail,
    		NotSendemailBln__c = false);
    	return acase;
    }
    
    public static Case createCase(Id recordTypeId, Id accountId, Id contactId, Id invoiceId, String clouseReason, String status, String aType, 
    	String origin, String contactType, String sellerEmail, String carrierEmail, String email1, String email2)
    {
    	Case acase = new Case(
    		RecordTypeId = recordTypeId,
    		AccountId = accountId,
    		ContactId = contactId,
    		InvoiceLkp__c = invoiceid,
    		ClouseReasonTxt__c = clouseReason,
    		Status = status,
    		Type = aType,
    		Origin = origin,
    		ContactTypeTxt__c = contactType,
    		SellerEmailEml__c = sellerEmail,
    		CarrierEmailEml__c = carrierEmail,
    		AlternativeEmail1Eml__c = email1,
    		AlternativeEmail2Eml__c = email2,
    		NotSendemailBln__c = false);
    		
    	return acase;
    }

    public static CaseItem__c createCaseItem(Id caseId, String customID, String failureType, String comments, String qualityProblem)
    {
    	CaseItem__c caseItem = new CaseItem__c(
    		CaseMdt__c = caseId,
    		CustomIDTxt__c = customID,
    		FailureTypeTxt__c = failureType,
    		CommentsTxt__c = comments,
    		QualityProblemTxt__c = qualityProblem);
    	return caseItem;
    }
    
    public static Entitlement createEntitlement(Id accountId, String name)
    {
    	Entitlement entitlement = new Entitlement(
    		AccountId = accountId,
    		Name = name);
    	return entitlement;
    }
    
    public static CaseMotive__c createCaseMotive(String name, String profileName, String caseType, String nature, String caseCategory, String contact)
    {
    	CaseMotive__c caseMotive = new CaseMotive__c(
    		Name = name,
    		Profile__c = profileName,
    		CaseTypeTxt__c = caseType,
    		NatureTxt__c = nature,
    		Category__c = caseCategory,
    		ContactTxt__c = contact);
    	return caseMotive;
    }
    
    public static ApexRedirectMap__c createApexRedirectMap(String name, String urlSufix)
    {
    	ApexRedirectMap__c apexRedirectMap = new ApexRedirectMap__c(
    		Name = name,
    		UrlSufix__c = urlSufix);
    	return apexRedirectMap;
    }
    
    public static Product2 createProduct(String name, String productCode)
    {
    	Product2 product = new Product2(
    		Name = name,
    		ProductCodeTxt__c = productCode,
    		IsActive = true);
    	return product;
    }
    
    public static Seller__c createSeller(String name, String sellerNumber)
    {
    	Seller__c seller = new Seller__c(
    		Name = name,
    		SellerNumberNmb__c = sellerNumber);
    	return seller;
    }
    
    public static AccountAreaSales__c createAccountAreaSales(Id accountId, Id sellerId, String customID)
    {
    	AccountAreaSales__c accountAreaSales = new AccountAreaSales__c(
    		AccountLkp__c = accountId,
    		SellerLkp__c = sellerId,
    		CustomIDTxt__c = customID);
    	return accountAreaSales;
    }
    
    public static Attachment createAttachment(Id objectId)
    {
        Attachment att = new Attachment(
        	parentId = objectId,
        	Name = 'Test Attachment',
            body = Blob.valueOf('Test Attachment Body'));
        return att;
    }
    
    public static CaseInvoice__c createCaseInvoice(Id caseId, Id invoiceId)
    {
    	CaseInvoice__c caseInvoice = new CaseInvoice__c(
    		CaseMdt__c = caseId,
    		InvoiceLkp__c = invoiceId);
    	return caseInvoice;
    }
    
    public static Order__c createOrder(Id accountId, Id accountAreaSalesId, String customID)
    {
    	Order__c anOrder = new Order__c(
    		AccountLkp__c = accountId,
    		AccountAreaSalesLkp__c = accountAreaSalesId,
    		CustomIDTxt__c = customID
    		);
    	return anOrder;
    }
    
    public static OrderItem__c createOrderItem(Id orderId, Id carrierId, String customID)
    {
    	OrderItem__c orderItem = new OrderItem__c(
    		OrderMdt__c = orderId,
    		CarrierLkp__c = carrierId,
    		CustomIDTxt__c = customID);
    	return orderItem;
    }
    
    public static EmailMessage createEmailMessage(Id parentId, String status)
    {
    	EmailMessage emailMessage = new EmailMessage(
    		ParentId = parentId,
    		Status = status
    		);
    	return emailMessage;
    }
    
    public static QM__c createQM(Id recordTypeId, Id caseId)
    {
    	QM__c qm = new QM__c(
    		RecordTypeId = recordTypeId,
    		CaseLkp__c = caseId);
    	return qm;
    }
    
    public static QMMeasure__c createQMMeasure(Id qmId, Id caseId, String externalId)
    {
    	QMMeasure__c qmMeasure = new QMMeasure__c(
    		QMSalesforceMdt__c = qmId,
    		CaseLkp__c = caseId,
    		CustomIDTxt__c = externalId
    	);
    	return qmMeasure;
    }
    
    public static Remittance__c createRemittance(String name, Id orderId, String customID, Date shipmentTransitDate, Date shipmentDeliveredDate)
    {
    	Remittance__c remittance = new Remittance__c(
    		Name = name,
    		OrderLkp__c = orderId,
    		CustomIDTxt__c = customID,
    		ShipmentTransitDte__c = shipmentTransitDate,
    		ShipmentDeliveredDte__c = shipmentDeliveredDate);
    	return remittance;
    }
    
    public static RemittanceItem__c createRemittanceItem(Id remittanceId, Id productId, Id orderItemId, String customID)
    {
    	RemittanceItem__c remittanceItem = new RemittanceItem__c(
    		RemittanceMdt__c = remittanceId,
    		ProductLkp__c = productId,
    		OrderItemLkp__c = orderItemId,
    		CustomIDTxt__c = customID
    		);
    	return remittanceItem;
    }
    
    public static IntegrationMap__c createIntegrationMap(String name, String sObjectApiName, String commandClassName, String integrationId, String dmlOperation, String customOperationClassName,
    	String outputDataType)
    {
    	IntegrationMap__c integrationMap = new IntegrationMap__c(
    		Name = name,
    		SObjectApiNameTxt__c = sObjectApiName,
    		CommandClassName__c = commandClassName,
    		IntegrationId__c = integrationId,
    		DMLOperationTxt__c = dmlOperation,
    		CustomOperationClassName__c = customOperationClassName,
    		OutputDataTypeTxt__c = outputDataType);
    	return integrationMap;
    }
    
    public static IntegrationMapItem__c createIntegrationMapItem(Id integrationMapId, String internalFieldName, String externalFieldName, String aType)
    {
    	IntegrationMapItem__c integrationMapItem = new IntegrationMapItem__c(
    		IntegrationMap__c = integrationMapId,
    		InternalFieldNameTxt__c = internalFieldName,
    		ExternalFieldNameTxt__c = externalFieldName,
    		TypeTxt__c = aType,
    		IsRequired__c = true,
    		IsActive__c = true);
    	return integrationMapItem;
    }
    
    public static Queue__c createQueue(Id integrationMapId, String eventName, String internalId)
    {
    	Queue__c queue = new Queue__c(
    		IntegrationMapLkp__c = integrationMapId,
    		EventName__c = eventName,
    		InternalId__c = internalId);
    	return queue;
    }
    
    public static Address__c createAddress(Id accountId, String customIDTxt, String neighborhood, String cepTxt, String city, String state)
    {
    	Address__c address = new Address__c(
    		AccountLkp__c = accountId,
    		CustomIDTxt__c = customIDTxt,
    		NeighborhoodTxt__c = neighborhood,
    		CEPTxt__c = cepTxt,
    		CityTxt__c = city,
    		StateTxt__c	= state);
    	return address;	
    }
    
      
    /*
    public static EmailTemplate createEmailTemplate(String name, String devName)
    {
    	EmailTemplate template = new EmailTemplate(
    		Name = name,
    		DeveloperName = devName,
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            TemplateType = 'text',
            Subject = 'Subject',
		    Body = 'Body');
        return template;
    }
    */
}