public class LocationCallouts {
    /*
    @future (callout=true)  // future method needed to run callouts from Triggers
    static public void getLocation(List<Id> accIdList) {
        List<Account> accsToUpdate = new List<Account>();
        
        List<Account> accList = [   SELECT Id,
                                 BillingCity,
                                 BillingCountry,
                                 BillingPostalCode,
                                 BillingState,
                                 BillingStreet,
                                 AddressCoordinates__Latitude__s
                                 FROM Account 
                                 WHERE Id IN :accIdList];
        
        for (Account a : accList) {
            // create an address string
            String address = '';
            
            if (a.BillingStreet != null)
                address += a.BillingStreet +', ';
            if (a.BillingCity != null)
                address += a.BillingCity +', ';
            if (a.BillingState != null)
                address += a.BillingState +' ';
            if (a.BillingPostalCode != null)
                address += a.BillingPostalCode +', ';
            if (a.BillingCountry != null)
                address += a.BillingCountry;
            
            address = EncodingUtil.urlEncode(address, 'UTF-8');
            
            // build callout
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('http://maps.googleapis.com/maps/api/geocode/json?address='+address+'&sensor=false');
            req.setMethod('GET');
            req.setTimeout(60000);
            
            try {
                // callout
                HttpResponse res = h.send(req);
                
                // parse coordinates from response
                JSONParser parser = JSON.createParser(res.getBody());
                double lat = null;
                double lon = null;
                while (parser.nextToken() != null) {
                    if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                        (parser.getText() == 'location') ) {
                            system.debug('enter location');
                            parser.nextToken(); // object start
                            while (parser.nextToken() != JSONToken.END_OBJECT) {
                                String txt = parser.getText();
                                system.debug('txt: ' + txt);
                                parser.nextToken();
                                if (txt == 'lat')
                                    lat = parser.getDoubleValue();
                                else if (txt == 'lng')
                                    lon = parser.getDoubleValue();
                            }
                            
                        }
                }
                
                // update coordinates if we get back
                if (lat != null) {
                    a.AddressCoordinates__Latitude__s = lat;
                    a.AddressCoordinates__Longitude__s = lon;
                    accsToUpdate.add(a);
                    //update a;
                    System.debug(a);
                }
                
            } catch (Exception e) {
                System.debug(e.getMessage());
                return;
            }
        }
        
        
        
        System.debug(accsToUpdate);
        
        if (accsToUpdate.size() > 0)
            update accsToUpdate;
        //update accList;
        //
    }
*/
}