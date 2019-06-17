import { LightningElement, wire, track, api } from 'lwc';
import fieldsForConversionMethod from '@salesforce/apex/lwcUtils.fieldsForConversion';
import getAccount from '@salesforce/apex/lwcUtils.getAccount';
import getCurrentNominatorValues from '@salesforce/apex/lwcUtils.getCurrentNominatorValues';
import createNewStoryApproved from '@salesforce/apex/lwcUtils.createNewStoryApproved';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMatches from '@salesforce/apex/lwcUtils.getMatches';

export default class StorybankSubmissionConversionNomOrg extends NavigationMixin(LightningElement) {
    @api nominatoremail;
    @api submittedrecid;
    @api storytellerid;
    @api nominatororgname;
    @track isTableVisible = false;
    @track isCreateOrgVisible = false;
    @track existedOrganizations;
    @track currentOrg = {};
    @track isCurrentComponent = false;
    @track fieldsForConversion;
    @track isCreateNominatorPage = false;
    @track nominatororgid = '';
    storyApprovedId = '';
    @track columns = [];
    @track currentOrgWrapper = [];
    connectedCallback() {
        fieldsForConversionMethod({ context: 'nominatorOrg' })
            .then(fieldsForConversion => {
                this.fieldsForConversion = fieldsForConversion;
                this.isCurrentComponent = true;
            })
        getAccount({
            name: this.nominatororgname
        })
            .then(existedAccs => {
                if (existedAccs.length != 0) {
                    getMatches({ fieldSetName: 'storybank__Storybank_Nominating_Organization', ObjectName: 'Account' })
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
                    this.isTableVisible = true;
                    this.isCreateOrgVisible = false;
                    this.existedOrganizations = existedAccs;
                } else {
                    this.isTableVisible = false;
                    this.isCreateOrgVisible = true;
                }
            })
        getCurrentNominatorValues({
            Id: this.submittedrecid,
            context: 'nominatorOrganization'
        })
            .then(currentOrg => {
                this.currentOrg = Object.assign({}, currentOrg);
                let currentOrgWrapper = [];
                for (const [key, val] of Object.entries(currentOrg)) {
                    currentOrgWrapper.push({
                        fieldAPI: key,
                        value: val,
                        title: 'currentOrg-' + key
                    });
                }
                this.currentOrgWrapper = [...currentOrgWrapper];
            })
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
        this.nominatororgid = event.detail.id;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account successfully created!',
                variant: 'success',
            }),
        );
        this.navigateToComponentOrCreateStoryApproved();
    }
    navigateToComponentOrCreateStoryApproved() {
        if (this.nominatoremail != '') {
            this.isCurrentComponent = false;
            this.isCreateNominatorPage = true;
        } else {
            createNewStoryApproved({
                currentStorybankSubmittedId: this.submittedrecid,
                contactId: this.storytellerid,
                nominatorId: null,
                organizationId: this.nominatororgid
            })
                .then(res => {
                    this.storyApprovedId = res;
                    this.navigateToObjectRecord();
                }).catch((error) => {
                    this.error = error;
                })
        }
    }
    navigateToObjectRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.storyApprovedId,
                actionName: 'view',
            },
        })
    }
    rowAction(event) {
        var name = event.detail.action.name;
        this.nominatororgid = event.detail.row.Id;
        if (name === 'Select') {
            this.nominatororgid = event.detail.row.Id;
            this.navigateToComponentOrCreateStoryApproved();
        }
    }
    changeBoolean() {
        this.isTableVisible = false;
        this.isCreateOrgVisible = true;
    }
}
