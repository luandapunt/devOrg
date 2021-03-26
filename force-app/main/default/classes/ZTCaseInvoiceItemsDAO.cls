@isTest
private class ZTCaseInvoiceItemsDAO
{
    static testMethod void testSelect()
    {
    	//Id id = '5454af6ssaas';
    	CaseInvoiceItemsDAO caseInvoiceItemsDao = new CaseInvoiceItemsDAO('12345', '1646d4as6das6', '4564666', '54fdas564fd4a', null);
    	
    	caseInvoiceItemsDao =  new CaseInvoiceItemsDAO('abc', 'def', null);
    }
}