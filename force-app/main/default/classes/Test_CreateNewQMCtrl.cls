@istest
public class Test_CreateNewQMCtrl {
    
    @istest static void testGetCaso(){
        
        Case caso = TestData.quickCreateCase();
        
        Test.startTest();
        System.assertEquals(CreateNewQMCtrl.getcaso(caso.Id).id, caso.id);
        Test.stopTest();
    }
    
    @istest static void testGetQM(){
        
        Case caso = TestData.quickCreateCase();
        
        Test.startTest();
        System.assertNotEquals(CreateNewQMCtrl.getqm(caso.id), null);
        Test.stopTest();
    }
    
    @istest static void testGetOrder(){
        
        Case caso = TestData.quickCreateCase();
        
        Test.startTest();
        System.assertNotEquals(CreateNewQMCtrl.getorder(caso.id), null);
        Test.stopTest();
    }
    
    @istest static void testGetOrderDev(){
        
        Order__c ord = TestData.quickCreateOrder();
        
        Order__c orderdev = [
            
            SELECT Name
            FROM Order__c
            WHERE id = :ord.id
            LIMIT 1
        ];
        
        Test.startTest();
        System.assertNotEquals(CreateNewQMCtrl.getorderdev(orderdev.Name), null);
        Test.stopTest();
    }
    
    @istest static void testGetCaseItem(){
        
        Case caso = TestData.quickCreateCase();
        
        Test.startTest();
        System.assertNotEquals(CreateNewQMCtrl.getcaseitem(caso.id), null);
        Test.stopTest();
    }
   
    @istest static void testGetOrderNRO(){
        
        Order__c ord = TestData.quickCreateOrder();
        
        Test.startTest();
        System.assertNotEquals(CreateNewQMCtrl.getorderNRO(ord.id), null);
        Test.stopTest();
    }
    
    @istest static void testGetRecordType(){
        
		//Case caso = TestData.quickCreateCase(); 
                
        Test.startTest();
        System.assertNotEquals(CreateNewQMCtrl.getqmrecordtype(), null);
        Test.stopTest();
    }
    
}