@isTest
private class ContactTriggerHandlerTest {

    // Utility method to create an Account
    private static Account createTestAccount(Boolean isActivated) {
        Account acc = new Account(Name = 'Test Account', Activated__c = isActivated);
        insert acc;
        return acc;
    }

    // Utility method to create a Contact
    private static Contact createTestContact(Id accountId, Boolean isActivated) {
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = accountId, Activated__c = isActivated);
        insert con;
        return con;
    }

    // Test activation scenario
    @isTest static void testActivateContact() {
        // Step 1: Create a deactivated account and contact
        Account acc = createTestAccount(false);
        Contact con = createTestContact(acc.Id, false);

        // Step 2: Update the contact to activate it
        con.Activated__c = true;
        update con;

        // Step 3: Retrieve the updated account and contact records
        Account updatedAcc = [SELECT Activated__c FROM Account WHERE Id = :acc.Id];
        Contact updatedCon = [SELECT Activated__c FROM Contact WHERE Id = :con.Id];

        // Step 4: Assertions to verify that both account and contact are activated
        System.assertEquals(true, updatedAcc.Activated__c, 'The account should be activated.');
        System.assertEquals(true, updatedCon.Activated__c, 'The contact should be activated.');
    }

    // Test deactivation scenario
    @isTest static void testDeactivateContact() {
        // Step 1: Create an activated account and contact
        Account acc = createTestAccount(true);
        Contact con = createTestContact(acc.Id, true);

        // Step 2: Update the contact to deactivate it
        con.Activated__c = false;
        update con;

        // Step 3: Retrieve the updated account and contact records
        Account updatedAcc = [SELECT Activated__c FROM Account WHERE Id = :acc.Id];
        Contact updatedCon = [SELECT Activated__c FROM Contact WHERE Id = :con.Id];

        // Step 4: Assertions to verify that both account and contact are deactivated
        System.assertEquals(false, updatedAcc.Activated__c, 'The account should be deactivated.');
        System.assertEquals(false, updatedCon.Activated__c, 'The contact should be deactivated.');
    }

    // Test multiple contacts affecting the same account
    @isTest static void testMultipleContactsUpdate() {
        // Step 1: Create a deactivated account and multiple contacts
        Account acc = createTestAccount(false);
        Contact con1 = createTestContact(acc.Id, false);
        Contact con2 = createTestContact(acc.Id, false);

        // Step 2: Update one contact to activate it
        con1.Activated__c = true;
        update con1;

        // Step 3: Retrieve updated account and contacts
        Account updatedAcc = [SELECT Activated__c FROM Account WHERE Id = :acc.Id];
        List<Contact> updatedContacts = [SELECT Activated__c FROM Contact WHERE AccountId = :acc.Id];

        // Step 4: Assertions to verify that the account and both contacts are activated
        System.assertEquals(true, updatedAcc.Activated__c, 'The account should be activated.');
        for (Contact con : updatedContacts) {
            System.assertEquals(true, con.Activated__c, 'All contacts should be activated.');
        }
    }

    // Test for no updates when Activated__c field is unchanged
    @isTest static void testNoChangeInActivatedStatus() {
        // Step 1: Create an activated account and contact
        Account acc = createTestAccount(true);
        Contact con = createTestContact(acc.Id, true);

        // Step 2: Update contact without changing the Activated__c field
        con.FirstName = 'Updated Test';
        update con;

        // Step 3: Retrieve the updated contact and account
        Account updatedAcc = [SELECT Activated__c FROM Account WHERE Id = :acc.Id];
        Contact updatedCon = [SELECT FirstName, Activated__c FROM Contact WHERE Id = :con.Id];

        // Step 4: Assertions to verify no change in activation status
        System.assertEquals(true, updatedAcc.Activated__c, 'The account should remain activated.');
        System.assertEquals('Updated Test', updatedCon.FirstName, 'The contact name should be updated.');
        System.assertEquals(true, updatedCon.Activated__c, 'The contact activation status should remain unchanged.');
    }
}
