public with sharing class QMDAO {
    
    public static List<QM__c> getById(Set<Id> qmIdSet) {
        return [
            SELECT Id,
                ProductDistributionChannelFml__c,
                CaseLkp__c,
                CaseLkp__r.CaseNumber,
                CoordinatorFml__c,
                AditionalDataTxt__c,
                ShipmentDateDte__c,
                DeliveryDateDte__c,
                DevolutionTxt__c,
                RetWithoutRemBln__c,
                DaysDueNmb__c,
                ClientContactLkp__r.Name,
                AccountIssuerLkp__c,
                AccountIssuerLkp__r.CodeCustomerTxt__c,
                ProductSalesTeamFml__c,
                ProductSalesOfficeFml__c,
                FinishDateDte__c,
                StartDateDte__c,
                NonConformityTxt__c,
                ComplaintReasonTxt__c,
                ClientInvoiceBln__c,
                InvoiceLkp__c,
                OrderNumberTxt__c,
                NumberClientInvoiceTxt__c,
                OrderAdditionalLkp__c,
                OrderAdditionalLkp__r.Name,
                ClientOrderLkp__c,
                ClientOrderLkp__r.CustomIDTxt__c,  //RSILVA 11_01_18
                SalesOrganizationFml__c,
                ProductSalesOrganizationFml__c,
                OriginTxt__c,
                //GrossWeightFml__c,
                GrossWeightNmb__c,
                PriorityTxt__c,
                ProductFml__c,
                SalesforceQMTxt__c,
                QMSAPTxt__c,
                QuantityFml__c,
                RecordTxt__c,
                SellerLkp__c,
                ProductActivitySectorFml__c,
                TechnicianLkp__c,
                TechnicianLkp__r.Name,
                PhoneTxt__c,
                //VolumeFml__c,
                VolumeNmb__c,
                Name,
                RecordType.DeveloperName,
                ClientOrderLkp__r.Name,
                ManufacturingCenterFml__c,
                InvoiceLkp__r.DocumentNumberTxt__c,
                CPFTxt__c,
                CNPFml__c,
                ClientContactLkp__c,
                ContactPhoneFml__c,
                ManufacturingCenterTxt__c,
                StreetFml__c,
                StateFml__c,
                CityFml__c,
                PostalCodeFml__c,
                NeighborhoodFml__c,
                ClientContactTxt__c,
                CaseItemLkp__r.ProductLkp__r.ProductCodeTxt__c,
                StatusTxt__c,
                ErrorTxt__c
                //CaseItemLkp__c,
                //AccountAddressLkp__c
                
            FROM QM__c
            WHERE Id IN :qmIdSet
        ];      
    }

    public static List<QM__c> getByCaseId(Set<Id> caseIdSet) {

        return [
            SELECT Id
                  ,CaseLkp__c
            FROM QM__c
            WHERE CaseLkp__c IN :caseIdSet
        ];
    }
    
}