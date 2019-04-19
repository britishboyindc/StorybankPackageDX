public with sharing class ManageStorybankSubmissions {
/* With reference to Steve Andersen's post: http://gokubi.com/archives/two-interesting-ways-to-architect-apex-triggers */ 

/* FKW - 101013 - Stripping this out as we are now using formula field (URL_Converted__c) for same purpose */ 
public static void beforeInsert(Storybank_Submitted__c[] newrecords) {

//    for (Storybank_Submitted__c w: newrecords) {
//        if (w.Video_URL__c != null) {
//           w.Embed_URL__c = ManageStorybankSubmissions.embedURL(w.Video_URL__c);
//        }
//    }
}


public static void afterUpdate(Storybank_Submitted__c[] newrecords, Map<Id, Storybank_Submitted__c> oldrecordmap) {

    List<FeedItem> newfeeds = new List<FeedItem> ();
    
    Id ChatterGroupId;
    if (Storybank_Settings__c.getValues('ChatterGroupId') != null) {
        ChatterGroupId = Storybank_Settings__c.getValues('ChatterGroupId').Target_Value__c;
    }

    for (Storybank_Submitted__c w: newrecords) {

    //If there is a Chatter Group Id in the Settings AND the current user is a member of the group
        if (ChatterGroupId != null
            && Schema.sObjectType.FeedItem.isCreateable()
            && StorybankUtilities.getGroupMemberStatus(ChatterGroupId)) 
            {
            
            //Check if Post to Chatter was checked by WF
            if (w.storybank__Post_to_Chatter__c == TRUE && oldrecordmap.get(w.Id).storybank__Post_to_Chatter__c == FALSE) {
                Feeditem nf = new Feeditem();
                nf.ParentId = ChatterGroupId;
                nf.Type = 'LinkPost';
            
                if (w.Video_URL__c != null) {
                    nf.LinkUrl = w.Video_URL__c;
                    nf.body = ' New Submission: ' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + w.Id;
                    nf.Title = 'New Video Submission'; 

                    } else if (w.Submitted_Story__c != null) {
        
                        Integer i =  w.Submitted_Story__c.length() > 255 ? 255 : w.Submitted_Story__c.length();
                        nf.LinkUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + w.Id;
                        nf.body = ' New Submission: ' + w.Submitted_Story__c.substring(0,i) + '...';
                        nf.Title = 'New Story Submission'; 
                    
                    }
                    
                    newfeeds.add(nf);
            }
        }
        }
        if (newfeeds.size()> 0) {
            //They can only insert records into the list if they are a member of the group
            // and can write to the Feed Item object
            
            insert newfeeds;
        }
    
}

/* FKW - 101013 - Stripping this out as we are now using formula field (URL_Converted__c) for same purpose */ 
//public static String embedURL (String sUrl) {
//
//    String newUrl = '';
//    if (sUrl.startsWith('http://youtu.be/')) {
//        newUrl = 'http://www.youtube.com/embed/' + sUrl.removeStart('http://youtu.be/');
//    }
//   return newUrl;
//}

} //end class