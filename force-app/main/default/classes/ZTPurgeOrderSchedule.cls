@isTest
public class ZTPurgeOrderSchedule {

	@isTest
	public static void deleteScenary(){
		Test.startTest();
		PurgeOrderSchedule.scheduleJob();
		Test.stopTest();
	}

}