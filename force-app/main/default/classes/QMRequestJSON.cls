public with sharing class QMRequestJSON {
    public String NQMSF;
    public String QMNUM_SAP;
    public String NCASO;
    public String VKORG; //verificar por record type    
    public String ZR_ORDEM_CLIENTE;
    public String ZR_NATUR_RECLAM_COD;
    public String ZR_REGISTRO;
    public String ZR_COD_NAO_CONF;
    public String ZR_DOCNUM;
    public String USER_SF;
    public String ZR_DEV_S_REM;
    public String ZR_FLAG_NFCLI;
    public String ZR_TIPO_DEVOL;
    public String ZR_NUM_NFCLI;
    public String ZR_CONTATO_CLIENTE;
    public String ZR_TEL_NUMBER;
    public Decimal ZR_NF_QTDE_VOL;
    public Decimal ZR_NF_PESO;
    public String ZR_DADOS_ADIC;
    public String ZR_DATA_EMBARQUE;
    public String ZR_DATA_ENTREGA;
    public Decimal ZR_DIAS_ATRASO;
    public String ZR_VBELN_REF;
    public String ZC_NOME_DO_TECNICO;
    public String ZC_ORDEM_REPOS;
    public String ZC_ORIGEM_RECLAM;
    public String KUNNR;
    public String ZC_MATNR;
    public String WERKS;
    public Decimal ZC_QTDE_PCS_RECLAM;
    public String PRIOK;
    public String ZC_DATA_INI_DES;
    public String VTWEG;
    public String SPART;
    public String VKBUR;
    public String VKGRP;
    public String ZC_PESSOA_CONT_CNPJ_CPF; //verificar quem que existe
    public String ZC_PESSOA_CONT_ENDERECO;
    public String ZC_PESSOA_CONT_UF;
    public String ZC_PESSOA_CONT_CIDADE;
    public String ZC_PESSOA_CONT_CEP;
    public String ZC_PESSOA_CONT_BAIRRO;
        
    public QMRequestJSON(QM__c qm) {
        system.debug('qmid JSONREQUEST>>>>>'+ qm );
        NQMSF = qm.SalesforceQMTxt__c;
        QMNUM_SAP = qm.QMSAPTxt__c;     
        NCASO = qm.CaseLkp__r.CaseNumber;
        //RSILVA 05/01/18 ALTERADO DE NAME PARA CustomIDTxt__c , Adicionar campo QMDAO;
        //ZR_ORDEM_CLIENTE = qm.ClientOrderLkp__r.Name;
        ZR_ORDEM_CLIENTE = qm.ClientOrderLkp__r.CustomIDTxt__c;
        
        if(qm.ComplaintReasonTxt__c != null && !qm.ComplaintReasonTxt__c.equals('')) {
            ZR_NATUR_RECLAM_COD = qm.ComplaintReasonTxt__c.split('-')[0];       
        }
        
        if(qm.RecordTxt__c != null && !qm.RecordTxt__c.equals('')) {
            if(qm.RecordTxt__c.equals('Devolução')) {
                ZR_REGISTRO = 'DEVOLUÇA';
            } else if(qm.RecordTxt__c.equals('Reclamação')) {
                ZR_REGISTRO = 'RECLAMAC';
            } else if(qm.RecordTxt__c.equals('Substituição')) {
                ZR_REGISTRO = 'SUBSTITU';
            }
        }
        
        if(qm.NonConformityTxt__c != null && !qm.NonConformityTxt__c.equals('') && !qm.NonConformityTxt__c.startsWith('---')) {
            ZR_COD_NAO_CONF = qm.NonConformityTxt__c.split('-')[0];
        }
        
        ZR_DOCNUM = qm.InvoiceLkp__r.DocumentNumberTxt__c;
        USER_SF = qm.CoordinatorFml__c;
        
        if(qm.RecordType.DeveloperName.equals('QMReposicaoItemI')) {
            if(qm.RetWithoutRemBln__c) {
            if(qm.RetWithoutRemBln__c) {
                ZR_DEV_S_REM = 'T';     
            }else {
                ZR_DEV_S_REM = 'F';
            }
        }
        
        if(qm.ClientInvoiceBln__c != null) {
            if(qm.ClientInvoiceBln__c) {
                ZR_FLAG_NFCLI = 'T';
            } else {
                ZR_FLAG_NFCLI = 'F';
            }
        }
        }
        
        if(qm.RecordType.DeveloperName.equals('QMDevolucaoParcial')) {
            if(qm.RetWithoutRemBln__c) {
                if(qm.RetWithoutRemBln__c) {
                    ZR_DEV_S_REM = 'T';     
                }else {
                    ZR_DEV_S_REM = 'F';
                }
            }
        
            if(qm.ClientInvoiceBln__c != null) {
                if(qm.ClientInvoiceBln__c) {
                    ZR_FLAG_NFCLI = 'T';
                } else {
                    ZR_FLAG_NFCLI = 'F';
                }
            }
        }
        
        if(qm.RecordType.DeveloperName.equals('QMDevolucaoTotalCliente')) {
            if(qm.ClientInvoiceBln__c != null) {
                if(qm.ClientInvoiceBln__c) {
                    ZR_FLAG_NFCLI = 'T';
                } else {
                    ZR_FLAG_NFCLI = 'F';
                }
            }
        }
        
  
        
        if(qm.DevolutionTxt__c != null && !qm.DevolutionTxt__c.equals('')) {
            ZR_TIPO_DEVOL = qm.DevolutionTxt__c.toUppercase().subString(0,1);
        }
        
        ZR_NUM_NFCLI = qm.NumberClientInvoiceTxt__c;
        
        
        ZR_NF_QTDE_VOL  =   qm.VolumeNmb__c;
        ZR_NF_PESO  =   qm.GrossWeightNmb__c;
        ZR_DADOS_ADIC   =   qm.AditionalDataTxt__c;
        if(qm.ShipmentDateDte__c != null) {
            ZR_DATA_EMBARQUE    =   sfToSapDate(qm.ShipmentDateDte__c);
        }
        if(qm.DeliveryDateDte__c != null) {
            ZR_DATA_ENTREGA =   sfToSapDate(qm.DeliveryDateDte__c);
        }
        ZR_DIAS_ATRASO  =   qm.DaysDueNmb__c;
        ZR_VBELN_REF    =   qm.OrderAdditionalLkp__r.Name;
        ZC_NOME_DO_TECNICO  =   qm.TechnicianLkp__r.Name;
        ZC_ORDEM_REPOS  =   qm.OrderNumberTxt__c;
        
        if(qm.OriginTxt__c != null && !qm.OriginTxt__c.equals('')) {
            if(qm.OriginTxt__c.equals('0800')) {
                ZC_ORIGEM_RECLAM = 'F'; 
            } else {
                ZC_ORIGEM_RECLAM = qm.OriginTxt__c.toUppercase().subString(0,1); 
            }               
        }
        
        if(qm.AccountIssuerLkp__r.CodeCustomerTxt__c != null && !qm.AccountIssuerLkp__r.CodeCustomerTxt__c.equals('')) {
            KUNNR   =   qm.AccountIssuerLkp__r.CodeCustomerTxt__c;
        }
        
        if(qm.ProductFml__c != null && !qm.ProductFml__c.equals('')) {
            ZC_MATNR    =   qm.CaseItemLkp__r.ProductLkp__r.ProductCodeTxt__c;
        }
        
        ZC_QTDE_PCS_RECLAM  =   qm.QuantityFml__c;
                
        if(qm.StartDateDte__c != null) {
            ZC_DATA_INI_DES =   sfToSapDate(qm.StartDateDte__c);
        }
        if(qm.ProductDistributionChannelFml__c != null && !qm.ProductDistributionChannelFml__c.equals('')) {
            VTWEG   =   qm.ProductDistributionChannelFml__c.split('-')[0];
        }
        
        if(qm.ProductActivitySectorFml__c != null && !qm.ProductActivitySectorFml__c.equals('')) {
            SPART   =   qm.ProductActivitySectorFml__c.split('-')[0];
        }
        
        if(qm.ProductSalesOfficeFml__c != null && !qm.ProductSalesOfficeFml__c.equals('')) {
            VKBUR   =   qm.ProductSalesOfficeFml__c.split('-')[0];
        }
        
        if(qm.ProductSalesTeamFml__c != null && !qm.ProductSalesTeamFml__c.equals('')) {
            VKGRP   =   qm.ProductSalesTeamFml__c.split('-')[0];                
        }
        //ZC_PESSOA_CONT_ENDERECO   =   qm.StreetTxt__c;
        //ZC_PESSOA_CONT_UF =   qm.StateTxt__c;
        //ZC_PESSOA_CONT_CIDADE =   qm.CityTxt__c;
        //ZC_PESSOA_CONT_CEP    =   qm.PostalCodeTxt__c;
        //ZC_PESSOA_CONT_BAIRRO =   qm.NeighborhoodTxt__c;
        
        if(qm.RecordType.DeveloperName.equals('QMReclamacao')) {
            
            if(qm.ProductSalesOrganizationFml__c != null && !qm.ProductSalesOrganizationFml__c.equals('')) {
                VKORG   =   qm.ProductSalesOrganizationFml__c.split('-')[0];
            }
            
            ZR_TEL_NUMBER   =   qm.ContactPhoneFml__c;
            
            if(qm.CPFTxt__c != null && !qm.CPFTxt__c.equals('')) {
                ZC_PESSOA_CONT_CNPJ_CPF =   qm.CPFTxt__c;   
            }else {
                ZC_PESSOA_CONT_CNPJ_CPF =   qm.CNPFml__c;   
            }
            
            if(qm.ManufacturingCenterFml__c != null && !qm.ManufacturingCenterFml__c.equals('')) {
                WERKS   =   qm.ManufacturingCenterFml__c.split('-')[0];
            }
            
            ZR_CONTATO_CLIENTE  =   qm.ClientContactLkp__r.Name;
            
            if(qm.PriorityTxt__c != null && !qm.PriorityTxt__c.equals('')) {
                PRIOK   =   qm.PriorityTxt__c.split('-')[0];
            }
            
        } else {
            if(qm.ManufacturingCenterTxt__c != null && !qm.ManufacturingCenterTxt__c.equals('')) {
                WERKS   =   qm.ManufacturingCenterTxt__c.split('-')[0];
            }
            if(qm.SalesOrganizationFml__c != null && !qm.SalesOrganizationFml__c.equals('')) {
                VKORG   =   qm.SalesOrganizationFml__c.split('-')[0];
            }
            ZR_TEL_NUMBER   =   qm.PhoneTxt__c;
            
            ZR_CONTATO_CLIENTE  =   qm.ClientContactTxt__c;
            
            PRIOK = '1';
        }           
        
        ZC_PESSOA_CONT_ENDERECO = qm.StreetFml__c;
        ZC_PESSOA_CONT_UF = qm.StateFml__c;
        ZC_PESSOA_CONT_CIDADE = qm.CityFml__c;
        ZC_PESSOA_CONT_CEP = qm.PostalCodeFml__c;
        ZC_PESSOA_CONT_BAIRRO = qm.NeighborhoodFml__c;
    }
    
    private String sfToSapDate(Date sfDate) {       
        return (String.valueOf(sfDate.year()) + (sfDate.month() < 10 ? '0' + String.valueOf(sfDate.month()) : String.valueOf(sfDate.month())) + (sfDate.day() < 10 ? '0' + String.valueOf(sfDate.day()) : String.valueOf(sfDate.day())));
    }
}