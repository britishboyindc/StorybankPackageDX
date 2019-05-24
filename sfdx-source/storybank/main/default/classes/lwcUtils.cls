public with sharing class lwcUtils {
    @AuraEnabled
    public static Contact createContact(Contact contact) {
        upsert contact;
        return contact;
    }
    @AuraEnabled
    public static Account createAccount(Account account) {
        upsert account;
        return account;
    }
    @AuraEnabled(cacheable=true)
    public static Storybank_Submitted__c getRecord(String Id) {
        List<String> fields = new List<String>();
        for (StorybankFieldsStoryteller__c s : [
                Select Name, Contact_object_fieldname__c
                FROM StorybankFieldsStoryteller__c
                WHERE Display_Order__c != NULL AND Contact_object_fieldname__c != null
                Order By Display_Order__c ASC, Name ASC
        ]) {
            fields.add(s.Contact_object_fieldname__c);
        }
        String allFieldsInString = string.join(fields, ',');
        try {
            String s = 'SELECT Id, Status__c, Storybank_Name__c, storybank__Nominator_Email_Address__c, storybank__Nominator_Organization__c, ' + allFieldsInString + ' FROM Storybank_Submitted__c WHERE Id =:Id';
            return Database.query(s);
        } catch (Exception e) {
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContact(String field, String value) {
        List<Contact> existedContact = new List<Contact>();
        if (value != '') {
            List<String> fields = new List<String>();
            for (StorybankFieldsStoryteller__c s : [
                    Select Name, Contact_object_fieldname__c
                    FROM StorybankFieldsStoryteller__c
                    WHERE Display_Order__c != NULL AND Contact_object_fieldname__c != null
                    Order By Display_Order__c ASC, Name ASC
            ]) {
                fields.add(s.Name);
            }
            String allFieldsInString = string.join(fields, ',');
            String str = 'SELECT Id, ' + allFieldsInString + ' FROM Contact WHERE ' + field + ' = ' + '\'' + value + '\'';
            existedContact = Database.query(str);
        }
        return existedContact;
    }
    @AuraEnabled
    public static String createNewStoryApproved(String currentStorybankSubmittedId, String contactId, String nominatorId, String organizationId) {
        Set<String> sFields = new Set<String>();
        sFields.addall(getNominatorOrgSubmittedFields(Storybank_Fields_Nominator_Org__c.getall().values()));
        sFields.addall(getSubmittedFields(storybank__Storybank_Map_Submitted_Approved__c.getall().values()));
        sFields.addall(getNominatorContactSubmittedFields(StorybankFieldsNominator__c.getall().values()));
        sFields.addall(getStorytellerSubmittedFields(StorybankFieldsStoryteller__c.getall().values()));
        List<String> allUniqueFields = new List<String>();
        allUniqueFields.addall(sFields);
        String allfields = string.join(allUniqueFields, ',');
        String query = 'SELECT ' + allfields + ' FROM Storybank_Submitted__c WHERE Id = :currentStorybankSubmittedId';
        Storybank_Submitted__c currentSSRecord = Database.query(query);
        String resultString = '';
        Storybank_Approved__c newStoryApproved = new Storybank_Approved__c();
        for (storybank__Storybank_Map_Submitted_Approved__c s : storybank__Storybank_Map_Submitted_Approved__c.getall().values()) {
            newStoryApproved.put(s.Name, currentSSRecord.get(s.storybank__Storybank_Submitted_Story_Field__c));
        }
        newStoryApproved.Name = currentSSRecord.Storybank_Name__c;
        if (newStoryApproved.Name == null) {
            newStoryApproved.Name = 'Story from ' + currentSSRecord.First_Name__c + ' ' + currentSSRecord.Last_Name__c;
        }
        if (contactId != null) {
            newStoryApproved.Storyteller__c = contactId;
        }
        if (nominatorId != null) {
            newStoryApproved.Submitter__c = nominatorId;
        }
        if (organizationId != null) {
            newStoryApproved.Nominating_Organization__c = organizationId;
        }
        try {
            insert newStoryApproved;
            currentSSRecord.Status__c = 'Converted';
            update currentSSRecord;
            return newStoryApproved.Id;
        } catch (Exception Ex) {
            return null;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Object> fillWrapper(String context, String submittedId, String contactId) {
        List<WrapperUpdateInformation> newList = new List<WrapperUpdateInformation>();
        List<Object> listFields = new List<Object>();
        if (context == 'Storyteller') {
            listFields = [
                    Select Name, Contact_object_fieldname__c
                    FROM StorybankFieldsStoryteller__c
                    WHERE Display_Order__c != NULL AND Contact_object_fieldname__c != null
                    Order By Display_Order__c ASC, Name ASC
            ];
        } else if (context == 'Nominator') {
            listFields = [
                    Select Name, Contact_object_fieldname__c
                    From StorybankFieldsNominator__c
                    WHERE Display_Order__c != NULL
                    AND Contact_object_fieldname__c != null
                    Order By Display_Order__c ASC, Name ASC
            ];
        }
        Storybank_Submitted__c rec = new Storybank_Submitted__c();
        Map<String, Object> sr = new Map<String, Object>();
        Contact cont = new Contact();
        Map<String, Object> cr = new Map<String, Object>();
        if (submittedId != null && contactId != null) {
            if (context == 'Storyteller') {
                rec = getRecord(submittedId);
                sr = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rec));
            } else if (context == 'Nominator') {
                sr = getCurrentNominatorValues(submittedId, 'nominatorUpdatePage');
            }
            cont = getContact('Id', contactId)[0];
            cr = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(cont));
        }
        for (Integer i = 0; i < listFields.size(); i++) {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(listFields[i]));
            List<String> actions = new List<String>();
            String name = String.valueof(m.get('Name'));
            String contactObjectFieldName = String.valueof(m.get('storybank__Contact_object_fieldname__c'));
            if (name == 'Age_range__c') {
                name = 'Age_Range__c';
            }
            actions.add('Overwrite');
            actions.add('Do Not Update');
            if (name == 'MailingStreet') {
                actions.add('Append');
            }
            if (name.contains('__c')) {
                name = 'storybank__' + name;
            }
            String fieldLabel = getfieldlabel(name);
            String selectedAction = '';
            if (submittedId != null && contactId != null) {
                String submittedValue = String.valueof(sr.get('storybank__' + contactObjectFieldName));
                String contactValue = String.valueof(cr.get(name));
                if (submittedValue == contactValue) {
                    selectedAction = '';
                } else if (submittedValue != contactValue) {
                    if (submittedValue != '' && submittedValue != null) {
                        selectedAction = 'Overwrite';
                    } else {
                        selectedAction = 'Do Not Update';
                    }
                }
            }
            newList.add(new WrapperUpdateInformation(fieldLabel, 'storybank__' + contactObjectFieldName, actions, name, selectedAction));
        }
        return newList;
    }
    public static String getfieldlabel(String confield) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Contact');
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        return fieldMap.get(confield).getDescribe().getLabel();
    }
    @AuraEnabled
    public static String updateContactButton(Contact contact, Storybank_Submitted__c storybankSubmitted, String Id, String nominatorOrgId) {
        updateContactAndSubmittedRecords(contact, storybankSubmitted);
        if (Id == null) {
            //In this case contact for update which accept method is Storyteller 
            return createNewStoryApproved(storybankSubmitted.Id, contact.Id, Id, nominatorOrgId);
        } else {
            //In this case contact for update which accept method is Nominator 
            return createNewStoryApproved(storybankSubmitted.Id, Id, contact.Id, nominatorOrgId);
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<String> fieldsForConversion(String context) {
        Schema.FieldSet fs1;
        if (context == 'nominator') {
            fs1 = Schema.SObjectType.Storybank_Submitted__c.fieldSets.Nominator_Fields_for_Conversion;
        } else if (context == 'storyteller') {
            fs1 = Schema.SObjectType.Storybank_Submitted__c.fieldSets.Submitted_Storyteller_Information;
        } else if (context == 'nominatorOrg') {
            fs1 = Schema.SObjectType.Storybank_Submitted__c.fieldSets.Nominator_Org_Fields_for_Submission;
        }
        List<String> fieldsForConversion = new List<String>();
        for (Schema.FieldSetMember s : fs1.getFields()) {
            fieldsForConversion.add(s.getFieldPath());
        }
        return fieldsForConversion;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCurrentNominatorValues(String Id, String context) {
        List<Object> allFields = new List<Object>();
        if (context == 'nominatorOrganization') {
            allFields = [
                    Select Name, Storybank_Submitted_Nominator_Org_Field__c
                    From Storybank_Fields_Nominator_Org__c
                    WHERE Display_Order__c != NULL AND Storybank_Submitted_Nominator_Org_Field__c != null
                    Order By Display_Order__c ASC, Name ASC
            ];
        }
        if (context == 'nominatorCreatePage' || context == 'nominatorUpdatePage') {
            allFields = [
                    Select Name, Contact_object_fieldname__c
                    From StorybankFieldsNominator__c
                    WHERE Display_Order__c != NULL AND Contact_object_fieldname__c != null
                    Order By Display_Order__c ASC, Name ASC
            ];
        }
        String WorkField = '';
        List<String> asd = new List<String>();
        for (Object o : allFields) {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
            if (context == 'nominatorOrganization') {
                WorkField = 'storybank__Storybank_Submitted_Nominator_Org_Field__c';
                asd.add(String.valueof(m.get(WorkField)));
            } else if (context == 'nominatorCreatePage' || context == 'nominatorUpdatePage') {
                WorkField = 'storybank__Contact_object_fieldname__c';
                asd.add(String.valueof(m.get(WorkField)));
            }
        }
        String fields = String.join(asd, ',');
        String query = 'SELECT ' + fields + ' FROM Storybank_Submitted__c WHERE Id = :Id';
        Storybank_Submitted__c curentSubmRec = Database.query(query);
        Map<String, String> resultMap = new Map<String, String>();
        for (Object s : allFields) {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(s));
            if (context == 'nominatorCreatePage' || context == 'nominatorOrganization') {
                String value = String.valueof(curentSubmRec.get(String.valueof(m.get(WorkField))));
                if (value == null) {
                    resultMap.put(String.valueof(m.get('Name')), '');
                } else {
                    resultMap.put(String.valueof(m.get('Name')), value);
                }
            } else if (context == 'nominatorUpdatePage') {
                String value = String.valueof(curentSubmRec.get(String.valueof(m.get(WorkField))));
                resultMap.put('storybank__' + String.valueof(m.get(WorkField)), value);
            }
        }
        if (context == 'nominatorUpdatePage') {
            resultMap.put('Id', curentSubmRec.Id);
        }
        return resultMap;
    }
    @AuraEnabled
    public static void updateContactAndSubmittedRecords(Contact contact, Storybank_Submitted__c storybankSubmitted) {
        update contact;
        update storybankSubmitted;
    }
    public static List<String> getSubmittedFields(List<storybank__Storybank_Map_Submitted_Approved__c> satosb) {
        List<String> sFields = new List<String> ();
        for (storybank__Storybank_Map_Submitted_Approved__c s : satosb) {
            sFields.add(s.storybank__Storybank_Submitted_Story_Field__c);
        }
        return sFields;
    }
    public static List<String> getNominatorOrgSubmittedFields(List<storybank__Storybank_Fields_Nominator_Org__c> satosb) {
        List<String> sFields = new List<String> ();
        for (storybank__Storybank_Fields_Nominator_Org__c s : satosb) {
            if (s.storybank__Storybank_Submitted_Nominator_Org_Field__c != null) {
                sFields.add(s.storybank__Storybank_Submitted_Nominator_Org_Field__c);
            }
        }
        return sFields;
    }
    public static List<String> getNominatorContactSubmittedFields(List<StorybankFieldsNominator__c> satosb) {
        List<String> sFields = new List<String> ();
        for (StorybankFieldsNominator__c s : satosb) {
            if (s.storybank__Contact_object_fieldname__c != null) {
                sFields.add(s.storybank__Contact_object_fieldname__c);
            }
        }
        return sFields;
    }
    public static List<String> getStorytellerSubmittedFields(List<StorybankFieldsStoryteller__c> satosb) {
        List<String> sFields = new List<String> ();
        for (StorybankFieldsStoryteller__c s : satosb) {
            if (s.storybank__Contact_object_fieldname__c != null) {
                sFields.add(s.storybank__Contact_object_fieldname__c);
            }
        }
        return sFields;
    }
    @AuraEnabled
    public static List<Account> getAccount(String name) {
        Schema.FieldSet fs1 = Schema.SObjectType.Account.fieldSets.Storybank_Nominating_Organization;
        List<String> fieldsForSelect = new List<String>();
        for (Schema.FieldSetMember s : fs1.getFields()) {
            fieldsForSelect.add(s.getFieldPath());
        }
        String fields = String.join(fieldsForSelect, ',');
        String query = 'SELECT ' + fields + ' FROM Account WHERE Name = :name';
        List<Account> accs = Database.query(query);
        return accs;
    }
     @AuraEnabled
     public static Map<String, String> getMatches(String fieldSetName, String ObjectName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        Map<String, String> m = new Map<String,String>();
        for(Schema.FieldSetMember s : fieldSetObj.getFields()){
           m.put(s.getLabel(), s.getFieldPath());
        }
        return m;
     }
}