global with sharing class Storybank_Queries {
/* Tested in TEST_StoryBankConversion*/

global static List<Storybank_Approved__c> stories {get;set;}
global static Storybank_Approved__c story {get;set;}

global List<String> Categories {get;set;}
private static string sQuery;
private static string sDetailedQuery;

global Storybank_Queries() {

Categories = new List<String> ();


for (Schema.PicklistEntry p: StorybankUtilities.getStorybankFieldDescription ('Category__c').getPicklistValues() ){
Categories.add(p.getlabel());
}

}

    @RemoteAction
    global static List<Storybank_Approved__c> getStoriesbyState(String sState) {
        
        String finalquery;
        finalquery = buildquery() + ' AND Storyteller__r.MailingState = :sState';
        stories = database.query(finalquery);
        return stories;
        
    }

    @RemoteAction
    global static List<Storybank_Approved__c> getStoriesbyCategory(String sCat) {
        
        String finalquery;
        finalquery = buildquery() + ' AND Category__c INCLUDES (:sCat)';
        stories = database.query(finalquery);
        return stories;
        
    }

 @RemoteAction
    global static Storybank_Approved__c getStoryDetail(String sId) {
        
        String finalquery;
        finalquery = buildDetailedQuery() + ' AND Id = :sId';
        story = database.query(finalquery);
        return story;
        
    }

private static String buildquery() {

        if (sQuery == NULL) {
            sQuery = 'Select Id, ';
        
            List<Schema.FieldSetMember> resultFields = Schema.SObjectType.Storybank_Approved__c.FieldSets.storybank__Public_Pages.getFields();
    
                for(Schema.FieldSetMember f : resultFields) {
                  sQuery += f.getFieldPath() + ', ';
                }
    
        sQuery += ' Name FROM Storybank_Approved__c WHERE Posted__c = TRUE ';
        }
        return sQuery;
        
    }
    
private static String buildDetailedQuery() {

        if (sDetailedQuery == NULL) {
            sDetailedQuery = 'Select Id, ';
        
            List<Schema.FieldSetMember> resultFields = Schema.SObjectType.Storybank_Approved__c.FieldSets.storybank__Story_Public_Detail_Page.getFields();
    
                for(Schema.FieldSetMember f : resultFields) {
                  sDetailedQuery += f.getFieldPath() + ', ';
                }
    
        sDetailedQuery += ' Name FROM Storybank_Approved__c WHERE Posted__c = TRUE ';
        }
        return sDetailedQuery;
        
    }    
    
}