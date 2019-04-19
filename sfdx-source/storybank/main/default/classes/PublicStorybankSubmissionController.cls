global with sharing class PublicStorybankSubmissionController {
/* 
Class to control public facing web page for Storybank
The class is declared as Global so that customers can clone the included page and use their own
to capture stories
*/

private Storybank_Submitted__c newws;
global List<wcategory> publiccategories {get;set;}
global String sURL {get;set;}

global PublicStorybankSubmissionController() {
   //Defaul Confirmation
    sURL = '';
    newws = new Storybank_Submitted__c(); 
    newws.Submission_URL__c = ApexPages.currentPage().geturl();
 
    publiccategories = new List<wcategory> ();
    Schema.DescribeFieldResult fieldResultd = Storybank_Submitted__c.category__c.getDescribe();
    List<Schema.PicklistEntry> pled = fieldResultd.getPicklistValues();
    for (Schema.PicklistEntry f : pled)   {
        publiccategories.add(new wcategory(f.getValue()));
    }    
}

global Storybank_Submitted__c getnewws() {
    return newws;
}

 global PageReference submit() {

    newws.Category__c = '';
    for (wcategory w: publiccategories) {
        if (w.bselected) {
            newws.Category__c += w.sCategory + ';';
        }
    }

    try {
        upsert newws;
        return getNextPage();
    }
    Catch (Exception Ex) {
        return null;
    } 

} //end submit 

global PageReference getNextPage() {
        PageReference pr;
        String FinalURL;
        if (String.IsBlank(sURL) == TRUE) {
            sURL = 'storybank__StorybankSubmissionConfirmation';
        }
            if (sURL.StartsWith('http') ) {
                FinalURL = sURL;
            }
            else {
                FinalURL = Site.getBaseUrl() + '/' + sURL;
            }

        pr = new PageReference(FinalURL);
        return pr;
 }

global class wcategory {

    global boolean bselected {get;set;}
    global string sCategory {get;set;}

    global wcategory(String scat) {
        sCategory = scat;
        bselected = false;
    }
}

}