public with sharing class CustomerSyncRequestJSON {

	public String KUNNR {get;set;}
	public String ERDAT_INI {get;set;}
	public String ERDAT_FIM {get;set;}

	public CustomerSyncRequestJSON(String KUNNR, String ERDAT_INI, String ERDAT_FIM) {
		this.KUNNR = KUNNR;
		this.ERDAT_INI = ERDAT_INI;
		this.ERDAT_FIM = ERDAT_FIM;
	}
}