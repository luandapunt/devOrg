@RestResource(urlMapping='/helloworld/*') 
global with sharing class GetPricePredictions { 

@HttpGet 
global static void hello(){ 
try {
    Account acct = new Account(Name='Conta Motoca Pt.3');
    insert acct;

    // Once the account is inserted, the sObject will be 
    // populated with an ID.
    // Get this ID.
    ID acctID = acct.ID;

    // Add a contact to this account.
    Contact con = new Contact(
        FirstName='Siemens',
        LastName='BR Jundiai',
        Phone='415.555.1212',
        AccountId=acctID);
    insert con;
} catch(DmlException e) {
    System.debug('An unexpected error has occurred: ' + e.getMessage());
}
    }
}