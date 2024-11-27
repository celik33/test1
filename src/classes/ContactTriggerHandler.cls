public with sharing class ContactTriggerHandler {
    private static Boolean isExecuting = false;

    public static void afterUpdate(List<Contact> contacts, Map<Id, Contact> oldMap) {
        if(isExecuting) return;
        isExecuting = true;

        Set<Id> accountIds = new Set<Id>();
        Map<Id, Boolean> accountActivationStatus = new Map<Id, Boolean>();

        for(Contact contact : contacts){
            if(contact.Activated__c != oldMap.get(contact.Id).Activated__c && contact.AccountId != null){
                accountIds.add(contact.AccountId);
                accountActivationStatus.put(contact.AccountId, contact.Activated__c);
            }
        }

        if(accountIds.isEmpty()) {
            isExecuting = false;
            return;
        }

        List<Account> accountsToUpdate = [SELECT Id, Activated__c, (SELECT Id, Activated__c FROM Contacts) FROM Account WHERE Id IN :accountIds];

        for(Account acc : accountsToUpdate){
            Boolean newStatus = accountActivationStatus.get(acc.Id);
            if(acc.Activated__c != newStatus) {
                acc.Activated__c = newStatus;

                for(Contact con : acc.Contacts){
                    con.Activated__c = newStatus;
                }
                update acc.Contacts;
            }
        }
        update accountsToUpdate;
        isExecuting = false;
    }
}
