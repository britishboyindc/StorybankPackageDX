@isTest
private class TEST_StoryBankConversion {

private static string urlnamespace = '/apex/storybank__';

@testSetup
private static void setupDefaults() {
    TEST_DATA_Factory.setupStoryBankDefaults ();
}

@isTest
static void testSelfNoVideo() {
    //TEST_DATA_Factory.setupStoryBankDefaults ();

    Storybank_Submitted__c testws1 = TEST_DATA_Factory.createselfsubmission();
    testws1.Submitted_Story__c = 'This is my story - tell me yours';
    insert testws1;

    testws1.Status__c = 'Accepted';
    update testws1;

    //Check Chatter Group Populated
    FeedItem fi = [Select Id, Title, Body from FeedItem WHERE ParentId = :Storybank_Settings__c.getValues('ChatterGroupId').Target_Value__c];
    system.assertequals('New Submission: This is my story - tell me yours...', fi.Body);
    system.assertequals('New Story Submission', fi.Title);


    PageReference pageRef = Page.StorybankSubmissionConversionStoryteller;
    Test.setCurrentPage(pageRef);
      
    //Instantiate Extension to mimic page
    StorybankSubmissionConversionController storyconversion = new StorybankSubmissionConversionController(new ApexPages.StandardController(testws1)); 
        
    system.assertequals ('TestF', storyconversion.newContact.FirstName);
    system.assertequals ('TestL', storyconversion.newContact.LastName);
    system.assertequals (FALSE, storyconversion.newContact.Disability__c);
        
    system.assertequals(0, storyconversion.cons.size());

    storyconversion.newContact.Email = 'testselfnew @bfcclient.com'; //set to fail

    try { //will fail due ot bad email
        storyconversion.createStoryTellerRecord();
    }
    Catch (Exception Ex) {
        system.debug(Ex.getmessage());  
    }       
        
    //Fix
    storyconversion.newContact.Email = 'testselfnew@bfcclient.com'; //set to fail
    String sURL = storyconversion.createStoryTellerRecord().getURL();
      
    Id StoryTellerId = storyconversion.newContact.Id;

    //Confirm Contact Inserted
    Contact tConfirm = [Select Id, LastName, AccountId from Contact WHERE Email = 'testselfnew@bfcclient.com' ];
    system.assertequals('TestL', tConfirm.LastName);
    system.assertequals(Storybank_Settings__c.getValues('DefaultAccountId').Target_Value__c, tConfirm.AccountId);

    system.assertequals('Test Notes + Test More Notes', storyconversion.rs.Storyteller_Notes__c);
    system.assertequals('Story from TestF TestL', storyconversion.rs.Name);
    system.assertequals(StoryTellerId, storyconversion.rs.Storyteller__c); 
    system.assertequals('This is my story - tell me yours', storyconversion.rs.Submitted_Story__c); 

    //storyconversion.convertsubmission();

    Storybank_Submitted__c testwsconfirm = [Select Id, Status__c from Storybank_Submitted__c WHERE Id = :testws1.Id];
    system.assertequals('Converted', testwsconfirm.Status__c);

    Storybank_Approved__c [] sa = [Select Id, Posted__c from Storybank_Approved__c];
    system.assertequals(1, sa.size());
    sa[0].Posted__c = TRUE;
    update sa;

    //Now test Remote Queries
    
    List<String> testCategories = new List<String> ();

    for (Schema.PicklistEntry p: StorybankUtilities.getStorybankFieldDescription ('Category__c').getPicklistValues() ){
    testCategories.add(p.getlabel());
    }
    
    Storybank_Queries sq = new Storybank_Queries();
    system.assertequals(testCategories[0], sq.Categories[0]);
    
    List<Storybank_Approved__c> testQuery = Storybank_Queries.getStoriesbyState('DC');
    system.assertequals('Test Final Copy', testQuery[0].Final_Copy__c);
    system.assertequals(storyconversion.rs.Storyteller__c, testQuery[0].Storyteller__c);
    
    testQuery = Storybank_Queries.getStoriesbyCategory('Education');
    system.assertequals(storyconversion.rs.Storyteller__c, testQuery[0].Storyteller__c);
         
    Storybank_Approved__c testdetail = Storybank_Queries.getStoryDetail((String)testQuery[0].Id);
    system.assertequals('Test Final Copy', testdetail.Final_Copy__c);
    
}
    
    
@isTest
static void testSelfwithVideo() {
    //TEST_DATA_Factory.setupStoryBankDefaults ();

    Storybank_Submitted__c testws1 = TEST_DATA_Factory.createselfsubmission();
    testws1.Submitted_Story__c = 'This is my video - tell me yours';
    testws1.Video_URL__c = 'http://youtu.be/RDQIrEECjfQ';
    insert testws1;

    testws1.Status__c = 'Accepted';
    update testws1;

    //Check Chatter Group Populated
    FeedItem fi = [Select Id, Title, Body from FeedItem WHERE ParentId = :Storybank_Settings__c.getValues('ChatterGroupId').Target_Value__c];
    system.assertequals('New Video Submission', fi.Title);

    PageReference pageRef = Page.StorybankSubmissionConversionStoryteller;
    Test.setCurrentPage(pageRef);
  
    //Instantiate Extension to mimic page
    StorybankSubmissionConversionController storyconversion = new StorybankSubmissionConversionController(new ApexPages.StandardController(testws1)); 
    
    system.assertequals ('TestF', storyconversion.newContact.FirstName);
    system.assertequals ('TestL', storyconversion.newContact.LastName);
    system.assertequals ('testselfnew@bfcclient.com', storyconversion.newContact.Email);
    system.assertequals (FALSE, storyconversion.newContact.Disability__c);
    
    system.assertequals(0, storyconversion.cons.size());
    
    String sURL = storyconversion.createStoryTellerRecord().getURL();
    
    Id StoryTellerId = storyconversion.newContact.Id;

    //Confirm Contact Inserted
    Contact tConfirm = [Select Id, LastName, AccountId from Contact WHERE Email = 'testselfnew@bfcclient.com' ];
    system.assertequals('TestL', tConfirm.LastName);
    system.assertequals(Storybank_Settings__c.getValues('DefaultAccountId').Target_Value__c, tConfirm.AccountId);

    system.assertequals('Test Notes + Test More Notes', storyconversion.rs.Storyteller_Notes__c);
    system.assertequals('Story from TestF TestL', storyconversion.rs.Name);
    system.assertequals(StoryTellerId, storyconversion.rs.Storyteller__c); 
    system.assertequals('This is my video - tell me yours', storyconversion.rs.Submitted_Story__c); 
    system.assertequals('http://youtu.be/RDQIrEECjfQ', storyconversion.rs.video_url__c); 

    Storybank_Submitted__c testwsconfirm = [Select Id, Status__c, Video_URL__c from Storybank_Submitted__c WHERE Id = :testws1.Id];
    system.assertequals('Converted', testwsconfirm.Status__c);
    system.assertequals('http://youtu.be/RDQIrEECjfQ', testwsconfirm.Video_URL__c);

    system.assertequals(1, [Select count() from Storybank_Approved__c]);


}

@isTest
static void testSelfwithVideonoDefaultAccount() {
    //TEST_DATA_Factory.setupStoryBankDefaults ();
    Map<String, Storybank_Settings__c> sbtestupdate = Storybank_Settings__c.getall();
    Storybank_Settings__c sbAccount = sbtestupdate.get('DefaultAccountId');
    sbAccount.target_value__c = NULL;
    update sbAccount;
    
    Storybank_Submitted__c testws1 = TEST_DATA_Factory.createselfsubmission();
    testws1.Submitted_Story__c = 'This is my video - tell me yours';
    testws1.Video_URL__c = 'http://youtu.be/RDQIrEECjfQ';
    insert testws1;

    testws1.Status__c = 'Accepted';
    update testws1;

    //Check Chatter Group Populated
    FeedItem fi = [Select Id, Title, Body from FeedItem WHERE ParentId = :Storybank_Settings__c.getValues('ChatterGroupId').Target_Value__c];
    system.assertequals('New Video Submission', fi.Title);

    PageReference pageRef = Page.StorybankSubmissionConversionStoryteller;
    Test.setCurrentPage(pageRef);
  
    //Instantiate Extension to mimic page
    StorybankSubmissionConversionController storyconversion = new StorybankSubmissionConversionController(new ApexPages.StandardController(testws1)); 
    
    system.assertequals ('TestF', storyconversion.newContact.FirstName);
    system.assertequals ('TestL', storyconversion.newContact.LastName);
    system.assertequals ('testselfnew@bfcclient.com', storyconversion.newContact.Email);
    system.assertequals (FALSE, storyconversion.newContact.Disability__c);
    
    system.assertequals(0, storyconversion.cons.size());
    
    String sURL = storyconversion.createStoryTellerRecord().getURL();
    
    Id StoryTellerId = storyconversion.newContact.Id;

    //Confirm Contact Inserted
    Contact tConfirm = [Select Id, LastName, AccountId from Contact WHERE Email = 'testselfnew@bfcclient.com' ];
    system.assertequals('TestL', tConfirm.LastName);
    system.assertequals(NULL, tConfirm.AccountId);

    system.assertequals('Test Notes + Test More Notes', storyconversion.rs.Storyteller_Notes__c);
    system.assertequals('Story from TestF TestL', storyconversion.rs.Name);
    system.assertequals(StoryTellerId, storyconversion.rs.Storyteller__c); 
    system.assertequals('This is my video - tell me yours', storyconversion.rs.Submitted_Story__c); 
    system.assertequals('http://youtu.be/RDQIrEECjfQ', storyconversion.rs.video_url__c); 

    Storybank_Submitted__c testwsconfirm = [Select Id, Status__c, Video_URL__c from Storybank_Submitted__c WHERE Id = :testws1.Id];
    system.assertequals('Converted', testwsconfirm.Status__c);
    system.assertequals('http://youtu.be/RDQIrEECjfQ', testwsconfirm.Video_URL__c);

    system.assertequals(1, [Select count() from Storybank_Approved__c]);


}

@isTest
static void testExistingSelfwithVideo() {
    //TEST_DATA_Factory.setupStoryBankDefaults ();
    Contact teststoryc = TEST_DATA_Factory.createExistingStoryteller();
    //Set a Team Source
    teststoryc.Team_Source__c = 'Story 2;Story 3';
    insert teststoryc;

    //Set SOSL Search for Test
    Id [] fixedSearchResultsc = new Id[1];
    fixedSearchResultsc[0] = teststoryc.Id;
    Test.setFixedSearchResults(fixedSearchResultsc);


    Storybank_Submitted__c testws1 = TEST_DATA_Factory.createselfsubmission();
    testws1.Email_Address__c = teststoryc.email;
    testws1.Submitted_Story__c = 'This is my video - tell me yours';
    testws1.Video_URL__c = 'http://youtu.be/RDQIrEECjfQ';
    insert testws1;

    testws1.Status__c = 'Accepted';
    update testws1;

    //Check Chatter Group Populated
    FeedItem fi = [Select Id, Title, Body from FeedItem WHERE ParentId = :Storybank_Settings__c.getValues('ChatterGroupId').Target_Value__c];
    system.assertequals('New Video Submission', fi.Title);

    PageReference pageRef = Page.StorybankSubmissionConversionStoryteller;
    Test.setCurrentPage(pageRef);
  
    //Instantiate Extension to mimic page
    StorybankSubmissionConversionController storyconversion = new StorybankSubmissionConversionController(new ApexPages.StandardController(testws1)); 
  
    system.assertequals(1, storyconversion.cons.size());
    
    ApexPages.currentPage().getParameters().put('cid', teststoryc.Id);
    
    String sURL = storyconversion.setSelected().getURL();
    system.assertequals(urlnamespace + 'storybanksubmissionupdatestoryteller', sURL);
    
    storyconversion.createStoryTellerRecord();

    system.assertequals('Test Notes + Test More Notes', storyconversion.rs.Storyteller_Notes__c);
    system.assertequals('Story from TestF TestL', storyconversion.rs.Name);
    system.assertequals(teststoryc.Id, storyconversion.rs.Storyteller__c); 
    system.assertequals('This is my video - tell me yours', storyconversion.rs.Submitted_Story__c); 
    system.assertequals('http://youtu.be/RDQIrEECjfQ', storyconversion.rs.video_url__c); 

    storyconversion.convertsubmission();

    Storybank_Submitted__c testwsconfirm = [Select Id, Status__c, Video_URL__c from Storybank_Submitted__c WHERE Id = :testws1.Id];
    system.assertequals('Converted', testwsconfirm.Status__c);
    system.assertequals('http://youtu.be/RDQIrEECjfQ', testwsconfirm.Video_URL__c);

    system.assertequals(1, [Select count() from Storybank_Approved__c]);


}


@isTest
static void testExistingSelfwithVideo2() {
    //TEST_DATA_Factory.setupStoryBankDefaults ();
    Contact teststoryc = TEST_DATA_Factory.createExistingStoryteller();
    //Set a Team Source not in Story
     teststoryc.Team_Source__c = 'Story 3';
    insert teststoryc;

    //Set SOSL Search for Test
    Id [] fixedSearchResultsc = new Id[1];
    fixedSearchResultsc[0] = teststoryc.Id;
    Test.setFixedSearchResults(fixedSearchResultsc);


    Storybank_Submitted__c testws1 = TEST_DATA_Factory.createselfsubmission();
    testws1.Email_Address__c = teststoryc.email;
    testws1.Submitted_Story__c = 'This is my video - tell me yours';
    testws1.Video_URL__c = 'http://youtu.be/RDQIrEECjfQ';
    insert testws1;

    testws1.Status__c = 'Accepted';
    update testws1;

    //Check Chatter Group Populated
    FeedItem fi = [Select Id, Title, Body from FeedItem WHERE ParentId = :Storybank_Settings__c.getValues('ChatterGroupId').Target_Value__c];
    system.assertequals('New Video Submission', fi.Title);

    PageReference pageRef = Page.StorybankSubmissionConversionStoryteller;
    Test.setCurrentPage(pageRef);
  
    //Instantiate Extension to mimic page
    StorybankSubmissionConversionController storyconversion = new StorybankSubmissionConversionController(new ApexPages.StandardController(testws1)); 
  
    system.assertequals(1, storyconversion.cons.size());
    
    ApexPages.currentPage().getParameters().put('cid', teststoryc.Id);
    
    String sURL = storyconversion.setSelected().getURL();
    system.assertequals(urlnamespace + 'storybanksubmissionupdatestoryteller', sURL);
    
    storyconversion.createStoryTellerRecord();

    system.assertequals('Test Notes + Test More Notes', storyconversion.rs.Storyteller_Notes__c);
    system.assertequals('Story from TestF TestL', storyconversion.rs.Name);
    system.assertequals(teststoryc.Id, storyconversion.rs.Storyteller__c); 
    system.assertequals('This is my video - tell me yours', storyconversion.rs.Submitted_Story__c); 
    system.assertequals('http://youtu.be/RDQIrEECjfQ', storyconversion.rs.video_url__c); 

    storyconversion.convertsubmission();

    Storybank_Submitted__c testwsconfirm = [Select Id, Status__c, Video_URL__c from Storybank_Submitted__c WHERE Id = :testws1.Id];
    system.assertequals('Converted', testwsconfirm.Status__c);
    system.assertequals('http://youtu.be/RDQIrEECjfQ', testwsconfirm.Video_URL__c);

    system.assertequals(1, [Select count() from Storybank_Approved__c]);


}


@isTest
static void testNominatorNoVideo() {
    //TEST_DATA_Factory.setupStoryBankDefaults ();

    Storybank_Submitted__c testws1 = TEST_DATA_Factory.createnominatorsubmission();
    testws1.Submitted_Story__c = 'This is their story - tell me yours';
    insert testws1;

    testws1.Status__c = 'Accepted';
    update testws1;

    //Check Chatter Group Populated
    FeedItem fi = [Select Id, Title, Body from FeedItem WHERE ParentId = :Storybank_Settings__c.getValues('ChatterGroupId').Target_Value__c];
    //  system.assertequals('New Submission: This is their story - tell me yours...', fi.Body);
    system.assertequals('New Story Submission', fi.Title);

    PageReference pageRef = Page.StorybankSubmissionConversionStoryteller;
    Test.setCurrentPage(pageRef);
  
    //Instantiate Extension to mimic page
    StorybankSubmissionConversionController storyconversion = new StorybankSubmissionConversionController(new ApexPages.StandardController(testws1)); 
    
    system.assertequals ('TestF', storyconversion.newContact.FirstName);
    system.assertequals ('TestL', storyconversion.newContact.LastName);
    system.assertequals ('testselfnew@bfcclient.com', storyconversion.newContact.Email);
    system.assertequals (FALSE, storyconversion.newContact.Disability__c);
    
    system.assertequals(0, storyconversion.cons.size());

    String sURL = storyconversion.createStoryTellerRecord().getURL();
    system.assertequals(urlnamespace + 'storybanksubmissionconversionnomorg', sURL);
    Id StoryTellerId = storyconversion.newContact.Id;

    //Confirm Contact Inserted
    Contact tConfirm = [Select Id, LastName, AccountId from Contact WHERE Email = 'testselfnew@bfcclient.com' ];
    system.assertequals('TestL', tConfirm.LastName);
    system.assertequals(Storybank_Settings__c.getValues('DefaultAccountId').Target_Value__c, tConfirm.AccountId);

    Id NomOrgId = storyconversion.na.Id;
    storyconversion.createnewnominatorcontact();
    
    storyconversion.newContact.Email = 'testnomnew @bfcclient.com'; //set to fail

    try { //will fail due ot bad email
        storyconversion.submitnewnominatorcontact();
    }
    Catch (Exception Ex) {
        system.debug(Ex.getmessage());  
    }   
    
    //Fix
    storyconversion.newContact.Email = 'testnomnew@bfcclient.com'; 
    
    storyconversion.submitnewnominatorcontact();
    Id NomContactId = storyconversion.newContact.Id;
    
    Storybank_Submitted__c testwsconfirm = [Select Id, Status__c from Storybank_Submitted__c WHERE Id = :testws1.Id];
    system.assertequals('Converted', testwsconfirm.Status__c);

    Storybank_Approved__c testrs = [Select Id, Storyteller_Notes__c, Name, Submitted_Story__c from Storybank_Approved__c];
    
    system.assertequals('Test Notes + Test More Notes', testrs.Storyteller_Notes__c);
    system.assertequals('Story from TestF TestL', testrs.Name);
    system.assertequals('This is their story - tell me yours', testrs.Submitted_Story__c); 

    
}

@isTest
static void testExistingNominatorNoVideo() {
    //TEST_DATA_Factory.setupStoryBankDefaults ();

    Contact teststoryc = TEST_DATA_Factory.createExistingStoryteller();
    insert teststoryc;

    Contact testnomc = TEST_DATA_Factory.createExistingNominatorContact();
    insert testnomc;

    //Set SOSL Search for StoryTeller
    Id [] fixedSearchResultsc = new Id[1];
    fixedSearchResultsc[0] = teststoryc.Id;
    Test.setFixedSearchResults(fixedSearchResultsc);
    
    Storybank_Submitted__c testws1 = TEST_DATA_Factory.createnominatorsubmission();
    testws1.Submitted_Story__c = 'This is their story - tell me yours';
    insert testws1;

    testws1.Status__c = 'Accepted';
    update testws1;

    //Check Chatter Group Populated
    FeedItem fi = [Select Id, Title, Body from FeedItem WHERE ParentId = :Storybank_Settings__c.getValues('ChatterGroupId').Target_Value__c];
    system.assertequals('New Story Submission', fi.Title);

    PageReference pageRef = Page.StorybankSubmissionConversionStoryteller;
    Test.setCurrentPage(pageRef);
  
    //Instantiate Extension to mimic page
    StorybankSubmissionConversionController storyconversion = new StorybankSubmissionConversionController(new ApexPages.StandardController(testws1)); 
    system.assertequals(1, storyconversion.cons.size());
    
    ApexPages.currentPage().getParameters().put('cid', teststoryc.Id);
    
    //Set Next SOSL Search for Test before we invoke page 2
    //Set SOSL Search for Nominator Org
    Id [] fixedSearchResultsa = new Id[1];
    fixedSearchResultsa[0] = testnomc.AccountId;
    Test.setFixedSearchResults(fixedSearchResultsa);

    String sURLc = storyconversion.setSelected().getURL();
    system.assertequals(urlnamespace + 'storybanksubmissionupdatestoryteller', sURLc);
    storyconversion.createStoryTellerRecord();

    system.assertequals(1, storyconversion.accts.size());
   
    ApexPages.currentPage().getParameters().put('aid', testnomc.AccountId);
   
    //Set Next SOSL Search for Test before we invoke page 2
    //Set SOSL Search for Nominator
    Id [] fixedSearchResultsc2 = new Id[1];
    fixedSearchResultsc2[0] = testnomc.Id;
    Test.setFixedSearchResults(fixedSearchResultsc2);
    
    String sURL2 = storyconversion.setSelectedAccount().getURL();
    system.assertequals(urlnamespace + 'storybanksubmissionconversionnominator', sURL2);

    system.assertequals(1, storyconversion.cons.size());
    
    //No Set Nominator
    ApexPages.currentPage().getParameters().put('cid', testnomc.Id);
    String sURL3 = storyconversion.setSelectedNominator().getURL();
    system.assertequals(urlnamespace + 'storybanksubmissionupdatenominator', sURL3);
    storyconversion.createNominatorRecord();
 
 
    system.assertequals('Test Notes + Test More Notes', storyconversion.rs.Storyteller_Notes__c);
    system.assertequals('Story from TestF TestL', storyconversion.rs.Name);
    system.assertequals(teststoryc.Id, storyconversion.rs.Storyteller__c); 
    
    system.assertequals(testnomc.AccountId, storyconversion.rs.Nominating_Organization__c); 
    system.assertequals(testnomc.Id, storyconversion.rs.Submitter__c); 
    
    system.assertequals('This is their story - tell me yours', storyconversion.rs.Submitted_Story__c); 

    Storybank_Submitted__c testwsconfirm = [Select Id, Status__c from Storybank_Submitted__c WHERE Id = :testws1.Id];
    system.assertequals('Converted', testwsconfirm.Status__c);

    system.assertequals(1, [Select count() from Storybank_Approved__c]);
    
    
    
}

       
//Test Field List Getters

@isTest
 static void testVFPageFieldGetters() {
    //TEST_DATA_Factory.setupStoryBankDefaults ();

    Storybank_Submitted__c testws1 = TEST_DATA_Factory.createnominatorsubmission();
    testws1.Submitted_Story__c = 'This is their story - tell me yours';
    insert testws1;

    testws1.Status__c = 'Accepted';
    update testws1;

    //Check Chatter Group Populated
    FeedItem fi = [Select Id, Title, Body from FeedItem WHERE ParentId = :Storybank_Settings__c.getValues('ChatterGroupId').Target_Value__c];
    //  system.assertequals('New Submission: This is their story - tell me yours...', fi.Body);
    system.assertequals('New Story Submission', fi.Title);

    PageReference pageRef = Page.StorybankSubmissionConversionStoryteller;
    Test.setCurrentPage(pageRef);
  
    //Instantiate Extension to mimic page
    StorybankSubmissionConversionController storyconversion = new StorybankSubmissionConversionController(new ApexPages.StandardController(testws1)); 
    system.debug('### Getters');
    
    system.assertequals(5, storyconversion.getAccountFieldMap().size());
    system.assertequals(14, storyconversion.getStoryTellerFieldList().size());
    system.assertequals(8, storyconversion.getNominatorFieldList().size());
    
    }
    



}