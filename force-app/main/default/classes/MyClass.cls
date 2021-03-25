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
        FirstName='Joe',
        LastName='Smith',
        Phone='415.555.1212',
        AccountId=acctID);
    insert con;
} catch(DmlException e) {
    System.debug('An unexpected error has occurred: ' + e.getMessage());
}
    }
}