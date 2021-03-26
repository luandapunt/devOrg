/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Get, Upsert and Delete relevent sObject declared in the Lightning and Community Builder
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Randy Grewal   <rgrewal@salesfore.com>
* @modifiedBy     Randy Grewal   <rgrewal@salesfore.com>
* @maintainedBy   Randy Grewal   <rgrewal@salesfore.com>
* @version        1.1
* @created        2017-05-01
* @modified       2017-06-12
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            rgrewal@salesfore.com
* 2017-06-08     	Added option to filter query by logged in user and removed System.debug logs
* 2017-06-12		Security Review Fixes:
*					Added isAccessible(), isCreateable(), isDeletable() for CRUD/FLS Enforcement fix
*					Added Typecasting to all injected field API names for SOQL Injection fix
*					Added "with sharing" keyword to Class for Sharing Violation Fix
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public with sharing class AnyEventCalCtrl {
    @AuraEnabled
    public static List<EventObj> getEvents(String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String userField, String targetField, String targetName, Boolean filterByUserField){
        String q = 'SELECT Id,' + 
            String.valueOf(titleField) + ',' + 
            String.valueOf(startDateTimeField) + ',' +
            String.valueOf(endDateTimeField) + ',' +
            String.valueOf(descriptionField) + ',' +            
            String.valueOf(targetField) + ',' + 
            String.valueOf(targetName) + ',' + 
            String.valueOf(userField) + ' FROM ' + 
            String.valueOf(sObjectName) + ' WHERE ' + 
            String.valueOf(userField) + ' = \'' + UserInfo.getUserId() + '\' AND ' +
            String.valueOf(targetField) + ' != null';
        if (!filterByUserField) {
            q = 'SELECT Id,' + 
                String.valueOf(titleField) + ',' + 
                String.valueOf(startDateTimeField) + ',' +
                String.valueOf(endDateTimeField) + ',' +
                String.valueOf(descriptionField) + ',' +  
                String.valueOf(targetField) + ',' + 
                String.valueOf(targetName) + ',' + 
                String.valueOf(userField) + ' FROM ' + 
                String.valueOf(sObjectName);
        } 
        
        
        
        String parentObject = targetName.split('\\.')[0];
        String objectField = targetName.split('\\.')[1];
        
        List<sObject> sObjectList = Database.query(q);
        List<EventObj> eventRecords = new List<EventObj>();
        if(isAccessible(sObjectName)) {
            for (sObject obj : sObjectList) {
                system.debug(obj.getSObject(parentObject));
                if(obj.getSObject(parentObject) != null){
                    EventObj newEv = new EventObj(obj.Id,
                                                  String.valueOf(obj.get(titleField)),
                                                  DateTime.valueOf(obj.get(startDateTimeField)),
                                                  DateTime.valueOf(obj.get(endDateTimeField)),
                                                  String.valueOf(obj.get(descriptionField)),                                              
                                                  String.valueOf(obj.get(userField)),
                                                  String.valueOf(obj.get(targetField)),
                                                  String.valueOf(obj.getSObject(parentObject).get(objectField))
                                                 );
                    eventRecords.add(newEv);
                    system.debug('ev.Name: ' + newEv.whatName);
                }
            }
        }
        return eventRecords;
    }
    @AuraEnabled
    public static EventObj upsertEvents(String sEventObj, String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String userField, String targetField){
        EventObj upsertingEvent = (EventObj)JSON.deserialize(sEventObj, EventObj.class);
        sObject newRecord = Schema.getGlobalDescribe().get(sObjectName).newSObject(); 
        String whatName = upsertingEvent.whatName;
        if (upsertingEvent.Id != null && isAccessible(sObjectName,'Id')){
            newRecord.put('Id',upsertingEvent.Id);
        } 
        if (isAccessible(sObjectName,titleField)) {
            newRecord.put(titleField, upsertingEvent.title);
        }
        if (isAccessible(sObjectName,startDateTimeField)) {
            newRecord.put(startDateTimeField, upsertingEvent.startDateTime);
        }
        if (isAccessible(sObjectName,endDateTimeField)) {
            newRecord.put(endDateTimeField, upsertingEvent.endDateTime);
        }
        if (isAccessible(sObjectName,descriptionField)) {
            newRecord.put(descriptionField, upsertingEvent.description);
        }
        if(isAccessible(sObjectName, targetField)){
            newRecord.put(targetField, upsertingEvent.whatId);
        }
        
        
        try {
            upsert newRecord;
            system.debug(newRecord);
            EventObj newEv = new EventObj(newRecord.Id,
                                          String.valueOf(newRecord.get(titleField)),
                                          DateTime.valueOf(newRecord.get(startDateTimeField)),
                                          DateTime.valueOf(newRecord.get(endDateTimeField)),
                                          String.valueOf(newRecord.get(descriptionField)),                                  
                                          String.valueOf(newRecord.get(userField)),
                                          String.valueOf(newRecord.get(targetField)),
                                          whatName
                                 );
            return newEv;
        } catch (Exception e) {
            throw new AuraHandledException('Erro ao inserir o registro');
            return null;
        }
        
    }
    @AuraEnabled
    public static String deleteEvent(String eventId, String sObjectName, String titleField, String startDateTimeField, String endDateTimeField, String descriptionField, String userField, String targetField, String targetName){
        String q = 'SELECT Id,' + 
                titleField + ',' + 
                startDateTimeField + ',' +
                endDateTimeField + ',' +
                descriptionField + ',' +  
            	targetField + ',' + targetName + ',' + 
                userField + ' FROM ' + 
                sObjectName + ' WHERE Id = \'' + eventId  + '\'';
        List<sObject> sObjectList = Database.query(q);
        try {
            if(isDeletable(sObjectName)) {
                delete sObjectList;
            }
            return eventId;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
        
    }
    public class EventObj {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public DateTime startDateTime {get;set;}
        @AuraEnabled
        public DateTime endDateTime {get;set;}
        @AuraEnabled
        public String description {get;set;}        
        @AuraEnabled
        public String owner {get;set;}
        @AuraEnabled
        public String whatId {get;set;}
        @AuraEnabled
        public String whatName {get;set;}

        
        public EventObj(String i,String t, DateTime s, DateTime e, String d, String o, String w, String n){
            this.Id = i;
            this.title = t;
            this.startDateTime = s;
            this.endDateTime = e;
            this.description = d;            
            this.owner = o;
            this.whatId = w;
            this.whatName = n;
        }
        
    }
    public static Boolean isAccessible(String sObjectType, String fieldName){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldName).getDescribe();
        return fieldDescribe.isAccessible();
    }
    public static Boolean isAccessible(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isAccessible();
    }
    public static Boolean isCreateable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isCreateable();
    }
    public static Boolean isDeletable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isDeletable();
    }
}