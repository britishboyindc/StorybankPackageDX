public with sharing class StorybankInstallationScripts {

  public static void execute () {
    setupMainSettings();    
    setupNominatorSettings();
    setupStoryTellerSettings();
    setupNominatorOrgSettings();
    setupApprovedStorybankSettings();
    }

  public static void setupMainSettings () {  
  List<Storybank_Settings__c>  sbsettings = new List<Storybank_Settings__c>();
  sbsettings.add(new Storybank_Settings__c( Name = 'DefaultAccountId', Description__c = 'For new Contacts with no Account set, this Account will be used'));
  sbsettings.add(new Storybank_Settings__c( Name = 'StorytellerRecordTypeId', Description__c = 'If populated, use this RecordTypeId'));
  sbsettings.add(new Storybank_Settings__c( Name = 'NominatorRecordTypeId', Description__c = 'If populated, use this RecordTypeId for Nominator Contacts'));
  sbsettings.add(new Storybank_Settings__c( Name = 'NominatorOrgRecordTypeId', Description__c = 'If populated, use this RecordTypeId for Nominator Orgs'));
  sbsettings.add(new Storybank_Settings__c( Name = 'ChatterGroupId', Description__c = 'If populated, stories post to this Chatter Group Id'));
  
  insert sbsettings;
  }
  
  public static void setupNominatorSettings () {  
    
  List<StorybankFieldsNominator__c>  sbNominatorFields = new List<StorybankFieldsNominator__c> ();
    sbNominatorFields.add(new StorybankFieldsNominator__c( Contact_object_fieldname__c = 'Nominator_First__c', Name = 'FirstName',Display_Order__c = 10));
    sbNominatorFields.add(new StorybankFieldsNominator__c( Contact_object_fieldname__c = 'Nominator_Last_Name__c', Name = 'LastName',Display_Order__c = 20));
    sbNominatorFields.add(new StorybankFieldsNominator__c( Contact_object_fieldname__c = 'Nominator_Email_Address__c', Name = 'Email',Display_Order__c = 30));
    sbNominatorFields.add(new StorybankFieldsNominator__c( Contact_object_fieldname__c = 'Nominator_Phone__c', Name = 'Phone',Display_Order__c = 40));
    sbNominatorFields.add(new StorybankFieldsNominator__c( Contact_object_fieldname__c = 'Nominator_Address__c', Name = 'MailingStreet',Display_Order__c = 50));
    sbNominatorFields.add(new StorybankFieldsNominator__c( Contact_object_fieldname__c = 'Nominator_City__c', Name = 'MailingCity',Display_Order__c = 60));
    sbNominatorFields.add(new StorybankFieldsNominator__c( Contact_object_fieldname__c = 'Nominator_State_pick__c', Name = 'MailingState',Display_Order__c = 70));
    sbNominatorFields.add(new StorybankFieldsNominator__c( Contact_object_fieldname__c = 'Nominator_Postal_Code__c', Name = 'MailingPostalCode',Display_Order__c = 80));
    
    
    insert sbNominatorFields;
}

    public static void setupStoryTellerSettings () {  
    List<StorybankFieldsStoryteller__c>  sbStoryTellerFields = new List<StorybankFieldsStoryteller__c> ();
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c = 'First_Name__c', Name='FirstName',Display_Order__c=10));
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c ='Last_Name__c',Name='LastName',Display_Order__c=15));
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Email_Address__c',Name='Email',Display_Order__c=20));
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Phone__c',Name='Phone',Display_Order__c=23));
    
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Street_Address__c',Name='MailingStreet',Display_Order__c=25));
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='City__c',Name='MailingCity',Display_Order__c=30));
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='State_pick__c',Name='MailingState',Display_Order__c=35));
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Postal_Code__c',Name='MailingPostalCode',Display_Order__c=40));
    
    
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Age_range__c',Name='Age_range__c',Display_Order__c=45));
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Disability__c',Name='Disability__c',Display_Order__c=50));
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Ethnicity__c',Name='Ethnicity__c',Display_Order__c=55));
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Gender__c',Name='Gender__c',Display_Order__c=60));
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Sexual_Orientation__c',Name='Sexual_Orientation__c',Display_Order__c=65));
    sbStoryTellerFields.add(new StorybankFieldsStoryteller__c(Contact_object_fieldname__c='Veteran__c',Name='Veteran__c',Display_Order__c=80));
    insert sbStoryTellerFields;
       }

public static void setupNominatorOrgSettings () {  
   
    List< storybank__Storybank_Fields_Nominator_Org__c >  NominatorOrgFields = new List< storybank__Storybank_Fields_Nominator_Org__c > ();
    NominatorOrgFields.add(new storybank__Storybank_Fields_Nominator_Org__c(Name = 'Name', storybank__Storybank_Submitted_Nominator_Org_Field__c = 'Nominator_Organization__c', Display_Order__c = 100 ));
    NominatorOrgFields.add(new storybank__Storybank_Fields_Nominator_Org__c(Name = 'Phone', storybank__Storybank_Submitted_Nominator_Org_Field__c = 'Nominator_Phone__c', Display_Order__c = 110 ));
    NominatorOrgFields.add(new storybank__Storybank_Fields_Nominator_Org__c(Name = 'BillingCity', storybank__Storybank_Submitted_Nominator_Org_Field__c = 'Nominator_City__c', Display_Order__c = 120 ));
    NominatorOrgFields.add(new storybank__Storybank_Fields_Nominator_Org__c(Name = 'BillingState', storybank__Storybank_Submitted_Nominator_Org_Field__c = 'Nominator_State_pick__c', Display_Order__c = 130 ));
    NominatorOrgFields.add(new storybank__Storybank_Fields_Nominator_Org__c(Name = 'BillingPostalCode', storybank__Storybank_Submitted_Nominator_Org_Field__c = 'Nominator_Postal_Code__c', Display_Order__c = 140 ));
    
    insert NominatorOrgFields;
  }
  
  public static void setupApprovedStorybankSettings () {  
    List<storybank__Storybank_Map_Submitted_Approved__c> sbtoapproved = new List<storybank__Storybank_Map_Submitted_Approved__c> (); 
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'Agree_to_Terms_of_Use__c',storybank__Storybank_Submitted_Story_Field__c = 'Agree_to_Terms_of_Use__c'));
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'Category__c',storybank__Storybank_Submitted_Story_Field__c = 'Category__c'));
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'Embed_URL__c',storybank__Storybank_Submitted_Story_Field__c = 'Embed_URL__c'));
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'Final_Copy__c',storybank__Storybank_Submitted_Story_Field__c = 'Final_Copy__c'));
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'How_did_you_hear_about_us__c',storybank__Storybank_Submitted_Story_Field__c = 'How_did_you_hear_about_us__c'));
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'Story_Summary__c',storybank__Storybank_Submitted_Story_Field__c = 'Story_Summary__c'));
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'Storybank_Name__c',storybank__Storybank_Submitted_Story_Field__c = 'Storybank_Name__c'));
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'Storyteller_Notes__c',storybank__Storybank_Submitted_Story_Field__c = 'Storyteller_Notes__c'));
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'Submitted_Date__c',storybank__Storybank_Submitted_Story_Field__c = 'Submitted_Date__c'));
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'Submitted_Story__c',storybank__Storybank_Submitted_Story_Field__c = 'Submitted_Story__c'));
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'Video_URL__c',storybank__Storybank_Submitted_Story_Field__c = 'Video_URL__c'));
    
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'storybank__Team__c',storybank__Storybank_Submitted_Story_Field__c = 'storybank__Team__c'));
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'storybank__Attribution__c',storybank__Storybank_Submitted_Story_Field__c = 'storybank__Attribution__c'));
   
    sbtoapproved.add(new storybank__Storybank_Map_Submitted_Approved__c(Name = 'storybank__Nominator_Notes__c',storybank__Storybank_Submitted_Story_Field__c = 'storybank__Nominator_Notes__c'));
    
    
    
     insert sbtoapproved;
  }
  
  }