public with sharing class StorybankSubmissionConversionController {

//To enable updates for batches to be called via buttons
private final Storybank_Submitted__c ws;
public Storybank_Approved__c rs {get;set;}

public List<Contact> cons {get;set;}
private Map<Id,Contact> consmap;

public List<Account> accts {get;set;}
public Account na {get;set;}

public Contact newContact {get;set;}
public Boolean bshownewcontact {get;set;}
public Boolean bshowsubmitter {get;set;}
public Boolean bshowsubmitteraccount {get;set;}

private Map<String, Storybank_Settings__c> storymap;
public Map<String, StorybankFieldsStoryteller__c> storytellerFieldmap {get;set;} 
public Map<String, StorybankFieldsNominator__c> nominatorFieldmap {get;set;}
public Map<String, Storybank_Fields_Nominator_Org__c> nominatorOrgFieldmap {get;set;}

Public Account ia {get;set;}
String selectedAccountId;
Id SelectedContactId;

public List<StorybankContactUpdates> contactFieldUpdates {get;set;}

// The extension constructor initializes the private member 
//variable by using the getRecord method from the standard controller.
    
public StorybankSubmissionConversionController (ApexPages.StandardController stdController) {
    System.debug('bshowsubmitter '+bshowsubmitter);
    
    System.debug('StorybankSubmissionConversionController');
    System.debug('Storybank_Submitted__c: '+ws);
    storytellerFieldmap = StorybankFieldsStoryteller__c.getAll(); 
    System.debug('storytellerFieldmap: '+storytellerFieldmap);     
    nominatorFieldmap = StorybankFieldsNominator__c.getAll(); 
    System.debug('nominatorFieldmap: '+nominatorFieldmap);
    nominatorOrgFieldmap = Storybank_Fields_Nominator_Org__c.getall();
    System.debug('nominatorOrgFieldmap: '+nominatorOrgFieldmap);

    List<String> sFields = new List<String> ();
    
    sFields.addall(StorybankUtilities.getNominatorOrgSubmittedFields(Storybank_Fields_Nominator_Org__c.getall().values()));    
    sFields.addall(StorybankUtilities.getSubmittedFields(storybank__Storybank_Map_Submitted_Approved__c.getall().values()));    
    sFields.addall(StorybankUtilities.getNominatorContactSubmittedFields(StorybankFieldsNominator__c.getall().values()));
    sFields.addall(StorybankUtilities.getStorytellerSubmittedFields(StorybankFieldsStoryteller__c.getall().values()));
    
    
    //Fails in Test Context
    if (!test.IsRunningTest()) {
    stdController.addfields(sFields);
    }
    
    this.ws = (Storybank_Submitted__c)stdController.getRecord();
    storymap = Storybank_Settings__c.getAll();
    
        
    if (storymap.containskey('DefaultAccountId') && storymap.get('DefaultAccountId').Target_Value__c != NULL) {
        selectedAccountId = storymap.get('DefaultAccountId').Target_Value__c;
        ia = [Select Id, Name from Account WHERE Id = :selectedAccountId];
    }
                
    bshownewcontact = FALSE;
    bshowsubmitter = TRUE;
    cons = contactSearch.emailsearch(ws.Email_Address__c);
        
    createreviewedsubmission();
        
    if (cons.size() == 0) {//no matches found
        createnewstorytellercontact();
    }
    else {
        consmap = new Map<Id, Contact> (cons);
    }
        
}
    
public void createnewstorytellercontact () {
    System.debug('createnewstorytellercontact');
    bshownewcontact = TRUE;
    cons.clear();
 
    newContact = new Contact();
    if (ia != NULL) {
        newContact.AccountId = ia.Id;
    }

    sObject c = newContact;
 
    if (Storybank_Settings__c.getValues('StorytellerRecordTypeId').Target_Value__c != null) {
        c.put('RecordTypeId',Storybank_Settings__c.getValues('StorytellerRecordTypeId').Target_Value__c);
    }
    for (String fieldName : storytellerFieldmap.keySet()){
        if (storytellerFieldmap.get(fieldname).Contact_object_fieldname__c != null) {
        c.put(fieldName, ws.get(storytellerFieldmap.get(fieldname).Contact_object_fieldname__c));
        }
    }
        
}
    
public void createnewnominatorcontact () {
    System.debug('createnewnominatorcontact');
    bshownewcontact = TRUE;
    cons.clear();
    
    if (na != null && na.Id != null) {
        selectedAccountId = na.Id;
    }
    
    
    newContact = new Contact();
    if (String.IsBlank(selectedAccountId) == FALSE) {
        newContact.AccountId = selectedAccountId;
    }
    
    sObject c = newContact;
    if (Storybank_Settings__c.getValues('NominatorRecordTypeId').Target_Value__c != null) {
        c.put('RecordTypeId',Storybank_Settings__c.getValues('NominatorRecordTypeId').Target_Value__c);
    }
    for (String fieldName : nominatorFieldmap.keySet()){
        if (nominatorFieldmap.get(fieldname).Contact_object_fieldname__c != null) {
        c.put(fieldName, ws.get(nominatorFieldmap.get(fieldname).Contact_object_fieldname__c));
        }
    }
    
}
    
public pagereference submitnewnominatorcontact () {
    try {
        insert newContact;
        rs.Submitter__c = newContact.Id;
        return convertsubmission();
    }    
    Catch (Exception Ex) {
      
    }
    return null;  
}
    
public pagereference createStoryTellerRecord() {
    try {
        System.debug('createStoryTellerRecord');
    
        //for updates, process field updates
        if (contactFieldUpdates != null) {//existing contact selected  
        newContact = StorybankContactUpdates.setValuesonContact (newContact, ws, contactFieldUpdates);
        }
        upsert newContact;
        
        rs.Storyteller__c = newContact.Id;
        return NominatorCheck();
        
    } 
    Catch (Exception Ex) {
        return null;  
    }
    
}
 
public pagereference createNominatorRecord() {
    try {
    
        //for updates, process field updates
        if (contactFieldUpdates != null) {//existing contact selected  
            newContact = StorybankContactUpdates.setValuesonContact (newContact, ws, contactFieldUpdates);
            }
            upsert newContact;
            
            rs.Submitter__c = newContact.Id;
            return convertsubmission();
            
    } 
    Catch (Exception Ex) {
        return null;  
    }
    
}


public pagereference submitnewaccount () {
    System.debug('submitnewaccount');
    
    try {
        insert na;
        rs.Nominating_Organization__c = na.Id;
        selectedAccountId = na.Id;
        return NominatorContactCheck();
    } 
    Catch (Exception Ex) {
        return null;  
    }
}
    
    
public pagereference createnewaccount () {
    accts.clear();
    na = new Account();
    sObject a = na; 
    if (Storybank_Settings__c.getValues('NominatorOrgRecordTypeId').Target_Value__c != null) {
        na.put('RecordTypeId',Storybank_Settings__c.getValues('NominatorOrgRecordTypeId').Target_Value__c);
    }
        for (String sorg: nominatorOrgFieldmap.keyset() ) {
            if (nominatorOrgFieldmap.get(sorg).storybank__Storybank_Submitted_Nominator_Org_Field__c != null) {
               a.put(sorg, ws.get(nominatorOrgFieldmap.get(sorg).storybank__Storybank_Submitted_Nominator_Org_Field__c));
            }
        }
    bshowsubmitteraccount = TRUE;
    return null;  
    }
    



public PageReference setSelected(){
    //to ensure selection is unique, check if in unique set
    if (ApexPages.currentPage().getParameters().get('cid') != null) {
        newContact = consmap.get(ApexPages.currentPage().getParameters().get('cid'));
        
              
        contactFieldUpdates = new List<StorybankContactUpdates> ();
        for (StorybankFieldsStoryteller__c s: [Select Name, Contact_object_fieldname__c 
                                              FROM StorybankFieldsStoryteller__c 
                                              WHERE Display_Order__c != NULL AND Contact_object_fieldname__c != null
                                              ORDER By Display_Order__c ASC, Name ASC ]) {
            contactFieldUpdates.add( new StorybankContactUpdates(s.Name, s.Contact_object_fieldname__c,ws, newContact));
        }
        
        rs.Storyteller__c = ApexPages.currentPage().getParameters().get('cid');
        //return NominatorCheck();
        
        return page.StorybankSubmissionUpdateStoryteller;
    } else {    
        return null;
    }
}
    
public PageReference setSelectedNominator(){
    //to ensure selection is unique, check if in unique set
      if (ApexPages.currentPage().getParameters().get('cid') != null) {

        newContact = consmap.get(ApexPages.currentPage().getParameters().get('cid'));
              
        contactFieldUpdates = new List<StorybankContactUpdates> ();

        for (StorybankFieldsNominator__c s: [Select Name, Contact_object_fieldname__c
                                             FROM StorybankFieldsNominator__c 
                                             WHERE Display_Order__c != NULL AND Contact_object_fieldname__c != null
                                             Order By Display_Order__c ASC, Name ASC ]) {
            contactFieldUpdates.add( new StorybankContactUpdates(s.Name, s.Contact_object_fieldname__c, ws, newContact));
        }
        
        rs.Submitter__c = ApexPages.currentPage().getParameters().get('cid');
        //return NominatorCheck();
        
        return page.StorybankSubmissionUpdateNominator;
    } else {    

        return null;
    }
}
    
public PageReference setSelectedAccount(){
    System.debug('setSelectedAccount');
    //to ensure selection is unique, check if in unique set
    if (ApexPages.currentPage().getParameters().get('aid') != null) {
        rs.Nominating_Organization__c = ApexPages.currentPage().getParameters().get('aid');
        selectedAccountId = ApexPages.currentPage().getParameters().get('aid');
        return NominatorContactCheck();
    }
    return null;
}  
    

   
private pagereference NominatorCheck () {
   System.debug('NominatorCheck');
    if (ws.Nominator_Organization__c != null) {//go to select an org page
        accts = contactSearch.namesearch(ws.Nominator_Organization__c);
            
        if (accts.size() == 0) {
            createnewaccount();
            bshowsubmitteraccount = TRUE;
        }
   
        return page.StorybankSubmissionConversionNomOrg;
    } else { //Check if there is a nominator       
        return NominatorContactCheck ();
    }
}

 private pagereference NominatorContactCheck () {
    System.debug('NominatNominatorContactCheckorCheck');
    if (ws.Nominator_Email_Address__c != null) {//go to select an org page
        Cons = contactSearch.emailsearchNominator(ws.Nominator_Email_Address__c);
            
        bshownewcontact = FALSE;
            
        if (cons.size() == 0) {
            createnewnominatorcontact();
            bshownewcontact = TRUE;
        }
        else {
            consmap = new Map<Id, Contact> (cons);
        }
   
        return page.StorybankSubmissionConversionNominator;
    
    } else {        
        return convertsubmission();
    }
} 
   
private void createreviewedsubmission() {
   System.debug('createreviewedsubmission');
    Id rtypeId;

    if (storymap.containskey(ws.RecordTypeId) ) {
        rtypeId = storymap.get(ws.RecordTypeId).Target_Value__c;
    }
    if (rtypeId != null) {
        rs = new Storybank_Approved__c(RecordTypeId = rtypeId);
    } else {
        rs = new Storybank_Approved__c();
    }
   
}

public pagereference convertsubmission () {
    System.debug('convertsubmission');

    rs.Name = ws.Storybank_Name__c;
    if (rs.Name == null) {
        rs.Name = 'Story from ' + ws.First_Name__c + ' ' + ws.Last_Name__c;
    }
    /*
    List<Schema.FieldSetMember> resultFields = Schema.SObjectType.Storybank_Submitted__c.FieldSets.storybank__Conversion.getFields();
    sObject rso = rs;
    for (Schema.FieldSetMember f : resultFields) {
        rso.put(f.getFieldPath(), ws.get(f.getFieldPath())); 
    }
    */
    sObject rso = rs;
    for (storybank__Storybank_Map_Submitted_Approved__c s: storybank__Storybank_Map_Submitted_Approved__c.getall().values() ) {
        rso.put(s.Name, ws.get(s.storybank__Storybank_Submitted_Story_Field__c));
    } 
    
    try {
        insert rs;
        ws.Status__c = 'Converted';
        update ws;
        return new ApexPages.StandardController(rs).view();
    } 
    catch (Exception Ex) {
        return null;
    }
}
 
 
//Page Utilities  
public List<String> getAccountFieldMap() {

List<Decimal> iSort = new List<Decimal> ();
Map<Decimal, String> mFieldMap = new Map<Decimal, String> ();
for (Storybank_Fields_Nominator_Org__c nomorg: nominatorOrgFieldmap.values() ) {
    iSort.add(nomorg.storybank__Display_Order__c);
        mFieldMap.put(nomorg.storybank__Display_Order__c, nomorg.name);
    }
    
iSort.sort();
List<String> sFields = new List<String> ();

for (Decimal i: iSort) {
sFields.add(mFieldMap.get(i));
}
return sFields;

}

public List<String> getStoryTellerFieldList() {

List<Decimal> iSort = new List<Decimal> ();
Map<Decimal, String> mFieldMap = new Map<Decimal, String> ();
for (StorybankFieldsStoryteller__c stry: storytellerFieldmap.values() ) {
    iSort.add(stry.storybank__Display_Order__c);
    mFieldMap.put(stry.storybank__Display_Order__c, stry.Name);
    }
    
iSort.sort();
List<String> sFields = new List<String> ();

for (Decimal i: iSort) {
sFields.add(mFieldMap.get(i));
}
return sFields;

}

public List<String> getNominatorFieldList() {

List<Decimal> iSort = new List<Decimal> ();
Map<Decimal, String> mFieldMap = new Map<Decimal, String> ();
for (StorybankFieldsNominator__c stry: nominatorFieldmap.values() ) {
    iSort.add(stry.storybank__Display_Order__c);
    mFieldMap.put(stry.storybank__Display_Order__c, stry.Name);
    }
    
iSort.sort();
List<String> sFields = new List<String> ();

for (Decimal i: iSort) {
sFields.add(mFieldMap.get(i));
}
return sFields;

}

  
} //end controller