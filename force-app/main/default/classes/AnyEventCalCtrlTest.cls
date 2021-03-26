@isTest(seeAllData=true)
public class AnyEventCalCtrlTest {
	static testMethod void getEventsTest() {
        AnyEventCalCtrl.getEvents('Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'OwnerId', 'WhatId', 'What.Name', true);
        AnyEventCalCtrl.getEvents('Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'OwnerId', 'WhatId', 'What.Name', false);
    }
    static testMethod void upsertEventsTest() {
        AnyEventCalCtrl.upsertEvents('{"title":"dasdsad","startDateTime":"2017-04-26T15:00:00-03:00","endDateTime":"2017-04-26T17:00:00-03:00","description":"asdasd", "whatName":"asdasd"}', 'Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'OwnerId', 'WhatId');
        //AnyEventCalCtrl.upsertEvents('{"title":"dasdsad","startDateTime":"2017-04-26T17:00:00-07:00","endDateTime":"2017-04-26T19:00:00-07:00","description":"asdasd", "whatName":"asdasd"}', 'Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'OwnerId', 'WhatId');
    	//AnyEventCalCtrl.upsertEvents('{"id":"sadad","title":"dasdsad","startDateTime":"2017-04-26T17:00:00-07:00","endDateTime":"2017-04-26T19:00:00-07:00","description":"asdasd", "whatName":"asdasd"}', 'Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'OwnerId', 'WhatId');
    }
    static testMethod void deleteEventTest() {
        AnyEventCalCtrl.deleteEvent('00U41000006bFIA', 'Event', 'Subject', 'StartDateTime', 'EndDateTime', 'Description', 'OwnerId', 'WhatId', 'What.Name');
    }
    static testMethod void crudSecurityTest() {
        AnyEventCalCtrl.isAccessible('Event');
        AnyEventCalCtrl.isAccessible('Event','Subject');
        AnyEventCalCtrl.isCreateable('Event');
        AnyEventCalCtrl.isDeletable('Event');
    }
}