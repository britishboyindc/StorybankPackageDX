import { LightningElement, api, track } from 'lwc';
import fillWrapper from '@salesforce/apex/lwcUtils.fillWrapper';
import getCurrentNominatorValues from '@salesforce/apex/lwcUtils.getCurrentNominatorValues';
import getContact from '@salesforce/apex/lwcUtils.getContact';
import updateContactButton from '@salesforce/apex/lwcUtils.updateContactButton';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StorybankSubmissionConversionStoryteller extends NavigationMixin(LightningElement) {
    @api storytellerid;
    @api submittedrecid;
    @api nominatorid;
    @api nominatororgid;
    @track wrapper;
    @track currentNominatorValues;
    actionArray = [];
    contact;
    connectedCallback() {
        fillWrapper({ context: 'Nominator', submittedId: this.submittedrecid, contactId: this.nominatorid })
            .then(wrapper => {
                this.wrapper = wrapper;
                this.copyWrapper = [...wrapper];
            })
            .catch(error => {
                this.error = error;
            })
        getCurrentNominatorValues({
            Id: this.submittedrecid,
            context: 'nominatorUpdatePage'
        })
            .then(currentNominatorValues => {
                this.currentNominatorValues = Object.assign({}, currentNominatorValues);
            })
        getContact({
            field: 'Id',
            value: this.nominatorid
        })
            .then(responseContact => {
                this.contact = responseContact[0];
            })
    }
    onInputChange(event) {
        let changedValue = event.target.value;
        let submittedNominatorField = event.target.title;
        this.currentNominatorValues[submittedNominatorField] = changedValue;
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
    onUpdateContactAndFinish() {
        var obj1 = Object.assign({}, this.contact);
        for (let i = 0; i < this.copyWrapper.length; i++) {
            if (this.copyWrapper[i].selectedAction == 'Overwrite') {
                obj1[this.copyWrapper[i].currentContactField] = this.currentNominatorValues[this.copyWrapper[i].submittedDataField];
            } else if (this.copyWrapper[i].selectedAction == 'Append') {
                if (obj1[this.copyWrapper[i].currentContactField] == null) {
                    obj1[this.copyWrapper[i].currentContactField] = '';
                }
                obj1[this.copyWrapper[i].currentContactField] = obj1[this.copyWrapper[i].currentContactField] + '\n\n' + this.currentNominatorValues[this.copyWrapper[i].submittedDataField];
            }
        }
        updateContactButton({
            contact: obj1,
            storybankSubmitted: this.currentNominatorValues,
            Id: this.storytellerid,
            nominatorOrgId: this.nominatororgid
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
            })
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