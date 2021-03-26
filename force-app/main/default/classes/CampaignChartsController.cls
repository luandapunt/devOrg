public class CampaignChartsController {
    public String currentRecordId {get;set;}
    public String campaignReportId {get;set;}
    
    public CampaignChartsController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        Report r = [SELECT Id FROM REPORT WHERE DeveloperName = 'FollowUpCampaignTradeMarketing'];
        campaignReportId = r.Id;
    } 
}