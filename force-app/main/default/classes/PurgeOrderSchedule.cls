global class PurgeOrderSchedule implements Schedulable {

	public static final String CRON_STR = '0 0 1 * * ?';

	public static void scheduleJob(){
		System.schedule('Purge order data every first day of month', CRON_STR, new PurgeOrderSchedule());
	}

	global void execute(SchedulableContext sc) {
		PurgeOrderBatch b = new PurgeOrderBatch();
		Database.executebatch(b, 200);
	}

}