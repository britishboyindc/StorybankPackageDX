import { LightningElement, wire, track, api } from 'lwc';
import fieldsForConversionMethod from '@salesforce/apex/lwcUtils.fieldsForConversion';
import getContact from '@salesforce/apex/lwcUtils.getContact';
import getCurrentNominatorValues from '@salesforce/apex/lwcUtils.getCurrentNominatorValues';
import createContact from '@salesforce/apex/lwcUtils.createContact';
import createNewStoryApproved from '@salesforce/apex/lwcUtils.createNewStoryApproved';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StorybankSubmissionConversionStoryteller extends NavigationMixin(LightningElement) {
    @api nominatoremail;
    @api submittedrecid;
    @api storytellerid;
    @api nominatororgid;
    @track isTableVisible = false;
    @track isCreateNominatorVisible = false;
    @track existedNominators;
    @track currentNominator = {};
    @track isUpdateNominatorComponent = false;
    @track isCurrentComponent = false;
    @track fieldsForConversion;
    connectedCallback() {
        fieldsForConversionMethod({ context: 'nominator' })
        .then(fieldsForConversion => {
            this.fieldsForConversion = fieldsForConversion;
            this.isCurrentComponent = true;
        });
        getContact({
            field: 'Email',
            value: this.nominatoremail
        })
        .then(existedNominators => {
            if (existedNominators.length != 0) {
                this.isTableVisible = true;
                this.isCreateNominatorVisible = false;
                this.existedNominators = existedNominators;
            } else {
                this.isTableVisible = false;
                this.isCreateNominatorVisible = true;
            }
        });

        getCurrentNominatorValues({
            Id: this.submittedrecid,
            context: 'nominatorCreatePage'
        })
        .then(currentNominator => {
            this.currentNominator = Object.assign({}, currentNominator);
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
        createContact({
            contact: this.currentNominator
        })
        .then(result => {
            this.createdNominator = result;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Contact successfully created!',
                    variant: 'success',
                }),
            );
            createNewStoryApproved({
                currentStorybankSubmittedId: this.submittedrecid,
                contactId: this.storytellerid,
                nominatorId: this.createdNominator.Id,
                organizationId: this.nominatororgid
            })
            .then(storyApprovedId => {
                this.storyApprovedId = storyApprovedId;
                this.navigateToObjectRecord();
            }).catch((error) => {
                this.error = error;
            });
        })
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
        this.selectedNominatorId = event.target.name;
        this.isTableVisible = false;
        this.isCreateNominatorVisible = false;
        this.isCurrentComponent = false;
        this.isUpdateNominatorComponent = true;
    }
    changeBoolean() {
        this.isTableVisible = false;
        this.isCreateNominatorVisible = true;
    }
}