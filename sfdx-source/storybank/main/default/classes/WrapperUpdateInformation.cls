public with sharing class WrapperUpdateInformation {
    @AuraEnabled public String contactLabelField { get; set; }
    @AuraEnabled public String submittedDataField { get; set; }
    @AuraEnabled public List<wrapperActions> action { get; set; }
    @AuraEnabled public String currentContactField { get; set; }
    @AuraEnabled public String selectedAction { get; set; }
    public WrapperUpdateInformation(String cF, String sDF, List<String> a, String cC, String sA) {
        contactLabelField = cF;
        submittedDataField = sDF;
        List<wrapperActions> lwa = new List<wrapperActions>();
        for (String s : a) {
            lwa.add(new wrapperActions(s));
        }
        action = lwa;
        currentContactField = cC;
        selectedAction = sA;
    }
    public class wrapperActions {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        public wrapperActions(String a) {
            label = a;
            value = a;
        }
    }
}
