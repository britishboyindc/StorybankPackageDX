import { LightningElement, wire, track, api } from 'lwc';
import fillWrapper from '@salesforce/apex/lwcUtils.fillWrapper';
import getRecord from '@salesforce/apex/lwcUtils.getRecord';
import getContact from '@salesforce/apex/lwcUtils.getContact';
import updateContactButton from '@salesforce/apex/lwcUtils.updateContactButton';
import updateContactAndSubmittedRecords from '@salesforce/apex/lwcUtils.updateContactAndSubmittedRecords';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StorybankSubmissionConversionStoryteller extends NavigationMixin(LightningElement) {
    @api contactid;
    @api storybanksubmittedid;
    @api nominatoremail;
    @api nominatororgname;
    @track wrapper;
    @track currentStorybankSubmitted = {};
    @track contact = {};
    copyWrapper;
    @track isTableVisible = true;
    redirectId;
    @api isConversionNominator = false;
    @api isCreateNominatorOrg = false;
    connectedCallback() {
        fillWrapper({
            context: 'Storyteller',
            submittedId: this.storybanksubmittedid,
            contactId: this.contactid
        })
            .then(wrapper => {
                this.wrapper = wrapper;
                this.copyWrapper = [...wrapper];
            })
            .catch(error => {
                this.error = error;
            })
        getRecord({
            Id: this.storybanksubmittedid
        })
            .then(currentStorybankSubmitted => {
                this.currentStorybankSubmitted = currentStorybankSubmitted;
            })
        getContact({
            field: 'Id',
            value: this.contactid
        })
            .then(responseContact => {
                this.contact = responseContact[0];
            })
    }
    onAction(event) {
        let selectedName = event.target.name;
        let selectedValue = event.target.value;
        for (let i = 0; i < this.copyWrapper.length; i++) {
            if (this.copyWrapper[i].submittedDataField == selectedName) {
                let obj = Object.assign({}, this.copyWrapper[i]);
                obj.selectedAction = selectedValue;
                this.copyWrapper[i] = Object.assign({}, obj);
            }
        }
    }
    onInputChange(event) {
        let changedValue = event.target.value;
        let submittedStoryField = event.target.title;
        this.currentStorybankSubmitted[submittedStoryField] = changedValue;
    }
    onUpdateContactAndContinue() {
        var obj1 = Object.assign({}, this.contact);
        for (let i = 0; i < this.copyWrapper.length; i++) {
            if (this.copyWrapper[i].selectedAction == 'Overwrite') {
                obj1[this.copyWrapper[i].currentContactField] = this.currentStorybankSubmitted[this.copyWrapper[i].submittedDataField];
            } else if (this.copyWrapper[i].selectedAction == 'Append') {
                if (obj1[this.copyWrapper[i].currentContactField] == null) {
                    obj1[this.copyWrapper[i].currentContactField] = '';
                }
                obj1[this.copyWrapper[i].currentContactField] = obj1[this.copyWrapper[i].currentContactField] + '\n\n' + this.currentStorybankSubmitted[this.copyWrapper[i].submittedDataField];
            }
        }
        if (this.nominatororgname != '') {
            updateContactAndSubmittedRecords({
                contact: obj1,
                storybankSubmitted: this.currentStorybankSubmitted
            })
            this.isTableVisible = false;
            this.isCreateNominatorOrg = true;
        } else {
            if (this.nominatoremail != '') {
                updateContactAndSubmittedRecords({
                    contact: obj1,
                    storybankSubmitted: this.currentStorybankSubmitted
                })
                this.isTableVisible = false;
                this.isConversionNominator = true;
            } else {
                updateContactButton({
                    contact: obj1,
                    storybankSubmitted: this.currentStorybankSubmitted,
                    Id: null,
                    nominatorOrgId: null
                })
                .then(redirectId => {
                    this.redirectId = redirectId;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!',
                            variant: 'success',
                        }),
                    );
                    this.navigateToObjectRecord();
                });
            }
        }
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
}