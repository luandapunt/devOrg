/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-25-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-25-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global class MyClass {

    webservice static void myMethod() // you can pass parameters
    {
        try {
    Account acct = new Account(Name='Conta Teste');
    insert acct;

    // Once the account is inserted, the sObject will be 
    // populated with an ID.
    // Get this ID.
    ID acctID = acct.ID;

    // Add a contact to this account.
    Contact con = new Contact(
        FirstName='Luan',
        LastName='Smith',
        Phone='415.555.1212',
        AccountId=acctID);
    insert con;
} catch(DmlException e) {
    System.debug('An unexpected error has occurred: ' + e.getMessage());
}
    }
}