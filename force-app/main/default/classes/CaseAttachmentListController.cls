public class CaseAttachmentListController {

    public Case c {get;set;}
    public Attachment attachment{
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
        }
        set;
    }
    
    public CaseAttachmentListController(ApexPages.StandardController controller){
        this.c = (Case) controller.getRecord();
    }
    
    public PageReference upload() {
        
        attachment.OwnerId = System.UserInfo.getUserId();
        attachment.ParentId = c.Id; // the record the file is attached to
        attachment.IsPrivate = true;
        
        try {
            insert attachment;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Ocorreu um erro durante o carregamento do arquivo.'));
            return null;
        } finally {
            attachment = new Attachment(); 
        }
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'O arquivo foi carregado com sucesso!'));
        return new PageReference('/' + c.Id);
    }
    
}