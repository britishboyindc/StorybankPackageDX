@isTest
public with sharing class TEST_lwcUtils {
    @testSetup static void setup() {
        List<StorybankFieldsStoryteller__c> newlist = new List<StorybankFieldsStoryteller__c>();
        newlist.add(new StorybankFieldsStoryteller__c(Name = 'FirstName', Contact_object_fieldname__c = 'First_Name__c'));
        newlist.add(new StorybankFieldsStoryteller__c(Name = 'LastName', Contact_object_fieldname__c = 'Last_Name__c'));
        newlist.add(new StorybankFieldsStoryteller__c(Name = 'Email', Contact_object_fieldname__c = 'Email_Address__c'));
        newlist.add(new StorybankFieldsStoryteller__c(Name = 'Age_range__c', Contact_object_fieldname__c = 'Age_range__c'));
        newlist.add(new StorybankFieldsStoryteller__c(Name = 'MailingStreet', Contact_object_fieldname__c = 'Street_Address__c'));
        insert newlist;
        List<StorybankFieldsNominator__c> newNominlist = new List<StorybankFieldsNominator__c>();
        newNominlist.add(new StorybankFieldsNominator__c(Name = 'FirstName', Contact_object_fieldname__c = 'Nominator_First__c'));
        newNominlist.add(new StorybankFieldsNominator__c(Name = 'LastName', Contact_object_fieldname__c = 'Nominator_Last_Name__c'));
        newNominlist.add(new StorybankFieldsNominator__c(Name = 'Email', Contact_object_fieldname__c = 'Nominator_Email_Address__c'));
        insert newNominlist;
        List<Storybank_Fields_Nominator_Org__c> newNomOrg = new List<Storybank_Fields_Nominator_Org__c>();
        newNomOrg.add(new Storybank_Fields_Nominator_Org__c(Name = 'Name', Storybank_Submitted_Nominator_Org_Field__c = 'Nominator_Organization__c', Display_Order__c = 100));
        insert newNomOrg;
        Contact newStorytellerContact = new Contact(FirstName = 'StorytellerFirstName', LastName = 'StorytellerLastName', Email = 'storytelleremail@email.com');
        insert newStorytellerContact;
        Contact newNominatorContact = new Contact(FirstName = 'NominatorFirstName', LastName = 'NominatorLastName', Email = 'nominatoremail@email.com');
        insert newNominatorContact;
        Storybank_Submitted__c newStorySubmitted = new Storybank_Submitted__c(First_Name__c = 'testFirstName', Last_Name__c = 'testLastName', Email_Address__c = 'email@email.com');
        insert newStorySubmitted;
    }
    @IsTest
    static void createContactTEST() {
        Contact newCont = new Contact(FirstName = 'testFirstName', LastName = 'testLastName', Email = 'email@email.com');
        newCont = lwcUtils.createContact(newCont);
        System.assertNotEquals(newCont.Id, null);
        Contact insertedContact = [SELECT Id FROM Contact WHERE Email = 'email@email.com' LIMIT 1];
        System.assertNotEquals(insertedContact, null);
    }
    @IsTest
    static void createAccountTEST() {
        Account acc = new Account(Name = 'Acc');
        acc = lwcUtils.createAccount(acc);
        System.assertNotEquals(acc.Id, null);
        Account insertedAcc = [SELECT Id FROM Account WHERE Name = 'Acc' LIMIT 1];
        System.assertNotEquals(insertedAcc, null);
    }
    @IsTest
    static void getRecordTEST() {
        Storybank_Submitted__c newStory = new Storybank_Submitted__c(First_Name__c = 'testFirstName1', Last_Name__c = 'testLastName1', Email_Address__c = 'email1@email.com');
        insert newStory;
        Storybank_Submitted__c story = lwcUtils.getRecord(newStory.Id);
        System.assertEquals(story.First_Name__c, 'testFirstName1');
        System.assertEquals(story.Last_Name__c, 'testLastName1');
        System.assertEquals(story.Email_Address__c, 'email1@email.com');
        Storybank_Submitted__c story2 = lwcUtils.getRecord(null);
        System.assertEquals(story2, null);
    }
    @IsTest
    static void getContactTEST() {
        List<Contact> ExContact = lwcUtils.getContact('Email', 'storytelleremail@email.com');
        System.assertEquals(!ExContact.isEmpty(), true);
    }
    @IsTest
    static void fillWrapperTEST() {
        List<Object> wrapper = lwcUtils.fillWrapper('Storyteller', null, null);
        System.assertNotEquals(wrapper.isEmpty(), true);
        System.assertEquals(wrapper.size(), 5);
        fillWrapperHELPER(wrapper);
        wrapper = lwcUtils.fillWrapper('Nominator', null, null);
        System.assertEquals(wrapper.size(), 3);
        System.assertNotEquals(wrapper.isEmpty(), true);
        fillWrapperHELPER(wrapper);
        Storybank_Submitted__c sr = [SELECT Id, First_Name__c FROM Storybank_Submitted__c WHERE Email_Address__c = 'email@email.com' LIMIT 1];
        Contact contact = [SELECT Id, FirstName FROM Contact WHERE Email = 'storytelleremail@email.com' LIMIT 1];
        wrapper = lwcUtils.fillWrapper('Storyteller', sr.Id, contact.Id);
        fillWrapperHELPER(wrapper);
        wrapper = lwcUtils.fillWrapper('Nominator', sr.Id, contact.Id);
        fillWrapperHELPER(wrapper);
    }
    static void fillWrapperHELPER(List<Object> wrapper) {
        for (Object o : wrapper) {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
            System.assertNotEquals(m.get('selectedAction'), null);
            if (m.get('currentContactField') == 'MailingStreet') {
                String s = String.valueof(m.get('action'));
                List<String> actions = s.split('},');
                System.assertEquals(actions.size(), 3);
            }
        }
    }
    @IsTest
    static void getfieldlabelTEST() {
        String s = lwcUtils.getfieldlabel('FirstName');
        System.assertEquals(s, 'First Name');
    }
    @IsTest
    static void updateContactButtonANDcreateNewStoryApprovedTEST() {
        insert new Storybank_Map_Submitted_Approved__c(Name = 'storybank__Storybank_Name__c', Storybank_Submitted_Story_Field__c = 'storybank__Storybank_Name__c');
        Account acc = new Account(Name = 'Test');
        insert acc;
        Contact storyteller = [SELECT Id, FirstName FROM Contact WHERE Email = 'storytelleremail@email.com' LIMIT 1];
        Contact nominator = [SELECT Id, FirstName FROM Contact WHERE Email = 'nominatoremail@email.com' LIMIT 1];
        Storybank_Submitted__c submittedRecord = [SELECT Id, First_Name__c FROM Storybank_Submitted__c WHERE Email_Address__c = 'email@email.com' LIMIT 1];
        Contact stclone = [SELECT Id, FirstName FROM Contact WHERE Email = 'storytelleremail@email.com' LIMIT 1];
        stclone.FirstName = 'UpdatedStorytellerFirstName';
        Storybank_Submitted__c srclone = [SELECT Id, First_Name__c FROM Storybank_Submitted__c WHERE Email_Address__c = 'email@email.com' LIMIT 1];
        srclone.First_Name__c = 'UpdatedSubmittedStoryFirstName';
        String idStoryApproved = lwcUtils.updateContactButton(stclone, srclone, null, null);
        Contact updatedStoryteller = [SELECT Id, FirstName FROM Contact WHERE Email = 'storytelleremail@email.com' LIMIT 1];
        Storybank_Submitted__c updatedSubmittedRecord = [SELECT Id, First_Name__c FROM Storybank_Submitted__c WHERE Email_Address__c = 'email@email.com' LIMIT 1];
        System.assertNotEquals(storyteller.FirstName, updatedStoryteller.FirstName);
        System.assertNotEquals(submittedRecord.First_Name__c, updatedSubmittedRecord.First_Name__c);
        idStoryApproved = lwcUtils.updateContactButton(nominator, submittedRecord, storyteller.Id, acc.Id);
        Storybank_Approved__c createdStoryApproved = [SELECT Id, Nominating_Organization__c FROM Storybank_Approved__c WHERE Submitter__c = :nominator.Id AND Storyteller__c = :storyteller.Id];
        System.assertEquals(createdStoryApproved.Id, idStoryApproved);
        System.assertEquals(createdStoryApproved.Nominating_Organization__c, acc.Id);
        updatedSubmittedRecord = [SELECT Id, Status__c FROM Storybank_Submitted__c WHERE Email_Address__c = 'email@email.com' LIMIT 1];
        System.assertEquals(updatedSubmittedRecord.Status__c, 'Converted');
    }
    @IsTest
    static void fieldsForConversionTEST() {
        Schema.FieldSet fs1;
        List<String> nominatorfieldsForConversion = lwcUtils.fieldsForConversion('nominator');
        fs1 = Schema.SObjectType.Storybank_Submitted__c.fieldSets.Nominator_Fields_for_Conversion;
        List<String> fields = new List<String>();
        for (Schema.FieldSetMember s : fs1.getFields()) {
            fields.add(s.getFieldPath());
        }
        System.assertEquals(fields, nominatorfieldsForConversion);
        List<String> storytellerfieldsForConversion = lwcUtils.fieldsForConversion('storyteller');
        fs1 = Schema.SObjectType.Storybank_Submitted__c.fieldSets.Submitted_Storyteller_Information;
        fields.clear();
        for (Schema.FieldSetMember s : fs1.getFields()) {
            fields.add(s.getFieldPath());
        }
        System.assertEquals(fields, storytellerfieldsForConversion);
        List<String> nomOrgFieldsForConversion = lwcUtils.fieldsForConversion('nominatorOrg');
        fs1 = Schema.SObjectType.Storybank_Submitted__c.fieldSets.Nominator_Org_Fields_for_Submission;
        fields.clear();
        for (Schema.FieldSetMember s : fs1.getFields()) {
            fields.add(s.getFieldPath());
        }
        System.assertEquals(fields, nomOrgFieldsForConversion);
    }
    @IsTest
    static void getCurrentNominatorValuesTEST() {
        Storybank_Submitted__c submittedRecord = [SELECT Id, First_Name__c FROM Storybank_Submitted__c WHERE Email_Address__c = 'email@email.com' LIMIT 1];
        Map<String, String> m = lwcUtils.getCurrentNominatorValues(submittedRecord.Id, 'nominatorCreatePage');
        getCurrentNominatorValuesHELPER(m, 3, 'Contact');
        m = lwcUtils.getCurrentNominatorValues(submittedRecord.Id, 'nominatorUpdatePage');
        getCurrentNominatorValuesHELPER(m, 4, 'Storybank_Submitted__c');
        System.assertEquals(submittedRecord.Id, m.get('Id'));
        m = lwcUtils.getCurrentNominatorValues(submittedRecord.Id, 'nominatorOrganization');
        getCurrentNominatorValuesHELPER(m, 1, 'Storybank_Submitted__c');
    }
    static void getCurrentNominatorValuesHELPER(Map<String, String> m, Integer count, String objectApi) {
        Schema.DescribeSObjectResult r;
        if (objectApi == 'Contact') {
            r = Contact.sObjectType.getDescribe();
        } else if (objectApi == 'Storybank_Submitted__c') {
            r = Storybank_Submitted__c.sObjectType.getDescribe();
        }
        List<String>apiNames = new list<String>();
        for (string apiName : r.fields.getMap().keySet()) {
            apiNames.add(apiName);
        }
        Integer counter = 0;
        for (String s : m.keySet()) {
            for (String ss : apiNames) {
                if (s == ss) {
                    counter++;
                }
            }
        }
        System.assertEquals(m.keySet().size(), count);
        System.assertEquals(counter, count);
    }
    @IsTest
    static void getSubmittedFieldsTEST() {
        insert new Storybank_Map_Submitted_Approved__c(Name = 'storybank__Storybank_Name__c', Storybank_Submitted_Story_Field__c = 'storybank__Storybank_Name__c');
        List<String> s = lwcUtils.getSubmittedFields(storybank__Storybank_Map_Submitted_Approved__c.getall().values());
        System.assertEquals(s[0], 'storybank__Storybank_Name__c');
    }
    @IsTest
    static void getNominatorOrgSubmittedFieldsTEST() {
        List<String> s = lwcUtils.getNominatorOrgSubmittedFields(Storybank_Fields_Nominator_Org__c.getall().values());
        System.assertEquals(s[0], 'Nominator_Organization__c');
    }
    @IsTest
    static void getNominatorContactSubmittedFieldsTEST() {
        List<String> s = lwcUtils.getNominatorContactSubmittedFields(StorybankFieldsNominator__c.getall().values());
        System.assertEquals(s[0], 'Nominator_First__c');
        System.assertEquals(s[1], 'Nominator_Last_Name__c');
        System.assertEquals(s[2], 'Nominator_Email_Address__c');
    }
    @IsTest
    static void getStorytellerSubmittedFieldsTEST() {
        List<String> s = lwcUtils.getStorytellerSubmittedFields(StorybankFieldsStoryteller__c.getall().values());
        System.assertEquals(s[0], 'First_Name__c');
        System.assertEquals(s[1], 'Last_Name__c');
        System.assertEquals(s[2], 'Email_Address__c');
        System.assertEquals(s[3], 'Age_range__c');
        System.assertEquals(s[4], 'Street_Address__c');
    }
    @IsTest
    static void getAccountTEST() {
        insert new Account(Name = 'NAME');
        List<Account> accs = lwcUtils.getAccount('NAME');
        System.assertEquals(accs.isEmpty(), false);
        System.assertEquals(accs[0].Name, 'NAME');
    }
    @IsTest
    static void getMatchesTEST(){
        Map<String, String> m =lwcUtils.getMatches('storybank__Storybank_Matches', 'Contact');
		Map<String, String> m2 = new Map<String,String>();
        for(Schema.FieldSetMember s : Schema.SObjectType.Contact.fieldSets.Storybank_Matches.getFields()){
            m2.put(s.getLabel(), s.getFieldPath());
        }
        System.assertEquals(m, m2);      
    }    
}