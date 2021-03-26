@isTest
public class TestData {
    
    public static User createUser(String name, String manager, String role, String profile, String username){
        User us = new User(LastName=name, ManagerId=manager, UserRoleId=role, ProfileId=profile, Username=username);
        us.Email = 'testmail@test.com';
        us.Alias = 'Tuser';
        us.CommunityNickname = name;
        us.TimeZoneSidKey = 'America/Sao_Paulo';
        us.LocaleSidKey = 'bs';
        us.EmailEncodingKey = 'UTF-8 ';
        us.LanguageLocaleKey = 'pt_BR';
        insert us;
        return us;
    }

    public static Lead createLead(String lastName, String channel){
        Lead l = new Lead(LastName=lastName, ChannelLkp__c=channel);
        l.CNPJTxt__c = '44.149.954/0001-36';
        l.SalesOrganizationTxt__c = 'AM01';
        l.Status = 'Open';
        l.ReasonToDisqualificationTxt__c = 'Não foi desqualificado';
        l.ApprovalTxt__c = 'Aguardando envio para aprovação';
        l.ShortNameTxt__c = 'Test';
        l.MobilePhone = '11985857878';
        l.Email = 'test@test.com';
        l.Company = 'TestCompany';
        l.RemarkTxt__c = 'Observações de teste';
        l.Street = 'Avenida das Nações Unidas';
        l.City = 'São Paulo';
        l.State = 'São Paulo';
        l.StateCode = 'SP';
        l.PostalCode = '87138-980';
        l.Country = 'Brasil';
        l.CountryCode = 'BR';
        l.RG_StateInscriptionTxt__c = '5353534';
        l.MunicipalRegistrationNmb__c = 31233;
        l.Phone = '11985857878';
        l.XMLEmailTxt__c = 'testxml@test.com';
        l.EmailTxt__c = 'testcomercial@test.com';
        l.SuframaCodeTxt__c = '13123123';
        l.MonthlyRevenueSourceTxt__c = 'Outros';
        l.ProponentMonthlyRevenueNmb__c = 1000;
        l.CustomerProfileTxt__c = 'Pessoa Jurídica';
        l.BankTxt__c = 'BANESPA';
        l.SuggestedLimit__c = 1000;
        l.Rating = 'Bom';
        l.OperatingAreaTxt__c = 'Nacional';
        l.BrandTxt__c = 'TestBrand';
        l.CPFPartner1Txt__c = '77777777755';
        l.BirthdayPartner1Dte__c = Date.newInstance(1990, 11, 21);
        l.MarketedMaterialsTxt__c = '01';
        l.PotentialPurchaseNmb__c = 10000;
        l.ShipmentConditionTxt__c = '01';
        l.OperationModeTxt__c = '0001';
        l.NielsenZoneTxt__c = '01';
        l.IndustryTxt__c = '0001';
        l.SubfiscalGroupTxt__c = 'D';
        l.TaxObligatoryTxt__c = '1';
        insert l;
        return l;
    }
    
    public static Lead createLead(String lastName, String channel, String seller){
        Lead l = new Lead(LastName=lastName, ChannelLkp__c=channel, SellerLkp__c=seller);
        l.CNPJTxt__c = '44.149.954/0001-36';
        l.SalesOrganizationTxt__c = 'AM01';
        l.Status = 'Open';
        l.ReasonToDisqualificationTxt__c = 'Não foi desqualificado';
        l.ApprovalTxt__c = 'Aguardando envio para aprovação';
        l.ShortNameTxt__c = 'Test';
        l.MobilePhone = '11985857878';
        l.Email = 'test@test.com';
        l.Company = 'TestCompany';
        l.RemarkTxt__c = 'Observações de teste';
        l.Street = 'Avenida das Nações Unidas';
        l.City = 'São Paulo';
        l.State = 'São Paulo';
        l.StateCode = 'SP';
        l.PostalCode = '87138-980';
        l.Country = 'Brasil';
        l.CountryCode = 'BR';
        l.RG_StateInscriptionTxt__c = '5353534';
        l.MunicipalRegistrationNmb__c = 31233;
        l.Phone = '11985857878';
        l.XMLEmailTxt__c = 'testxml@test.com';
        l.EmailTxt__c = 'testcomercial@test.com';
        l.SuframaCodeTxt__c = '13123123';
        l.MonthlyRevenueSourceTxt__c = 'Outros';
        l.ProponentMonthlyRevenueNmb__c = 1000;
        l.CustomerProfileTxt__c = 'Pessoa Jurídica';
        l.BankTxt__c = 'BANESPA';
        l.SuggestedLimit__c = 1000;
        l.Rating = 'Bom';
        l.OperatingAreaTxt__c = 'Nacional';
        l.BrandTxt__c = 'TestBrand';
        l.CPFPartner1Txt__c = '77777777755';
        l.BirthdayPartner1Dte__c = Date.newInstance(1990, 11, 21);
        l.MarketedMaterialsTxt__c = '01';
        l.PotentialPurchaseNmb__c = 10000;
        l.ShipmentConditionTxt__c = '01';
        l.OperationModeTxt__c = '0001';
        l.NielsenZoneTxt__c = '01';
        l.IndustryTxt__c = '0001';
        l.SubfiscalGroupTxt__c = 'D';
        l.TaxObligatoryTxt__c = '1';
        insert l;
        return l;
    }
    
    public static Account createAccount(String name, String channel){
        Account acc = new Account(Name=name, ChannelLkp__c=channel);
        acc.SalesOrganizationTxt__c = 'AM01';
        acc.CNPJTxt__c = '44.149.954/0001-36';
        acc.BillingStreet = 'Rua Test';
        acc.BillingStateCode = 'SP';
        acc.BillingState = 'São Paulo';
        acc.BillingCity = 'TestCity';
        acc.BillingCountryCode = 'BR';
        acc.BillingCountry = 'Brasil';
        acc.BillingPostalCode = '04060-120';
        insert acc;
        return acc;
    }
    
    public static Account createAccount(String name, String channel, String mainSA, String recordType){
        Account acc = new Account(Name=name, ChannelLkp__c=channel, MainSalesAreaLkp__c=mainSA, RecordTypeId=recordType);
        acc.SalesOrganizationTxt__c = 'AM01';
        acc.CNPJTxt__c = '44.149.954/0001-36';
        acc.CodeCustomerTxt__c = '1234567'+name;
        acc.BillingStreet = 'Rua Test';
        acc.BillingStateCode = 'SP';
        acc.BillingState = 'São Paulo';
        acc.BillingCity = 'TestCity';
        acc.BillingCountryCode = 'BR';
        acc.BillingCountry = 'Brasil';
        acc.BillingPostalCode = '04060-120';
        acc.RG_StateInscriptionTxt__c = '510643590';
        insert acc;
        return acc;
    }

    public static Account createAccount(String name, String channel, String mainSA, String recordType, String codeCustomer){
        Account acc = new Account(Name=name, ChannelLkp__c=channel, MainSalesAreaLkp__c=mainSA, RecordTypeId=recordType, CodeCustomerTxt__c = codeCustomer);
        acc.SalesOrganizationTxt__c = 'AM01';
        acc.CNPJTxt__c = '44.149.954/0001-36';
        acc.BillingStreet = 'Rua Test';
        acc.BillingStateCode = 'SP';
        acc.BillingState = 'São Paulo';
        acc.BillingCity = 'TestCity';
        acc.BillingCountryCode = 'BR';
        acc.BillingCountry = 'Brasil';
        acc.BillingPostalCode = '04060-120';
        acc.RG_StateInscriptionTxt__c = '510643590';
        insert acc;
        return acc;
    }
    
    public static Account createAccount(String name, String channel, String mainSA){
        Account acc = new Account(Name=name, ChannelLkp__c=channel, MainSalesAreaLkp__c=mainSA);
        acc.SalesOrganizationTxt__c = 'AM01';
        acc.CNPJTxt__c = '44.149.954/0001-36';
        acc.BillingStreet = 'Rua Test';
        acc.BillingStateCode = 'SP';
        acc.BillingState = 'São Paulo';
        acc.BillingCity = 'TestCity';
        acc.BillingCountryCode = 'BR';
        acc.BillingCountry = 'Brasil';
        acc.BillingPostalCode = '04060-120';
        insert acc;
        return acc;
    }  

    public static AccountAreaSales__c createAccountAreaSales(String acct, String channel, String salesman){
        AccountAreaSales__c salesArea = new AccountAreaSales__c(AccountLkp__c=acct, ChannelLkp__c=channel, SellerLkp__c=salesman);
        salesArea.CustomIDTxt__c = String.valueOf(Math.random() * 1000);
        salesArea.CodeDistribubutionChannelTxt__c = '01';
        salesArea.CodeSalesOrganizationTxt__c = 'AM01';
        salesArea.CodeActivitySectorTxt__c = 'SC';
        salesArea.SalesOfficeTxt__c= '0020';
        insert salesArea;
        return salesArea;
    }
    
    public static AccountAreaSales__c createAccountAreaSales(Account acct, String channePVClId){
        AccountAreaSales__c salesArea = new AccountAreaSales__c(AccountLkp__c=acct.Id, ChannelLkp__c=channePVClId);
        salesArea.CustomIDTxt__c = String.valueOf(Math.random() * 1000);
        salesArea.CodeDistribubutionChannelTxt__c = 'RV';
        salesArea.CodeSalesOrganizationTxt__c = 'AM01';
        salesArea.CodeActivitySectorTxt__c = 'PR';
        insert salesArea;
        return salesArea;        
    }

    public static SalesOffice__c createSalesOffice(String name, String manager){
        SalesOffice__c so = new SalesOffice__c(Name=name, ManagerLkp__c=manager);
        insert so;
        return so;
    }
    
    public static Channel__c createChannel(String code, String activeKit){
        Channel__c chn = new Channel__c(CodeTxt__c=code, ActiveVerdeAmancoKitLkp__c=activeKit);
        chn.Name = chn.CodeTxt__c;
        insert chn;
        return chn;
        
    }   
    
    public static ExpurgoNotaFiscal__c createExpurgoNotaFiscal(String name, Integer diasParaExpurgo){
        ExpurgoNotaFiscal__c expurgoNF = new ExpurgoNotaFiscal__c(Name=name, Dias_para_expurgo__c=diasParaExpurgo);
        insert expurgoNF;
        return expurgoNF;
    } 
    
    public static ExpurgoItemDaIntegracao__c createExpurgoItemDaIntegracao(String name, Integer diasParaExpurgo){
        ExpurgoItemDaIntegracao__c expurgoIntegracao = new ExpurgoItemDaIntegracao__c(Name=name, DiasParaExpurgo__c=diasParaExpurgo);
        insert expurgoIntegracao;
        return expurgoIntegracao;
    } 
    
    public static VerdeAmancoSolicitation__c createVerdeAmancoSolicitation(String name, String salesArea, String addressType){
        VerdeAmancoSolicitation__c vaSolic = new VerdeAmancoSolicitation__c(Name=name, SalesAreaLkp__c=salesArea, AddressTypeTxt__c=addressType);
        vaSolic.StatusTxt__c = 'Em preenchimento';
        insert vaSolic;
        return vaSolic;
        
    } 
    
    public static VerdeAmancoKit__c createVerdeAmancoKit(String name, String channel){
        VerdeAmancoKit__c kit = new VerdeAmancoKit__c(Name=name, ChannelLkp__c=channel);
        kit.ActiveBln__c = false;
        insert kit;
        return kit;
        
    }    
    
    public static VerdeAmancoKit__c createVerdeAmancoKit(String name, String channel, Boolean active){
        VerdeAmancoKit__c kit = new VerdeAmancoKit__c(Name=name, ChannelLkp__c=channel, ActiveBln__c=active);
        insert kit;
        return kit;
        
    }       
    
    public static VerdeAmancoKitItem__c createVerdeAmancoKitItem(String name, String kit, Integer maxAmount){
        VerdeAmancoKitItem__c ki = new VerdeAmancoKitItem__c(Name=name, VerdeAmancoKitLkp__c=kit, MaximumAmountNmb__c=maxAmount);
        ki.SAPCodeTxt__c = '3213124124';
        insert ki;
        return ki;
    }

    public static Seller__c createSeller(String name, String user, String salesOffice){
        Seller__c sel = new Seller__c(Name=name, UserLkp__c=user, SalesOfficeLkp__c=salesOffice,
                                      SellerNumberNmb__c = String.valueOf(Math.round(Math.random() * 1000)));
        insert sel;
        return sel;
    }

    public static Seller__c createSeller (String name){
        Seller__c sell = new Seller__c (Name = name);
        sell.SellerEmailTxt__c ='seller@email.com.br'; 
        
        sell.ManagerEmailTxt__c = 'manager@email.com.br'; 
        sell.CoordinatorEmailTxt__c= 'coordinator@email.com.br';
        sell.SellerNumberNmb__c = String.valueOf(Math.round(Math.random() * 1000));
        insert sell;
        return sell;
    }
    
    public static Seller__c returnSeller(String name, String user, String salesOffice){
        Seller__c sel = new Seller__c(Name=name, UserLkp__c=user, SalesOfficeLkp__c=salesOffice);
        sel.SellerNumberNmb__c = String.valueOf(Math.round(Math.random() * 1000));
        return sel;
    }    
    
    public static CreditNote__c createCreditNote(String account, String acctGoal, String campaing){
        CreditNote__c cn = new CreditNote__c(AccountLkp__c=account, AccountGoalLkp__c=acctGoal, CampaignLkp__c=campaing);
        insert cn;
        return cn;
    }
    
    public static ContentVersion createContentVersion(String title, String path){
        ContentVersion cv = new ContentVersion(Title=title, PathOnClient=path);
        cv.VersionData = Blob.valueOf('Test Content'); 
        cv.origin = 'H';
        insert cv;
        return cv;
    }
    
    public static ContentDocumentLink createContentDocumentLink(String contentDocument, String linkedEntity){
        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=contentDocument, LinkedEntityId=linkedEntity);
        cdl.ShareType = 'V';
        insert cdl;
        return cdl;
    }
    
    public static Address__c createAddress(String street, String account, String lead){
        Address__c add = new Address__c(Name=street, AccountLkp__c=account, LeadLkp__c=lead);
        insert add;
        return add;
    }

    public static Product2 createProduct(String name){
        Product2 prod = new Product2(Name=name);
        prod.ProductSystemTxt__c = '1000';
        prod.MaterialGroup__c = '01';
        prod.ProductCodeTxt__c = name;
        insert prod;
        return prod;
    }
    
    public static Product2 createProduct(String name, Decimal packageAmt){
        Product2 prod = new Product2(Name=name);
        prod.ProductSystemTxt__c = '1000';
        prod.MaterialGroup__c = '01';
        prod.ProductCodeTxt__c = name;
        prod.StandardPackageAmountNmb__c = packageAmt;
        insert prod;
        return prod;
    }
    
    public static Pricebook__c createPricebook(String name){
        Pricebook__c pb = new Pricebook__c(Name=name);
        insert pb;
        return pb;
        
    }
    
    public static OrderType__c createOrderType(String name){
        OrderType__c ot = new OrderType__c(Name=name, CustomIdTxt__c = name, SalesOrderTypeCodeTxt__c = name);
        insert ot;
        return ot;
    }
    
    public static OrderType__c createOrderType(String name, Boolean hasTerm, Boolean isIrrigation, Boolean hasObservation, Boolean shippingSplit){
        OrderType__c ot = new OrderType__c(Name=name, 
                                           CustomIdTxt__c = name,
                                           ReportPaymentTermsBln__c = hasTerm,
                                           OrderIrrigationBln__c = isIrrigation,
                                           AllowsObservationBln__c	= hasObservation,
                                           ShippingSplitBln__c = shippingSplit, 
                                           SalesOrderTypeCodeTxt__c = name                                           
                                          );
        insert ot;
        return ot;
    }
    
    public static CatalogElement__c createCatalogElement(String name, Integer index, String pricebook, String parent){
        CatalogElement__c elem = new CatalogElement__c(Name=name, IndexNmb__c=index, PricebookLkp__c=pricebook, ParentElementLkp__c=parent);
        insert elem;
        return elem;
    }
    
    public static ElementProduct__c createElementProduct(Product2 prod, CatalogElement__c elem){
        ElementProduct__c elProd = new ElementProduct__c(CatalogElementLkp__c = elem.Id, ProductLkp__c = prod.Id);
        insert elProd;
        return elProd;
    }

    public static Opportunity createOpportunity(String name, String stage, String acc, String salesArea){
        Opportunity opp = new Opportunity(Name=name, StageName=stage, AccountId=acc, Opty_Sales_Area__c=salesArea);
        opp.CloseDate = Date.Today();
        insert opp;
        return opp;
    }
    
    public static Order__c createOrder(String salesArea, String acc, String ordtype, String pricebook, String customId){
        Order__c ord = new Order__c(AccountAreaSalesLkp__c=salesArea, AccountLkp__c=acc, OrderTypeLkp__c=ordtype, PricebookLkp__c=pricebook, CustomIDTxt__c=customId);
        insert ord;
        return ord;
    }

    public static Order__c createOrder(String salesArea, String acc, String ordtype, String pricebook){
        Order__c ord = new Order__c(AccountAreaSalesLkp__c=salesArea, AccountLkp__c=acc, OrderTypeLkp__c=ordtype, PricebookLkp__c=pricebook);
        insert ord;
        return ord;
    }
    
    public static Order__c createOrder(String salesArea, String acc, String ordtype, String pricebook, String customId,String sell, PaymentTerm__c term){
        Order__c ord = new Order__c(AccountAreaSalesLkp__c=salesArea, 
                                    AccountLkp__c=acc, 
                                    OrderTypeLkp__c=ordtype, 
                                    PricebookLkp__c=pricebook, 
                                    CustomIDTxt__c=customId, 
                                    SellerLkp__c = sell,
                                   PaymentTermLkp__c = term.Id);
        insert ord;
        return ord;
    }
    
    public static Order__c createOrder(String salesArea, String acc, String ordtype, String pricebook, String customId,String sell){
        Order__c ord = new Order__c(AccountAreaSalesLkp__c=salesArea, 
                                    AccountLkp__c=acc, 
                                    OrderTypeLkp__c=ordtype, 
                                    PricebookLkp__c=pricebook, 
                                    CustomIDTxt__c=customId, 
                                    SellerLkp__c = sell
                                   );
        insert ord;
        return ord;
    }
    
    public static Order__c quickCreateOrder(){
        Product2 prod1 = TestData.createProduct('Tubo 1');
        prod1.SpecialProductBln__c = true;
        update prod1;
        Product2 prod2 = TestData.createProduct('Tubo 2');
        
        RecordTypeMap rt = RecordTypeMap.getInstance();
 		String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Profile prof = [SELECT Id 
                        FROM Profile 
                        WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testUser321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        Seller__c sel = TestData.createSeller('TestSeller', salesOfficeManager.Id, so.Id);
		Account acc = TestData.createAccount('TestAccount', null, null, rtSAPAcc);
        Channel__c channel = TestData.createChannel('VJ1', null);
        AccountAreaSales__c salesArea = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);
        Pricebook__c pb = TestData.createPricebook('TestPricebook');
        OrderType__c ot = TestData.createOrderType('ZNOV');
        Order__c ord = TestData.createOrder(salesArea.Id, acc.Id, ot.Id, pb.Id, '321312313213');
        return ord;
    }

    public static OrderItem__c createOrderItem(String product, String ord, String expCenter, String carrier){
        OrderItem__c ordi = new OrderItem__c(ProductLkp__c=product, OrderMdt__c=ord, ExpeditionCenterLkp__c=expCenter, CarrierLkp__c=carrier);
        ordi.UnitPriceNmb__c = 10;
        ordi.UnitPriceIPINmb__c = 10;
        ordi.OrderQuantityNmb__c = 15;
        ordi.LiquidNmb__c = 8;
        ordi.TotalNetWeightKgNmb__c = 5.5;
        insert ordi;
        return ordi;
    }
    
    public static SummarizedRevenue__c createSummarizedRevenue(String name, String customId, String salesArea){
        SummarizedRevenue__c sr = new SummarizedRevenue__c(Name=name, CustomIdTxt__c=customId, SalesAreaLkp__c=salesArea);
        sr.ROBNmb__c = 50.50;
        insert sr;
        return sr;
    }
    
    public static SalesPlanning__c createSalesPlanning(String salesArea, String campaign, String quota){
        SalesPlanning__c sp = new SalesPlanning__c(AccountAreaSalesLkp__c=salesArea, CampaignLkp__c=campaign, QuotaLkp__c=quota); 
        insert sp;
        return sp;
    }
    
    public static Invoice__c createInvoice(String name,String Account, String rmt){
        Invoice__c inv = new Invoice__c(Name=name, AccountLkp__c = Account, RemittanceLkp__c = rmt);
        insert inv;
        return inv;
    }
    
    public static Invoice__c createInvoice(String name){
        Invoice__c inv = new Invoice__c(Name=name);
        insert inv;
        return inv;
    }
    
    public static Queue__c createQueue(String eventName){
        Queue__c q = new Queue__c(EventName__c=eventName);
        q.InternalId__c = '12';
        insert q;
        return q;
    }   

    public static Remittance__c createRemittance (String name, String ord, String carrier ){
        Remittance__c rmt = new Remittance__c(Name=name, OrderLkp__c = ord, CarrierLkp__c = carrier);
        rmt.CustomIDTxt__c = '2345612';
        insert rmt;
        return rmt;
    }
    
    public static Carrier__c createCarrier (String name, String email){
        Carrier__c car = new Carrier__c(Name=name, EmailTxt__c = email);
        insert car;
        return car;
    }
    
    public static SummarizedRevenue__c createSummarizedRevenue(AccountAreaSales__c salesArea, Date dte, String materialGroup){
        SummarizedRevenue__c sumRev = new SummarizedRevenue__c(SalesAreaLkp__c = salesArea.Id,
                                                               DateDt__c = System.today().addMonths(-2),
                                                               MaterialGroupTxt__c = materialGroup,
                                                               ROBSpecialNmb__c = 100,
                                                               ROBRevenueNmb__c = 1000,
                                                               ROBNewOfferNmb__c = 300,
                                                               ROBIrrigationMixNmb__c = 400,
                                                               ROBRunnerNmb__c = 200,
                                                              CustomIdTxt__c = String.valueOf(salesArea.Id).substring(10,15) + String.valueOf(dte) + materialGroup);
        insert sumRev;
        return sumRev;
    }
    
    public static SummarizedRevenue__c createSummarizedRevenue(AccountAreaSales__c salesArea, Date dte, Double rolValue){
        SummarizedRevenue__c sumRev = new SummarizedRevenue__c(SalesAreaLkp__c = salesArea.Id,
                                                               DateDt__c = dte,
                                                               MaterialGroupTxt__c = '02',
                                                               ROLRevenueNmb__c = rolValue,
                                                               ROBSpecialNmb__c = 100,
                                                               ROBRevenueNmb__c = 1000,
                                                               ROBNewOfferNmb__c = 300,
                                                               ROBIrrigationMixNmb__c = 400,
                                                               ROBRunnerNmb__c = 200,
                                                               CustomIdTxt__c = String.valueOf(salesArea.Id).substring(10,15) + String.valueOf(dte) + '02');
        insert sumRev;
        return sumRev;        
    } 
    
    public static Quota__c createQuota(Seller__c sel, String year, String month, String quotaType, User u){
        Quota__c quota = new Quota__c(SellerLkp__c = sel.Id, 
                                      CurrentMonthTxt__c = month,
                                      CurrentYearTxt__c = year,
                                      QuotaTypeTxt__c = quotaType,
                                      TotalValueNmb__c = 100000,
                                      OwnerId = u.Id
                                     );
        insert quota;
        return quota;
    }
    
    public static ExpeditionCenter__c createExpeditionCenter(String name, String distributionCode){
        ExpeditionCenter__c expCenter = new ExpeditionCenter__c(CustomIdTxt__c = name, Name = name, CenterCodeTxt__c = distributionCode);
        insert expCenter;
        return expCenter;
    }
    
    public static PaymentTerm__c createPaymentTerm(String name, Decimal installments, Decimal avgTerm){
        PaymentTerm__c term = new PaymentTerm__c(IsActiveBln__c = true,
                                                 CustomizedIdTxt__c = name, 
                                                 Name = name, 
                                                 AverageTermNmb__c = avgTerm, 
                                                 InstallmentsNmb__c = installments);
        insert term;
        return term;
    }
    
    public static Campaign__c createCampaign(Date startDate, Date endDate){
        Campaign__c cmp = new Campaign__c();
        cmp.Name = 'Campanha Teste';
        cmp.StartDate__c = startDate;
        cmp.EndDate__c = endDate;
        cmp.Type__c = 'Fixa';
        
        insert cmp;
        return cmp;
    }
    
    public static CampaignAccount__c createCampaignAccount(Campaign__c cmp, Account cmpGroup){
        CampaignAccount__c cmpAcc = new CampaignAccount__c(CampaignLkp__c = cmp.Id, AccountLkp__c = cmpGroup.Id);
        
        insert cmpAcc;
        return cmpACC;
    }
    
    public static CampaignCalculation__c createCampaignCalculation(Campaign__c cmp, String calcName, Date calcStartDate, Date calcEndDate, Integer position){
        CampaignCalculation__c cmpCalc = new CampaignCalculation__c(Name = calcName, StartDate__c = calcStartDate, EndDate__c = calcEndDate, CampaignLkp__c = cmp.Id, Position__c= position);

        insert cmpCalc;
        return cmpCalc;
    }
    
    public static AccountGoal__c createAccountGoal(Campaign__c cmp, CampaignCalculation__c cmpCalc, CampaignMechanics__c cmpMec, 
                                                   CampaignAccount__c cmpAcc, Double goal, Double real, Double calcBasis){
        AccountGoal__c accGoal = new AccountGoal__c(CampaignLkp__c = cmp.Id, 
                                                    BenefitPercentage__c = cmpMec.Percentage__c, 
                                                    Description__c = cmpMec.CalculationCriteria__c, 
                                                    AccountLkp__c = cmpAcc.AccountLkp__c,
                                                    CampaignMechanicsLkp__c = cmpMec.Id,
                                                    CampaignCalculationLkp__c = cmpCalc.Id,
                                                    CalculationBasis__c = calcBasis);
                                                       
        
        insert accGoal;                                              
                            
        List<MonthlyGoal__c> listMonGoal = new List<MonthlyGoal__c>();
        Integer nMonths = cmpCalc.StartDate__c.monthsBetween(cmpCalc.EndDate__c) + 1; //Adds 1 to consider the starting month 
                                                       
        for(Integer I = 0 ; I < nMonths; I++){           
            MonthlyGoal__c monGoal = new MonthlyGoal__c(CampaignLkp__c = cmp.Id,
                                                        BenefitPercentageNmb__c = cmpMec.Percentage__c,
                                                        DescriptionTxt__c = cmpMec.CalculationCriteria__c,
                                                        AccountMdt__c = cmpAcc.AccountLkp__c,
                                                        CampaignMechanicsLkp__c = cmpMec.Id,
                                                        CampaignCalculationLkp__c = cmpCalc.Id,
                                                        GoalNmb__c = goal/nMonths,
                                                        RevenueNmb__c = real/nMonths,
                                                        BenefitRevenueNmb__c = calcBasis/nMonths,
                                                        MonthNmb__c = cmpCalc.StartDate__c.month() + I,
                                                        MonthDte__c = cmpCalc.StartDate__c.addMonths(I),
                                                        AccountGoalMdt__c = accGoal.Id
                                                       );
            listMonGoal.add(monGoal);
        }                                    
        insert listMonGoal;
                                                       
        return accGoal;
    }
    
    public static Account createCampaignGroup(String areaSalesId){
        RecordTypeMap rt = RecordTypeMap.getInstance();
        String rtGroup = rt.rtmap.get('Account').get('CampaignGroup');
        
        Account cmpGroup = new Account();
        cmpGroup.Name = 'Agrupamento Teste';
        cmpGroup.GroupCodeTxt__c = '9999';
        cmpGroup.MainSalesAreaLkp__c = areaSalesId;
        cmpGroup.RecordTypeId = rtGroup;
        
        insert cmpGroup;
        return cmpGroup;
    }
    
    public static CampaignIndicator__c createCampaignIndicator(){
        CampaignIndicator__c cmpInd = new CampaignIndicator__c();
        cmpInd.Name__c = 'Predial';
        cmpInd.Description__c = 'Total Predial';
        cmpInd.Table__c = 'SummarizedRevenue__c';
        cmpInd.GroupBy__c = 'SalesAreaLkp__r.CampaignGroupLkp__r.Id';
        cmpInd.GroupedField__c = 'SUM(ROLRevenueNmb__c)';
        cmpInd.Filter__c = 'SalesAreaLkp__r.CampaignGroupLkp__c <> null AND SalesAreaLkp__r.CampaignActive__c = True';
        cmpInd.DateField__c = 'DateDt__c';
        
        insert cmpInd;
        return cmpInd;
    }
    
    public static CampaignMechanics__c createCampaignMechanics(Campaign__c cmp, CampaignIndicator__c cmpIndicator, CampaignIndicator__c cmpBenefit, String paymentType, Boolean getNCDiscount)
    {
        CampaignMechanics__c cmpMech = new CampaignMechanics__c(CampaignLkp__c = cmp.Id, CampaignIndicatorLkp__c = cmpIndicator.Id,  
                                                                BenefitCriteriaLkp__c = cmpBenefit.Id, PaymentTypeTxt__c = paymentType, ApplyDiscountBln__c = getNCDiscount);
        cmpMech.MainMechanic__c = true;
        cmpMech.Percentage__c = 3;      
        
        insert cmpMech;                                                                  
        return cmpMech;
    }
    
    public static Campaign__c createCompleteCampaignNcDiscount(Boolean createAccountGoals){
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testManager321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        prof = [SELECT Id FROM Profile WHERE Name = 'Vendedor'];
        User sellerUser = TestData.createUser('TestSeller', null, null, prof.Id, 'testUser321@test.com');
        Seller__c sel = TestData.createSeller('TestSeller', sellerUser.Id, so.Id);      
        RecordTypeMap rt = RecordTypeMap.getInstance();
        String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        //Account acc = TestData.createAccount('TestAccount', null, null, rtSAPAcc);
        Account acc = TestData.createAccount('TestAccount', null, null, rtSAPAcc, '165134');
        Channel__c channel = TestData.createChannel('VJ1', null);
        AccountAreaSales__c av = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);        
        
        Account cmpGroup = createCampaignGroup(av.Id);
        CampaignIndicator__c cmpIndicator = createCampaignIndicator();
        av.CampaignActive__c= true;
        av.CampaignGroupLkp__c = cmpGroup.Id;
        update av;
        
        Account acc2 = TestData.createAccount('TestAccount2', null, null, rtSAPAcc, '209819');
        AccountAreaSales__c av2 = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);  
        av2.CampaignActive__c= true;
        av2.CampaignGroupLkp__c = cmpGroup.Id;  
        update av2;
        
        //ummarizedRevenue__c sumRev = createSummarizedRevenue(av, Date.newInstance(2017, 1, 1), 700);
        //sumRev = createSummarizedRevenue(av, Date.newInstance(2017, 4, 1), 2400);
        //sumRev = createSummarizedRevenue(av, Date.newInstance(2017, 7, 1), 2500);
        SummarizedRevenue__c sumRev = createSummarizedRevenue(av, Date.newInstance(2017, 10, 1), 3000);
        
        Campaign__c cmp = createCampaign(Date.newInstance(2017, 1, 1), Date.newInstance(2017, 12, 31));
        CampaignCalculation__c cmpCalc1 = createCampaignCalculation(cmp, 'T1', Date.newInstance(2017, 1, 1), Date.newInstance(2017, 3, 31), 0);
        CampaignCalculation__c cmpCalc2 = createCampaignCalculation(cmp, 'T2', Date.newInstance(2017, 4, 1), Date.newInstance(2017, 6, 30), 0);
        CampaignCalculation__c cmpCalc3 = createCampaignCalculation(cmp, 'T3', Date.newInstance(2017, 7, 1), Date.newInstance(2017, 9, 30), 0);
        CampaignCalculation__c cmpCalc4 = createCampaignCalculation(cmp, 'T4', Date.newInstance(2017, 10, 1), Date.newInstance(2017, 12, 31), 0);
        
        CampaignAccount__c cmpAcc = createCampaignAccount(cmp, cmpGroup);
        
        CampaignMechanics__c cmpMec = createCampaignMechanics(cmp, cmpIndicator, cmpIndicator, 'FATU', true);
        
        if (createAccountGoals){
            createAccountGoal(cmp, cmpCalc1, cmpMec, cmpAcc, 9000, 6300, 6300);
            createAccountGoal(cmp, cmpCalc2, cmpMec, cmpAcc, 12000, 15000, 15000);
            createAccountGoal(cmp, cmpCalc3, cmpMec, cmpAcc, 15000, 12000, 12000);
            createAccountGoal(cmp, cmpCalc4, cmpMec, cmpAcc, 18000, 0, 0);            
        }

        return cmp;
    }
    
    public static Campaign__c createCompleteCampaign(Boolean createAccountGoals){
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Gerente de Vendas'];
        User salesOfficeManager = TestData.createUser('TestManager', null, null, prof.Id, 'testManager321@test.com');
        SalesOffice__c so = TestData.createSalesOffice('TestSalesOffice', salesOfficeManager.Id);
        prof = [SELECT Id FROM Profile WHERE Name = 'Vendedor'];
        User sellerUser = TestData.createUser('TestSeller', null, null, prof.Id, 'testUser321@test.com');
        Seller__c sel = TestData.createSeller('TestSeller', sellerUser.Id, so.Id);      
        RecordTypeMap rt = RecordTypeMap.getInstance();
        String rtSAPAcc = rt.rtmap.get('Account').get('SAPBusinessAccount');
        Account acc = TestData.createAccount('TestAccount', null, null, rtSAPAcc);
        Channel__c channel = TestData.createChannel('VJ1', null);
        AccountAreaSales__c av = TestData.createAccountAreaSales(acc.Id, channel.Id, sel.Id);

        
        Account cmpGroup = createCampaignGroup(av.Id);
        CampaignIndicator__c cmpIndicator = createCampaignIndicator();
        av.CampaignActive__c= true;
        av.CampaignGroupLkp__c = cmpGroup.Id;
        update av;
        
        //ummarizedRevenue__c sumRev = createSummarizedRevenue(av, Date.newInstance(2017, 1, 1), 700);
        //sumRev = createSummarizedRevenue(av, Date.newInstance(2017, 4, 1), 2400);
        //sumRev = createSummarizedRevenue(av, Date.newInstance(2017, 7, 1), 2500);
        SummarizedRevenue__c sumRev = createSummarizedRevenue(av, Date.newInstance(2017, 10, 1), 3000);
        
        Campaign__c cmp = createCampaign(Date.newInstance(2017, 1, 1), Date.newInstance(2017, 12, 31));
        CampaignCalculation__c cmpCalc1 = createCampaignCalculation(cmp, 'T1', Date.newInstance(2017, 1, 1), Date.newInstance(2017, 3, 31), 0);
        CampaignCalculation__c cmpCalc2 = createCampaignCalculation(cmp, 'T2', Date.newInstance(2017, 4, 1), Date.newInstance(2017, 6, 30), 0);
        CampaignCalculation__c cmpCalc3 = createCampaignCalculation(cmp, 'T3', Date.newInstance(2017, 7, 1), Date.newInstance(2017, 9, 30), 0);
        CampaignCalculation__c cmpCalc4 = createCampaignCalculation(cmp, 'T4', Date.newInstance(2017, 10, 1), Date.newInstance(2017, 12, 31), 0);
        
        CampaignAccount__c cmpAcc = createCampaignAccount(cmp, cmpGroup);
        
        CampaignMechanics__c cmpMec = createCampaignMechanics(cmp, cmpIndicator, cmpIndicator, 'FATU', false);
        
        if (createAccountGoals){
            createAccountGoal(cmp, cmpCalc1, cmpMec, cmpAcc, 9000, 6300, 6300);
            createAccountGoal(cmp, cmpCalc2, cmpMec, cmpAcc, 12000, 15000, 15000);
            createAccountGoal(cmp, cmpCalc3, cmpMec, cmpAcc, 15000, 12000, 12000);
            createAccountGoal(cmp, cmpCalc4, cmpMec, cmpAcc, 18000, 0, 0);            
        }

        return cmp;
    }
    
    
    public static TradeMktSurvey__c createTrdMktSurvey() {
        TradeMktSurvey__c trdMktSurvey = new TradeMktSurvey__c();
        trdMktSurvey.Name = 'Test Survey';
        trdMktSurvey.BrandsTxt__c = 'Amanco;Plastubos';
        trdMktSurvey.LimitDate__c = system.today() + 5;
        trdMktSurvey.IsActiveBln__c = FALSE;
        insert trdMktSurvey;
        return trdMktSurvey;
    }        
    
    public static SurveyProduct__c createSurveyProduct(TradeMktSurvey__c trdMktSurvey, Product2 prod, string otherProduct, string otherMaterialGroup){               
        SurveyProduct__c surveyProduct = new SurveyProduct__c(TradeMktSurveyLkp__r = trdMktSurvey,
                                                              ProductLkp__c = prod != null ? prod.Id : null, 
                                                              OtherProductsTxt__c = otherProduct != null ? otherProduct : null, 
                                                              OtherMaterialGroupTxt__c = otherMaterialGroup);        
        insert surveyProduct;
        return surveyProduct;
    }
    
    public static CustomerSurvey__c createCustomerSurvey (TradeMktSurvey__c trdMktSurvey, AccountAreaSales__c accAreaSales, string status){
        CustomerSurvey__c customerSurvey = new CustomerSurvey__c(TradeMktSurveyLkp__c = trdMktSurvey.Id, 
                                                                 TradeMktSurveyLkp__r = trdMktSurvey, 
                                                                 AccountAreaSalesLkp__c = accAreaSales.Id,
                                                                 AccountAreaSalesLkp__r = accAreaSales, 
                                                                 StatusTxt__c = status);
        insert customerSurvey;
        return customerSurvey;        
    }
    
    public static SkipValidations__c createSkipValidations(){
        SkipValidations__c skipVal = SkipValidations__c.getOrgDefaults();
        skipVal.Skip__c = False;
        upsert skipVal;
        return skipVal;
    }
    
    public static Case quickCreateCase(){
        Channel__c channel = TestData.createChannel('VJ1', null);
        Account conta = TestData.createAccount('Conta', channel.id);
        conta.CodeCustomerTxt__c = '203761';
        update conta;
        AccountAreaSales__c sa = TestData.createAccountAreaSales(conta, channel.Id);
        sa.CustomIDTxt__c = conta.CodeCustomerTxt__c + sa.CodeSalesOrganizationTxt__c;
        update sa;
        Pricebook__c pb = TestData.createPricebook('TestPricebook');
        OrderType__c ot = TestData.createOrderType('ZNOV');
        
        Order__c ord = TestData.createOrder(sa.Id, conta.Id, ot.Id, pb.Id, '321312313223');
        
        Remittance__c remessa = new Remittance__c();
        remessa.OrderLkp__c = ord.Id;
        remessa.CustomIDTxt__c = '01';
        insert remessa;
        
        Invoice__c nota = new Invoice__c();
        nota.RemittanceLkp__c = remessa.Id;
        insert nota;
        
        Case caso = new Case();
        caso.OrderLkp__c = ord.Id;
        caso.InvoiceLkp__c = nota.Id;
        caso.AccountId = conta.Id;
        insert caso;
        
        QM__c qm = new QM__c();
        qm.CaseLkp__c = caso.id;
        insert qm; 
        
        ord.CaseLkp__c = caso.id;
        update ord;
        
        CaseItem__c casoItem = new CaseItem__c();
        casoItem.CaseMdt__c = caso.id;
        casoItem.CustomIDTxt__c = casoItem.CustomIDTxt__c = String.valueOf(caso.id) + String.valueOf(casoItem.Id);
        insert casoItem;
        casoItem.CustomIDTxt__c = String.valueOf(caso.id) + String.valueOf(casoItem.Id); //Id do Item nao existia antes do insert e eh obrigatorio
        update casoItem;
        System.debug(casoItem);
        
        return caso;
    }
    
    public static void createIntegrationData(){
        List<ApexRedirectMap__c> listConfig = new List<ApexRedirectMap__c>();
        listConfig.add(new ApexRedirectMap__c(Name='EndpointPrefix', UrlSufix__c='http://179.125.173.106:50000/RESTAdapter/SFDC/'));
        listConfig.add(new ApexRedirectMap__c(Name='EndpointSuffix', UrlSufix__c='/Homologation'));
        listConfig.add(new ApexRedirectMap__c(Name='WebServiceUser', UrlSufix__c='USER_SFDC_HOMOLOG'));
        listConfig.add(new ApexRedirectMap__c(Name='WebServicePassword', UrlSufix__c='homolog_2016*'));
        insert listConfig;
    }
    
}