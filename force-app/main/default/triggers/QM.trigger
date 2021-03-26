trigger QM on QM__c (after insert, before insert, before update) {
    new THQM().run();
}