@isTest
private class TEST_Storybank_Creation {
    
@isTest
static void test_basic_storycreation() {
    
    PageReference pageRef = Page.Storyteller_Form;
    Test.setCurrentPage(pageRef);
  
    //Instantiate Controller to mimic page
    PublicStorybankSubmissionController storycreation = new PublicStorybankSubmissionController();
    storycreation.sURL = 'StorybankSubmissionConfirmation';

    storycreation.newws.Agree_to_Terms_of_Use__c = TRUE;
    storycreation.newws.First_Name__c = 'TestF';
    storycreation.newws.Last_Name__c = 'TestL';
    storycreation.newws.Email_Address__c = 'testselfnew @bfcclient.com'; //set to fail
    storycreation.newws.City__c = 'Washington';
    storycreation.newws.State_pick__c = 'DC';
    storycreation.newws.Postal_Code__c = '20005';
    storycreation.newws.Gender__c = 'Male';
    storycreation.newws.Ethnicity__c = 'White';
    storycreation.newws.Age_range__c = '35-64';
    
    storycreation.getnewws();

    
    try {
        storycreation.submit();
    }
    Catch (Exception Ex) {
        system.debug(Ex.getmessage());  
    }
    //Fix Email
    storycreation.newws.Email_Address__c = 'testselfnew@bfcclient.com'; //set to fail
    String sConfirmURL = storycreation.submit().getUrl();
    system.assert(sConfirmURL.contains('StorybankSubmissionConfirmation'));

    Storybank_Submitted__c wconfirm = [Select Id, Name, Category__c FROM Storybank_Submitted__c];
}

    @isTest
    static void test_basic_storycreationnoURL() {

        PageReference pageRef = Page.Storyteller_Form;
        Test.setCurrentPage(pageRef);

        //Instantiate Controller to mimic page
        PublicStorybankSubmissionController storycreation = new PublicStorybankSubmissionController();

        storycreation.newws.Agree_to_Terms_of_Use__c = TRUE;
        storycreation.newws.First_Name__c = 'TestF';
        storycreation.newws.Last_Name__c = 'TestL';
        storycreation.newws.Email_Address__c = 'testselfnew @bfcclient.com'; //set to fail
        storycreation.newws.City__c = 'Washington';
        storycreation.newws.State_pick__c = 'DC';
        storycreation.newws.Postal_Code__c = '20005';
        storycreation.newws.Gender__c = 'Male';
        storycreation.newws.Ethnicity__c = 'White';
        storycreation.newws.Age_range__c = '35-64';

        storycreation.getnewws();


        try {
            storycreation.submit();
        }
        Catch (Exception Ex) {
            system.debug(Ex.getmessage());
        }
        //Fix Email
        storycreation.newws.Email_Address__c = 'testselfnew@bfcclient.com'; //set to fail
        String sConfirmURL = storycreation.submit().getUrl();
        system.assert(sConfirmURL.contains('StorybankSubmissionConfirmation'));

        Storybank_Submitted__c wconfirm = [Select Id, Name, Category__c FROM Storybank_Submitted__c];
    }
    
}