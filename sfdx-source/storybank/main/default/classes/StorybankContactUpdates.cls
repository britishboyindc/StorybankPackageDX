public with sharing class StorybankContactUpdates {
    
public String sContactField {get;set;}
public String sFieldLabel {get;set;}
public String sSubmissionField {get;set;}
public String sAction {get;set;}
public List<SelectOption> sActions  {get;set;}
public String sType {get;set;}

public StorybankContactUpdates (String cf, String sf, Storybank_Submitted__c ss, Contact c) {
    sContactField  = cf;
    sSubmissionField  = sf;
    sFieldLabel = getfieldlabel(sContactField);
    sActions = new List<SelectOption>();
    //If Target has no value, set to no action so we don't override existing data 

    sType = getfieldtype(sContactField);

    if (sType == 'STRING' || sType == 'PHONE' || sType == 'PICKLIST' || sType == 'EMAIL' || sType == 'TEXTAREA' || sType == 'REFERENCE' ) {
    
        sActions.add(new SelectOption('Unchanged','', true));
        sActions.add(new SelectOption('Overwrite','Overwrite'));
       
            if (sType == 'TEXTAREA') {
                sActions.add(new SelectOption('Append','Append'));
            }
       
        sActions.add(new SelectOption('Do Not Update','Do Not Update'));
   
   
            if ( (String)ss.get(sSubmissionField) == (String)c.get(sContactField) ) {
                sAction = 'Unchanged';
            }
        
            else if (String.IsEmpty( (String)ss.get(sSubmissionField)) ) {
                sAction = 'Do Not Update';
            }
    
            else {
        
                if (sType == 'TEXTAREA') {
                    if (!sFieldLabel.contains('Street')) {
                        sAction = 'Append'; 
                    }
            
                    else {
    
                        if ( (String)ss.get(sSubmissionField) != (String)c.get(sContactField) ) {
                            sAction = 'Overwrite'; 
                        }
                        else {
                            sAction = 'Unchanged';
                        }
                    }  
                }
                else {
                    if ((String)ss.get(sSubmissionField) != (String)c.get(sContactField) ) {
                        sAction = 'Overwrite'; 
                    }   
                    else {
                        sAction = 'Unchanged'; 
                    }
            
                }
        
            }

    } //end main IF

    else if (sType == 'BOOLEAN') {
        if ( (BOOLEAN)ss.get(sSubmissionField) != (BOOLEAN)c.get(sContactField) ) {

            if ( (BOOLEAN)ss.get(sSubmissionField) ) {
                sAction = 'Overwrite';
            } else {
                sAction = 'Do Not Update';
            }
        }
        else {
            sAction = 'Unchanged'; 
        }
        
        sActions.add(new SelectOption('Unchanged',''));
        sActions.add(new SelectOption('Overwrite','Overwrite'));
        sActions.add(new SelectOption('Do Not Update','Do Not Update'));
    }   
 

    else if (sType == 'MULTIPICKLIST') {
        sActions.add(new SelectOption('Unchanged',''));
        sActions.add(new SelectOption('Append','Append'));
        sActions.add(new SelectOption('Overwrite','Overwrite'));
        sActions.add(new SelectOption('Do Not Update','Do Not Update'));

        String sMVPValue = (String)c.get(sContactField);
        Set<String> sMVPExistingValues = new Set<String> ();
       
        if (String.isEmpty( (String)ss.get(sSubmissionField) ) ) {

            if (String.IsEmpty(sMVPValue)) {
                sAction = 'Unchanged';
            } else { 
                sAction = 'Do Not Update';
            }

        }

        else if (!String.IsEmpty(sMVPValue)) {
            List<String> mvpvalues = sMVPValue.split(';');
            sMVPExistingValues.addall(mvpvalues);
            
            if ( !sMVPExistingValues.contains( (String)ss.get(sSubmissionField) ) ){
                sAction = 'Append'; 
            }
            else {
                sAction = 'Unchanged'; 
            }
        }
        else if (!String.isEmpty( (String)ss.get(sSubmissionField) ) ) {
            sAction = 'Overwrite'; 
        }
        else  {
            sAction = 'Unchanged'; 
        }
            
    }   
 


    else {
        sAction = sType;
        sActions.add(new SelectOption(sType,sType));
    } 
    
}

private string getfieldtype (String confield) {  
    Schema.DescribeFieldResult contactField = StorybankUtilities.getContactFieldDescription(confield);
    String typeString = String.ValueOf(contactField.getType());              
    return typeString;
}  


private string getfieldlabel (String confield) {  
    Schema.DescribeFieldResult contactField = StorybankUtilities.getContactFieldDescription(confield);
    return String.ValueOf(contactField.getlabel());              
}   
  

public static Contact setValuesonContact (Contact newContact, Storybank_Submitted__c ws, List<StorybankContactUpdates> contactFieldUpdates) {

      sObject c = newContact;
            for (StorybankContactUpdates cwu: contactFieldUpdates) {
                if (cwu.sAction == 'Overwrite' ) {
                    c.put(cwu.sContactField, ws.get(cwu.sSubmissionField)); 
                } 
                else if (cwu.sAction == 'Append' ) {
                        
                    String sAppend = (String)ws.get(cwu.sSubmissionField);
                    
                    if (sAppend != Null) {

                        if (cwu.sType == 'MULTIPICKLIST') {

                        String sDestinationMVPValue = (String)c.get(cwu.sContactField);

                                if (!String.IsEmpty(sDestinationMVPValue)) {
                                    // set up the set of values in the destination field
                                    List<String> destinationmvpvalues = sDestinationMVPValue.split(';');
                                    Set<String> sDestinationMVPExistingValues = new Set<String> ();
                                    sDestinationMVPExistingValues.addall(destinationmvpvalues);
                                             system.debug('set size: ' + sDestinationMVPExistingValues.size() );           
                                    // iterate over the list of values in the source field, append to new list
                                    List<String> sourcemvpvalues = sAppend.split(';');
                                    List<String> revisedappendvalues = new List<String> ();
                                    
                                    for (String item : sourcemvpvalues) {
                                            system.debug('item: ' + item);
                                        if ( !sDestinationMVPExistingValues.contains( item ) ){
                                            revisedappendvalues.add(item);
                                        }            
                                    }
                                     sAppend = (String)c.get(cwu.sContactField)  + ';' + String.join(revisedappendvalues, ';');

                    
                                }
                        }

                        else if (cwu.sType == 'TEXTAREA') {
                            if (!String.IsEmpty( (String)c.get(cwu.sContactField) ) ) {
                                sAppend = (String)c.get(cwu.sContactField) + '\n\n' + sAppend;
                            } 
                        }

                        else if (!String.IsEmpty( (String)c.get(cwu.sContactField) ) ) {

                            sAppend = (String)c.get(cwu.sContactField) + ' ' + sAppend;
                        }
                        c.put(cwu.sContactField, sAppend);
                    }
                }
            
            }
        return (Contact)c;    
        }

  
    
}//end wrapper class