public class StorybankUtilities {

public static Map<String,Schema.SObjectField> contactMapFields;
public static Map<String,Schema.SObjectField> storybankMapFields;
public static Boolean bGroupMember;

public static Schema.DescribeFieldResult getContactFieldDescription (String s) {
    if (contactMapFields  == null) {
    contactMapFields = Contact.sObjectType.getDescribe().fields.getMap();
    }
    
    return contactMapFields.get(s).getDescribe();
    
}

public static Schema.DescribeFieldResult getStorybankFieldDescription (String s) {
    if (storybankMapFields  == null) {
    storybankMapFields = Storybank_Approved__c.sObjectType.getDescribe().fields.getMap();
    }
    
    return storybankMapFields.get(s).getDescribe();
    
}

public static Boolean getGroupMemberStatus (Id chattergroupid) {
//Check to see if current user is member of Group - if so, they can write to Group
if (bGroupMember == NULL) {
    bGroupMember = FALSE;

    CollaborationGroupMember [] cgmember = [Select Id from CollaborationGroupMember WHERE CollaborationGroupId = :chattergroupid AND MemberId = :userinfo.getUserId()];
    if (cgmember.size() > 0) {
    bGroupMember = TRUE;
    }
}
return bGroupMember;
} 

public static List<String> getSubmittedFields (List<storybank__Storybank_Map_Submitted_Approved__c> satosb ) {
List<String> sFields = new List<String> ();

for (storybank__Storybank_Map_Submitted_Approved__c s: satosb) {
sFields.add(s.storybank__Storybank_Submitted_Story_Field__c);
}
return sFields;
}

public static List<String> getNominatorOrgSubmittedFields (List<storybank__Storybank_Fields_Nominator_Org__c> satosb ) {
List<String> sFields = new List<String> ();

for (storybank__Storybank_Fields_Nominator_Org__c s: satosb) {
    if (s.storybank__Storybank_Submitted_Nominator_Org_Field__c != null) {
        sFields.add(s.storybank__Storybank_Submitted_Nominator_Org_Field__c);
    }
}
return sFields;
}  

public static List<String> getNominatorContactSubmittedFields (List<StorybankFieldsNominator__c> satosb ) {
List<String> sFields = new List<String> ();

for (StorybankFieldsNominator__c s: satosb) {
    if (s.storybank__Contact_object_fieldname__c != null) {
        sFields.add(s.storybank__Contact_object_fieldname__c);
    }
}
return sFields;
}  

public static List<String> getStorytellerSubmittedFields (List<StorybankFieldsStoryteller__c> satosb ) {
List<String> sFields = new List<String> ();

for (StorybankFieldsStoryteller__c s: satosb) {
    if (s.storybank__Contact_object_fieldname__c != null) {
        sFields.add(s.storybank__Contact_object_fieldname__c);
    }
}
return sFields;
}  

} //end class