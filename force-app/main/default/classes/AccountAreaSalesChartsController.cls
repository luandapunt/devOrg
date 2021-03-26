public class AccountAreaSalesChartsController{
    public String currentRecordId {get;set;}
    public String caseReportId {get;set;}
    public String orderReportId {get;set;}
    public String orderStatusReportId {get;set;}
    
    public AccountAreaSalesChartsController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        List<Report> reportList = [SELECT Id, DeveloperName FROM REPORT WHERE DeveloperName = 'AccountAreaSalesOrderStatus' OR
                                   DeveloperName = 'AccountAreaSalesCases' OR
                                   DeveloperName = 'AccountAreaSalesOrders'];
        
        Map<String, String> reportMap = new Map<String, String>();
        for(Report r: reportList){
            reportMap.put(r.DeveloperName, r.Id);
        }
        
        caseReportId = reportMap.get('AccountAreaSalesCases');
        orderReportId = reportMap.get('AccountAreaSalesOrders');
        orderStatusReportId = reportMap.get('AccountAreaSalesOrderStatus');
    } 
}