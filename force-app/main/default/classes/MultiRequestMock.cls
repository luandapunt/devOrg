@isTest
public class MultiRequestMock implements HttpCalloutMock {
    Map<String, StaticResourceCalloutMock> requests;

    public MultiRequestMock(Map<String, StaticResourceCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        List<String> splitEndpoint = req.getEndpoint().split('/');
        system.debug('splitEndpoint: ' + splitEndpoint);
        StaticResourceCalloutMock mock = requests.get(splitEndpoint[splitEndpoint.size() - 2]);
        if (mock != null) {
            return mock.respond(req);
        }
        else return new HttpResponse();
    }

    public void addRequestMock(String url, StaticResourceCalloutMock mock) {
        requests.put(url, mock);
    }
}