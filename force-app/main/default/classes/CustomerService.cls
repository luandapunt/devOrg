global class CustomerService  extends integ_SyncIntegrationServiceAbstract {
	
	global static CustomerService instance;
	
	private CustomerService(){
		
	}
	
	private static CustomerService getInstance() {
		if (instance == null) {
			instance = new CustomerService();
		}
		return instance;
	}
    
    webservice static List<Invoice__c> getOrderByCustomer(String customerCode, Date fromDate, Date toDate){
    	return getInstance().executeRemoteService(customerCode, fromDate, toDate);
    }
        
    private List<Invoice__c> executeRemoteService(String customerCode, Date fromDate, Date toDate) {
        CustomerRemoteCall remoteCall = new CustomerRemoteCall(customerCode, fromDate, toDate);
        return (List<Invoice__c>)super.execute(IntegrationIds.SYNC_ORDER_OUTBOUND.name(), remoteCall);
    }
    
}