public class SellerDocumentsController {

    @AuraEnabled
    public static List<Document> getDocumentList(Id userId){
        List<Seller__c> listSeller = [SELECT Id, SellerNumberNmb__c FROM Seller__c WHERE UserLkp__c =: userId];
        if(listSeller.isEmpty()) return null;
        List<String> sellerNumbers = new List<String>();
        for(Seller__c s : listSeller){
            sellerNumbers.add(s.SellerNumberNmb__c.leftPad(8, '0') + '%');
        }
        system.debug(sellerNumbers);
        List<Document> listDocs = [SELECT Id, Name, URL FROM Document WHERE Name LIKE :sellerNumbers AND Folder.DeveloperName = 'SellerFiles'];
        return listDocs;
    }
    
    @AuraEnabled
    public static String deleteDocument(Id docId){
        try{
            delete new Document(Id = docId);
            return 'SUCCESS';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    
}