/* With reference to Steve Andersen's post: http://gokubi.com/archives/two-interesting-ways-to-architect-apex-triggers */
 
trigger ManageStorybankSubmissions on Storybank_Submitted__c (before Insert, after update) { 

      if(Trigger.isInsert && Trigger.isBefore){
          ManageStorybankSubmissions.beforeInsert(Trigger.new); 
      }

    if(Trigger.isUpdate && Trigger.isAfter){
          ManageStorybankSubmissions.afterUpdate(Trigger.new, Trigger.oldmap); 
      }  
      
   }