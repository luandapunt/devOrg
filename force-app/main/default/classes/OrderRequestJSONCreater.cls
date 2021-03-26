public with sharing class OrderRequestJSONCreater {
    public static String execute(String invoiceNumber, String customerCode) {
    	
    	invoiceNumber = StringUtil.leftPadding(9,'0',invoiceNumber);
    	customerCode = StringUtil.leftPadding(10,'0',customerCode);
    	
    	OrderRequestJSON orderRequestJson = new OrderRequestJSON(invoiceNumber, customerCode);
    	
    	String jsonData = JSON.serialize(orderRequestJson);
    	
    	jsonData = '{"request": ' + jsonData + '}';
    	
    	system.debug(jsonData);
    	
    	return jsonData;
    }
}