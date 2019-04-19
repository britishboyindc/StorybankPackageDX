public class TEST_DATA_Factory {


public static void setupStoryBankDefaults () {

    Account a = new Account (Name = 'Default SB Account');
    insert a;

    CollaborationGroup cg = new CollaborationGroup(Name = 'Test Group' + string.valueof(system.today()), CollaborationType = 'Public' );
    insert cg;

    List<Storybank_Settings__c> sbtest = new List<Storybank_Settings__c> ();
        
    sbtest.add(new Storybank_Settings__c (Name = 'DefaultAccountId', target_value__c = a.Id ));
    sbtest.add(new Storybank_Settings__c (Name = 'ChatterGroupId', target_value__c = cg.Id ));
    sbtest.add(new Storybank_Settings__c (Name = 'NominatorRecordTypeId'));
    sbtest.add(new Storybank_Settings__c (Name = 'StorytellerRecordTypeId'));
    sbtest.add(new Storybank_Settings__c (Name = 'NominatorOrgRecordTypeId'));
        
    insert sbtest;
    
    StorybankInstallationScripts.setupNominatorSettings();
    StorybankInstallationScripts.setupStoryTellerSettings();
    StorybankInstallationScripts.setupNominatorOrgSettings();
    StorybankInstallationScripts.setupApprovedStorybankSettings();

    }
 
public static Storybank_Submitted__c createselfsubmission() {

    Storybank_Submitted__c ws = new Storybank_Submitted__c();

    ws.Submission_Type__c = 'Submitted by Self';
    ws.Agree_to_Terms_of_Use__c = TRUE;
    ws.First_Name__c = 'TestF';
    ws.Last_Name__c = 'TestL';
    ws.Email_Address__c = 'testselfnew@bfcclient.com';
    ws.City__c = 'Washington';
    ws.State_pick__c = 'DC';
    ws.Postal_Code__c = '20005';
    ws.Gender__c = 'Male';
    ws.Ethnicity__c = 'White';
    ws.Veteran__c = FALSE;
    ws.Age_range__c = '35-64';
    ws.Disability__c = FALSE;
    ws.Storyteller_Notes__c = 'Test Notes + Test More Notes';
    ws.Experience_w_Media__c = TRUE;
    ws.Category__c='Education';
    ws.Attribution__c=null;
    ws.Final_Copy__c='Test Final Copy'; 
    ws.Team_Source__c = 'Story 2';
    ws.Video_URL__c=null; 
    ws.Video__c=FALSE; 
    ws.Embed_URL__c=null; 
    ws.Other_Category__c=null;
    
    return ws;

 }  


public static Storybank_Submitted__c createnominatorsubmission() {

    Storybank_Submitted__c ws = createselfsubmission();

    ws.Submission_Type__c = 'Submitted by Nominator';
    ws.Nominator_Last_Name__c = 'TestNL';
    ws.Nominator_Email_Address__c = 'testnom@bfcclient.com';
    ws.Nominator_City__c = 'Nom City';
    ws.Nominator_State_pick__c = 'VA';
    ws.Nominator_Postal_Code__c = '22206';
    ws.Nominator_Notes__c = ' Nominator Notes';
    ws.Nominator_Organization__c = 'Test NOM Org';
    ws.Nominator_Phone__c = '202-555-1234';
    
    return ws;


}  

public static Contact createExistingStoryteller() {

    Contact c = new Contact();
    c.AccountId = Storybank_Settings__c.getValues('DefaultAccountId').Target_Value__c;
    c.LastName = 'StoryL';
    c.FirstName = 'StoryF';
    c.Email = 'story1@bfcclient.com';

    return c;
}  


public static Account createExistingNominatorOrg() {

    Account a = new Account();
    a.Name = 'Story1';

    return a;
}  


public static Contact createExistingNominatorContact() {

    Account a = createExistingNominatorOrg();
    insert a;

    Contact c = new Contact();
    c.AccountId = a.Id;
    c.LastName = 'NomL';
    c.FirstName = 'NomF';
    c.Email = 'nom1@bfcclient.com';

    return c;


}  

}