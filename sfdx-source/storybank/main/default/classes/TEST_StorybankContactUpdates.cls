@isTest
private with sharing class TEST_StorybankContactUpdates {
    
    @isTest
    private static void testUpdates_MVPFields () {
    
    TEST_DATA_Factory.setupStoryBankDefaults ();
    
    List<StorybankFieldsStoryteller__c> sb = new List<StorybankFieldsStoryteller__c> (); 
    sb.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Team_Source__c', Name='Team_Source__c',Display_Order__c=999));
    sb.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Experience_w_Media__c', Name='Experience_w_Media__c',Display_Order__c=999));
    sb.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Storyteller_Notes__c', Name='Storyteller_Notes__c',Display_Order__c=999));
    insert sb;
    
    List<StorybankFieldsStoryteller__c> sfields = [Select Name, Contact_object_fieldname__c 
                                                FROM StorybankFieldsStoryteller__c WHERE Contact_object_fieldname__c != null
                                                Order By Display_Order__c ASC NULLS LAST, Name ASC ];

    Contact teststoryc = TEST_DATA_Factory.createExistingStoryteller();
    //Set a Team Source
    teststoryc.Team_Source__c = null;
    
    Storybank_Submitted__c testws1 = TEST_DATA_Factory.createselfsubmission();
    testws1.Team_Source__c = null;
    
        List<StorybankContactUpdates> contactFieldUpdates = new List<StorybankContactUpdates> ();
        for (StorybankFieldsStoryteller__c s: sFields) {
            contactFieldUpdates.add( new StorybankContactUpdates(s.name, s.Contact_object_fieldname__c,testws1, teststoryc));
        }

        system.assertequals(null,teststoryc.Team_Source__c);
        system.assertequals(FALSE,teststoryc.Experience_w_Media__c);
        

        teststoryc = StorybankContactUpdates.setValuesonContact (teststoryc, testws1, contactFieldUpdates);
        system.assertequals(null,teststoryc.Team_Source__c);
        system.assertequals(TRUE,teststoryc.Experience_w_Media__c);
    

        teststoryc.Team_Source__c = 'Story 2';
    
        contactFieldUpdates = new List<StorybankContactUpdates> ();
        for (StorybankFieldsStoryteller__c s: sFields) {
            contactFieldUpdates.add( new StorybankContactUpdates(s.name, s.Contact_object_fieldname__c, testws1, teststoryc));
        }

        system.assertequals('Story 2',teststoryc.Team_Source__c);
        teststoryc = StorybankContactUpdates.setValuesonContact (teststoryc, testws1, contactFieldUpdates);
        system.assertequals('Story 2',teststoryc.Team_Source__c);

        testws1.Team_Source__c = 'Story 4';
    
        contactFieldUpdates = new List<StorybankContactUpdates> ();
        for (StorybankFieldsStoryteller__c s: sFields) {
            contactFieldUpdates.add( new StorybankContactUpdates(s.name, s.Contact_object_fieldname__c, testws1, teststoryc));
        }

        system.assertequals('Story 2',teststoryc.Team_Source__c);
        teststoryc = StorybankContactUpdates.setValuesonContact (teststoryc, testws1, contactFieldUpdates);
        system.assertequals('Story 2;Story 4',teststoryc.Team_Source__c);

        teststoryc.Team_Source__c = null;
        teststoryc.Storyteller_Notes__c = 'Test New Line';

        contactFieldUpdates = new List<StorybankContactUpdates> ();
        for (StorybankFieldsStoryteller__c s: sFields) {
            contactFieldUpdates.add( new StorybankContactUpdates(s.name, s.Contact_object_fieldname__c, testws1, teststoryc));
        }
        
        system.assertequals(null,teststoryc.Team_Source__c);
        system.assertequals('Test New Line' , teststoryc.Storyteller_Notes__c);
        
        teststoryc = StorybankContactUpdates.setValuesonContact (teststoryc, testws1, contactFieldUpdates);
        
        system.assertequals('Story 4',teststoryc.Team_Source__c);
        system.assertequals('Test New Line'  + '\n\n' + 'Test Notes + Test More Notes', teststoryc.Storyteller_Notes__c);
        
        //Text Area for Street
        testws1.Street_Address__c = 'Test Street 1';
        system.assertequals(null,teststoryc.MailingStreet);

        contactFieldUpdates = new List<StorybankContactUpdates> ();
        for (StorybankFieldsStoryteller__c s: sFields) {
            contactFieldUpdates.add( new StorybankContactUpdates(s.name, s.Contact_object_fieldname__c,testws1, teststoryc));
        }
        teststoryc = StorybankContactUpdates.setValuesonContact (teststoryc, testws1, contactFieldUpdates);
        system.assertequals('Test Street 1',teststoryc.MailingStreet);

        testws1.Street_Address__c = 'Test Street 2';
        
        contactFieldUpdates = new List<StorybankContactUpdates> ();
        for (StorybankFieldsStoryteller__c s: sFields) {
            contactFieldUpdates.add( new StorybankContactUpdates(s.name, s.Contact_object_fieldname__c, testws1, teststoryc));
        }
         teststoryc = StorybankContactUpdates.setValuesonContact (teststoryc, testws1, contactFieldUpdates);
        system.assertequals('Test Street 2',teststoryc.MailingStreet);


    }
}