public with sharing class Soql {
	
	private String queryString = '';
    
    public Soql() {
    }
    
    public Soql addLine(String str) {
    	queryString += ' ' + str + '\n ';
    	return this;
    }
    
    public override String toString(){
    	return this.queryString;
    }
        
}