import { LightningElement, wire, track, api } from 'lwc';
import fieldsForConversionMethod from '@salesforce/apex/lwcUtils.fieldsForConversion';
import getAccount from '@salesforce/apex/lwcUtils.getAccount';
import getCurrentNominatorValues from '@salesforce/apex/lwcUtils.getCurrentNominatorValues';
import createAccount from '@salesforce/apex/lwcUtils.createAccount';
import createNewStoryApproved from '@salesforce/apex/lwcUtils.createNewStoryApproved';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

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
    connectedCallback() {
        fieldsForConversionMethod({ context: 'nominatorOrg' })
        .then(fieldsForConversion => {
            this.fieldsForConversion = fieldsForConversion;
            this.isCurrentComponent = true;
        });
        getAccount({
            name: this.nominatororgname
        })
            .then(existedAccs => {
                if (existedAccs.length != 0) {
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
    handleCreate() {
        createAccount({
            account: this.currentOrg
        })
        .then(result => {
            this.createdOrganization = result;
            this.nominatororgid = result.Id;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Account successfully created!',
                    variant: 'success',
                }),
            );
            this.navigateToComponentOrCreateStoryApproved();
        });
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
            });
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
    onSelectClick(event) {
        this.nominatororgid = event.target.name;
        this.navigateToComponentOrCreateStoryApproved();
    }
    changeBoolean() {
        this.isTableVisible = false;
        this.isCreateOrgVisible = true;
    }
}