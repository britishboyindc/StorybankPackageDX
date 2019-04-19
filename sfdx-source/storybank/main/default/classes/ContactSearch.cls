public class ContactSearch {

   
    public Static List<Contact> emailsearch (String sEmail) {
    
    String searchquery = 'FIND \'' + sEmail +  '\' IN ALL FIELDS RETURNING Contact(';
   
    Set<String> sFields = ContactSearch.getsFieldsfromSet();
    
    for (StorybankFieldsStoryteller__c s: StorybankFieldsStoryteller__c.getall().values() ) { 
         sFields.add(s.Name);
    }
    
    List<String> sJoin = new List<String> ();
    sJoin.addall(sFields);
    searchquery += String.join(sJoin, ',');
        return executeSearch(searchquery);
    }

    public Static List<Contact> emailsearchNominator (String sEmail) {

    String searchquery = 'FIND \'' + sEmail +  '\' IN ALL FIELDS RETURNING Contact(';
    
    Set<String> sFields = ContactSearch.getsFieldsfromSet();
    
     for (StorybankFieldsNominator__c s: StorybankFieldsNominator__c.getall().values() ) { 
         sFields.add(s.Name);
    }
    List<String> sJoin = new List<String> ();
    sJoin.addall(sFields);
    searchquery += String.join(sJoin, ',');
        return executeSearch(searchquery);
    }
    

    private Static List<Contact> executeSearch (String sQuery) {
    sQuery += ', AccountId, Account.Name, CreatedDate, CreatedById, Id )';
     
    List<List<SObject>> searchList = search.query(sQuery);
    Contact [] cons = ((List<Contact>)searchList[0]);
    return cons;
    }

    public Static List<Account> namesearch (String sName) {


    String searchquery = 'FIND \'' + sName +  '\' IN ALL FIELDS RETURNING Account(';

    List<Schema.FieldSetMember> resultFields = Schema.SObjectType.Account.FieldSets.storybank__Storybank_Nominating_Organization.getFields();

     for(Schema.FieldSetMember f : resultFields) {
         searchquery += f.getFieldPath() + ',';
        } 
    
    searchquery += ' CreatedDate, CreatedById, Id )';
    
    List<List<SObject>> searchList = search.query(searchquery);
    Account [] accts = ((List<Account>)searchList[0]);
    return accts;
    }

private static Set<String> getsFieldsfromSet () {
 Set<String> sFields = new Set<String> ();
    
    List<Schema.FieldSetMember> resultFields = Schema.SObjectType.Contact.FieldSets.storybank__Storybank_Matches.getFields();

     for(Schema.FieldSetMember f : resultFields) {
         //searchquery += f.getFieldPath() + ',';
            sFields.add(f.getFieldPath());
        } 
return sFields;
}

}