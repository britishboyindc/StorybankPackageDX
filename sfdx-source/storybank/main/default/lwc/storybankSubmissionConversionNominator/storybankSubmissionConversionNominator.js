import { LightningElement, wire, track, api } from 'lwc';
import fieldsForConversionMethod from '@salesforce/apex/lwcUtils.fieldsForConversion';
import getContact from '@salesforce/apex/lwcUtils.getContact';
import getCurrentNominatorValues from '@salesforce/apex/lwcUtils.getCurrentNominatorValues';
import createNewStoryApproved from '@salesforce/apex/lwcUtils.createNewStoryApproved';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMatches from '@salesforce/apex/lwcUtils.getMatches';

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
    @track currentNominatorWrapper = [];
    @track columns = [];
    connectedCallback() {
        fieldsForConversionMethod({ context: 'nominator' })
            .then(fieldsForConversion => {
                this.fieldsForConversion = fieldsForConversion;
                this.isCurrentComponent = true;
            })
        getContact({
            field: 'Email',
            value: this.nominatoremail
        })
            .then(existedNominators => {
                if (existedNominators.length != 0) {
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
                    this.isTableVisible = true;
                    this.isCreateNominatorVisible = false;
                    this.existedNominators = existedNominators;
                } else {
                    this.isTableVisible = false;
                    this.isCreateNominatorVisible = true;
                }
            })
        getCurrentNominatorValues({
            Id: this.submittedrecid,
            context: 'nominatorCreatePage'
        })
            .then(currentNominator => {
                this.currentNominator = Object.assign({}, currentNominator);
                let currentNominatorWrapper = [];
                for (const [key, val] of Object.entries(currentNominator)) {
                    currentNominatorWrapper.push({
                        fieldAPI: key,
                        value: val,
                        title: 'currentNominator-' + key
                    });
                }
                this.currentNominatorWrapper = [...currentNominatorWrapper];
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
        this.createdNominator = { Id: event.detail.id };
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
    rowAction(event) {
        var recId = event.detail.row.Id;
        var name = event.detail.action.name;
        if (name === 'Select') {
            this.selectedNominatorId = recId;
            this.isTableVisible = false;
            this.isCreateNominatorVisible = false;
            this.isCurrentComponent = false;
            this.isUpdateNominatorComponent = true;
        }
    }
    changeBoolean() {
        this.isTableVisible = false;
        this.isCreateNominatorVisible = true;
    }
}
