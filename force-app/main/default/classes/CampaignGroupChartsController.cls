public class CampaignGroupChartsController {
    public String currentRecordId {get;set;}
    public String campaignReportId {get;set;}
    
    public CampaignGroupChartsController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        Report r = [SELECT Id FROM REPORT WHERE DeveloperName = 'CampaignGoalsCurrentQuarter'];
        campaignReportId = r.Id;
    }
    
    public PageReference openReport(){
        PageReference nextPage = new PageReference('/sObject/' + '00OL0000000bfseMAA'+'/view');
        nextPage.getParameters().put('fv1', campaignReportId);
        return nextPage;
    }
}