/*
    Rotinas de limpeza:
    PurgeOrderItemSchedule + PurgeOrderItemBatch
    PurgeOrderSchedule + PurgeOrderBatch
    PurgeInvoiceSchedule + PurgeInvoiceBatch
    PurgeOrderRemittanceSchedule + PurgeOrderRemittanceBatch
    
    Data: 03/02/2017
    Dev: Carlos Diogo de Oliveira
    Caso: 00025639
*/
global class Schedule_RemittanceItem implements Schedulable{
    
  public static final String CRON_STR = '0 0 1 * * ?';

  public static void scheduleJob(){
    System.schedule('Purge RemittanceItem data every first day of month', CRON_STR, new Schedule_RemittanceItem());
  }

  global void execute(SchedulableContext sc) {
    Batch_RemittanceItem b = new Batch_RemittanceItem();
    Database.executebatch(b, 200);
  }
}