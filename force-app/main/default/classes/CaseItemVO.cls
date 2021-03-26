public with sharing class CaseItemVO {
	
    public Boolean Checked {get; set;}
    public Id Id {get; set;}
    //public Id ProductId {get; set;}
    //public String ProductName {get; set;}
    public Integer Quantity {get; set;}
    public Integer MaxQuantity {get; set;}
    public String FailureType {get; set;}
    public CaseItem__c CaseItem {get; set;}
    public String Comments {get; set;}
    public String QualityProblem {get; set;}
    public String Denomination {get; set;}
    
}