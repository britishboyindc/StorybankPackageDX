import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fillWrapper from '@salesforce/apex/lwcUtils.fillWrapper';
import getRecord from '@salesforce/apex/lwcUtils.getRecord';
import getContact from '@salesforce/apex/lwcUtils.getContact';
import createNewStoryApproved from '@salesforce/apex/lwcUtils.createNewStoryApproved';
import fieldsForConversion from '@salesforce/apex/lwcUtils.fieldsForConversion';
import getMatches from '@salesforce/apex/lwcUtils.getMatches';
import { NavigationMixin } from 'lightning/navigation';

export default class StorybankSubmissionConversionStoryteller extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isCreateContactVisible = false;
    @track isTableVisible = false;
    @track isCurrentComponent = false;
    @track isUpdatePageComponent = false;
    @track isCreateNominatorPage = false;
    @track exContResult;
    @track nominatorEmail = '';
    @track fieldsForConversion;
    @track contact;
    @track contactWrapper = [];
    contact = {
        FirstName: '',
        LastName: '',
        Email: '',
        Phone: '',
        MailingStreet: '',
        MailingState: '',
        MailingCity: '',
        MailingPostalCode: ''
    };
    @track createdContact;
    @track nominatorOrgName = '';
    @track isCreateOrganizationPage = false;
    @track columns = [];
    connectedCallback() {
        this.getQueryVariable()
    }
    navigateToObjectRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.redirectId,
                actionName: 'view',
            },
        })
    }
    getQueryVariable() {
        var query = window.location.search.substring(1);
        var vars = query.split("&");
        var pair;
        for (let i = 0; i < vars.length; i++) {
            pair = vars[i].split("=");
            if (pair[0] == "storybank__id") {
                this.recordId = pair[1];
            }
        }
        fieldsForConversion({ context: 'storyteller' })
            .then(resultFields => {
                this.fieldsForConversion = resultFields;
            })
        getRecord({
            Id: this.recordId
        })
            .then(result => {
                this.obj = result;
                if (result.storybank__Nominator_Email_Address__c != null) {
                    this.nominatorEmail = result.storybank__Nominator_Email_Address__c;
                }
                if (result.storybank__Nominator_Organization__c != null) {
                    this.nominatorOrgName = result.storybank__Nominator_Organization__c;
                }
                fillWrapper({ context: 'Storyteller' })
                    .then(wrapper => {
                        let contwrapper = [];
                        for (let i = 0; i < wrapper.length; i++) {
                            let value = (this.obj[wrapper[i].submittedDataField] == null) ? '' : this.obj[wrapper[i].submittedDataField];
                            let title = 'contact-' + wrapper[i].currentContactField;
                            this.contact[wrapper[i].currentContactField] = value;
                            contwrapper.push({
                                fieldAPI: wrapper[i].currentContactField,
                                value: value,
                                title: title
                            });
                        }
                        this.contactWrapper = [...contwrapper];
                        getContact({
                            field: 'Email',
                            value: this.contact.Email
                        })
                            .then(exContResult => {
                                if (exContResult.length != 0) {
                                    getMatches({ fieldSetName: 'storybank__Storybank_Matches', ObjectName: 'Contact' })
                                        .then(resMap => {
                                            let columns = [];
                                            columns.push({
                                                label: 'Select', fieldName: 'Select', type: 'button', typeAttributes: {
                                                    label: 'Select',
                                                    name: 'Select',
                                                    title: 'Select',
                                                    disabled: false,
                                                    value: 'Select',
                                                    variant: ''
                                                }
                                            });
                                            for (const [key, value] of Object.entries(resMap)) {
                                                columns.push({
                                                    label: key, fieldName: value
                                                });
                                            }
                                            this.columns = [...columns];
                                        })
                                    this.isCurrentComponent = true;
                                    this.isTableVisible = true;
                                    this.isCreateContactVisible = false;
                                    this.exContResult = exContResult;
                                } else {
                                    this.isCurrentComponent = true;
                                    this.isTableVisible = false;
                                    this.isCreateContactVisible = true;
                                }
                            })
                            .catch(error => {
                                this.error = error;
                            });
                    })
            })
            .catch(error => {
                this.error = error;
            });
    }
    handleChange(event) {
        let variableName = event.target.title;
        let typedValue = event.target.value;
        var fields = variableName.split('-');
        if (this[fields[0]].hasOwnProperty(fields[1])) {
            this[fields[0]][fields[1]] = typedValue;
        }
    }
    handleSuccess(event) {
        this.createdContact = { Id: event.detail.id };
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Contact successfully created!',
                variant: 'success',
            }),
        );
        if (this.nominatorOrgName != '') {
            this.isCurrentComponent = false;
            this.isCreateOrganizationPage = true;
        } else if (this.nominatorEmail != '') {
            this.isCurrentComponent = false;
            this.isCreateNominatorPage = true;
        } else {
            createNewStoryApproved({
                currentStorybankSubmittedId: this.recordId,
                contactId: this.createdContact.Id,
                nominatorId: null,
                organizationId: null
            })
                .then(resultId => {
                    this.redirectId = resultId;
                    this.navigateToObjectRecord();
                }).catch((error) => {
                    this.error = error;
                })
        }
    }
    changeBoolean() {
        this.isTableVisible = false;
        this.isCreateContactVisible = true;
    }
    rowAction(event) {
        var recId = event.detail.row.Id;
        var name = event.detail.action.name;
        if (name === 'Select') {
            this.selectedContactId = recId;
            this.isTableVisible = false;
            this.isCreateContactVisible = false;
            this.isCurrentComponent = false;
            this.isUpdatePageComponent = true;
        }
    }
}
