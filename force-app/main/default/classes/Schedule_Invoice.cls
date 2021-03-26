/*
    Rotinas de limpeza:
    PurgeOrderItemSchedule + PurgeOrderItemBatch
    PurgeOrderSchedule + PurgeOrderBatch
    PurgeInvoiceSchedule + PurgeInvoiceBatch
    PurgeOrderRemittanceSchedule + PurgeOrderRemittanceBatch
    
    Data: 23/01/2017
    Dev: Renata
    Caso: 00025639
*/
global class Schedule_Invoice implements Schedulable {

  public static final String CRON_STR = '0 0 1 * * ?';

  public static void scheduleJob(){
    System.schedule('Purge Invoice data every first day of month', CRON_STR, new Schedule_Invoice());
  }

  global void execute(SchedulableContext sc) {
    Batch_Invoice b = new Batch_Invoice();
    Database.executebatch(b, 200);
  }

}