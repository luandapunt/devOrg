public class UpdateOrderAsync implements Queueable, Database.AllowsCallouts {
    
    public final String orderCode;
    
    public void execute(QueueableContext context){
        OrderService.getInvoiceListByOrderNumber(orderCode);
    }
    
    public UpdateOrderAsync(String orderCode){
        this.orderCode = orderCode;
    }
}