import { api, LightningElement, wire, track } from 'lwc';
import handleMixUpsert from '@salesforce/apex/MixController.handleMixUpsert';
import getMix from '@salesforce/apex/MixController.getMix';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MixBuilder extends LightningElement
{
    @api recordId;

    @track selectedContactId;
    @track mixName;
    @track selectedSongs = [];

    @wire(getMix, { mixId: '$recordId' })
    wiredMix({ error, data }) {
        if (data) {
            data = JSON.parse(data);
            this.mixName = data.mixName;
            this.selectedContactId = data.contactId;
            this.selectedSongs = data.selectedSongs;
        } else if (error) {
            console.error('Error loading mix', error);
        }

        if(!this.mixName)
        {
            this.mixName = 'New Mix';
        }
    }

    handleSongsEvent(event) {
        this.selectedSongs = event.detail;
    }

    handleNameEvent(event) {
        this.mixName = event.detail.value;
    }

    handleContactEvent(event) {
        this.selectedContactId = event.detail.recordId;
    }

    closeModal() {
        const modal = this.template.querySelector('section[role="dialog"]');
        const backdrop = this.template.querySelector('.slds-backdrop');

        if (modal) {
            modal.classList.remove('slds-fade-in-open');
            modal.classList.add('slds-hidden');
        }
        if (backdrop) {
            backdrop.classList.remove('slds-backdrop_open');
            backdrop.classList.add('slds-hidden');
        }

        window.history.back();
    }

    handleSave() {
        if(!this.mixValid())
        {
            return;
        }

        const mix = {
            mixId: this.recordId,
            mixName: this.mixName,
            contactId: this.selectedContactId,
            selectedSongs: this.selectedSongs.map(song => song)
        };

        handleMixUpsert({ mixJson: JSON.stringify(mix) })
            .then(result => {
                this.dispatchEvent(new CustomEvent('mixsave', { detail: result }));
                this.closeModal();
            })
            .catch(error => {
                console.error('Error saving mix', error);
            });
    }

    mixValid()
    {
        if (!this.mixName) {
            this.dispatchToastError('Please enter a mix name.');
            return false;
        }

        if (!this.selectedContactId) {
            this.dispatchToastError('Please select a contact.');
            return false;
        }

        if (this.selectedSongs.length > 20 || this.selectedSongs.length < 1) {
            this.dispatchToastError('Mixes must have between 1 and 20 songs.');
            return false;
        }

        if (this.selectedSongs.reduce((acc, song) => acc + song.Length__c, 0) > 90) {
            this.dispatchToastError('Mixes must be 90 minutes or less.');
            return false;
        }

        return true;
    }

    dispatchToastError(message) {
        const toast = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        });

        this.dispatchEvent(toast);
    }
}
