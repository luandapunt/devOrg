@IsTest
private class Test_OrderClone {


    static testMethod void basicTestSingleNoChildren() {
        Order__c a = TestData.quickcreateOrder();
        //insert a;

        OrderItem__c c = New OrderItem__c(OrderMdt__c = a.id, OrderQuantityNmb__c = 10);
        insert c;

        OrderClone.cloneObjectSingle(a.id,false);

        Order__c[] clonedOrder = [Select Name From Order__C Where ID != :a.id];

        system.assertEquals(1,clonedOrder.size(), 'More than one account was created');

        //Clear out the values that would never match
        a.id = null;
        clonedOrder[0].id = null;

        OrderItem__c[] newItem = [Select OrderQuantityNmb__c, OrderMdt__c From OrderItem__c Where ID != :c.id];

        system.assertEquals(true,newItem.isEmpty(),'A contact record was created when nochildren was set to false');

    }

    static testMethod void basicTestSingleWithChildren() {
        Order__c a = TestData.quickcreateOrder();
        //insert a;

        OrderItem__c c = New OrderItem__c(OrderMdt__c = a.id, OrderQuantityNmb__c = 10);
        insert c;

        OrderClone.cloneObjectSingle(a.id,true);

        Order__c[] clonedOrder = [Select Name From Order__C Where ID != :a.id];

        system.assertEquals(1,clonedOrder.size(), 'More than one account was created');        

        OrderItem__c[] newItem = [Select OrderQuantityNmb__c, OrderMdt__c From OrderItem__c Where ID != :c.id];

        system.assertEquals(1,newItem.size(),'No item record was created when nochildren was set to true');

        system.assertEquals(clonedOrder[0].id,newItem[0].OrderMdt__c,'The cloned Item OrderId was not set to the cloned Order ID');

    }

    static testMethod void basicTestWithChildrenExcludeContact() {
        Order__c a = TestData.quickcreateOrder();
        //insert a;

        OrderItem__c c = New OrderItem__c(OrderMdt__c = a.id, OrderQuantityNmb__c = 10);
        insert c;

        OrderClone.cloneObjectWithExclude(New Set<ID>{a.id},true,New Set<String>{'OrderItem__c'});

        Order__c[] clonedOrder = [Select Name From Order__C Where ID != :a.id];

        system.assertEquals(1,clonedOrder.size(), 'More than one account was created');
        
        
        OrderItem__c[] newItem = [Select OrderQuantityNmb__c, OrderMdt__c From OrderItem__c Where ID != :c.id];

        system.assertEquals(true,newItem.isEmpty(),'An item record was created when OrderItem__c was excluded');

    }


    static testMethod void noRecordsError(){
        OrderClone.cloneObjectSingle(null,false);
        system.assertEquals(OrderClone.NORECORDS,OrderClone.getErrorMessage());

        OrderClone.cloneObjectSet(New Set<ID>(), false);
        system.assertEquals(OrderClone.NORECORDS,OrderClone.getErrorMessage());

    }

    static testMethod void toManyTypesError(){

        Account a = New Account(Name = 'Test Account',BillingCity = 'Test City');
        insert a;

        Contact c = New Contact(LastName = 'Last', FirstName = 'First', AccountId = a.id);
        insert c;

        try {
            OrderClone.queryForRecords(New Set<ID>{a.id, c.id}, null);
            system.assertEquals(false,true,'An error (TOO MANY TYPES) was supposed to be thrown and caught, thus we should have never made it here');
        }catch(OrderClone.Object_Clone_Exception e) {
            system.assertEquals(OrderClone.TOMANYTYPES, e.getMessage());
        }


    }

    static testMethod void NoExclusionsSet(){

        system.assertNotEquals(null,OrderClone.excludedObjects, 'The Exclusion returned null when it should have been an empty list');
        system.assertEquals(true,OrderClone.excludedObjects.isEmpty(),'The Exclusions were not empty despite the setter not being executed');

    }

    //TODO - Bulk Tests
    static testmethod void bulkClone(){

    }

}