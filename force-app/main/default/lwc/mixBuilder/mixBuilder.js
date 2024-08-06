import { api, LightningElement, wire, track } from 'lwc';
import handleMixUpsert from '@salesforce/apex/MixBuilderController.handleMixUpsert';
import getMix from '@salesforce/apex/MixBuilderController.getMix';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const SONG_URL = '/lightning/r/Song__c/';
const MIX_URL = '/lightning/r/Mix__c/';
const VIEW = '/view';

export default class MixBuilder extends LightningElement
{
    @api recordId;
    @api contactId;

    @track mixName;
    @track selectedSongs = [];

    isLoading = false;

    // @wire(getMix, { mixId: '$recordId' })
    // wiredMix({ error, data }) {
    //     if (data) {
    //         data = JSON.parse(data);
    //         this.mixName = data.mixName;
    //         this.contactId = data.contactId;
    //         this.selectedSongs = data.selectedSongs.map(song => ({
    //             ...song,
    //             url: SONG_URL + song.Id + VIEW
    //         }));
    //     } else if (error) {
    //         console.error('Error loading mix', error);
    //         this.dispatchToastError('Error loading mix', error.message);
    //     }

    //     if(!this.mixName) {
    //         this.mixName = 'New Mix';
    //     }
    // }

    //removed wire as it doesn't allow for cashable=false, which is a fix for the issue of the mix not updating after a song is added/removed
    connectedCallback() {
        if (this.recordId) {
            getMix({ mixId: this.recordId })
            .then(result => {
                try {
                    const parsedResult = JSON.parse(result);
    
                    this.mixName = parsedResult.mixName;
                    this.contactId = parsedResult.contactId;
    
                    this.selectedSongs = parsedResult.selectedSongs.map(song => ({
                        ...song,
                        url: SONG_URL + song.Id + VIEW
                    }));
                } catch (error) {
                    console.error('Error parsing result', error);
                    this.dispatchToastError('Error parsing result', error.message);
                }
            })
            .catch(error => {
                console.error('Error loading mix', error);
                this.dispatchToastError('Error loading mix', error.message);
            });
        } else {
            this.mixName = 'New Mix';
        }
    }

    handleSongsEvent(event) {
        this.selectedSongs = event.detail;
        this.isLoading = false;
    }

    handleNameEvent(event) {
        this.mixName = event.detail.value;
    }

    handleContactEvent(event) {
        this.contactId = event.detail.recordId;
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

        this.navigateToMixView();
    }

    handleCancel() {
        this.closeModal();
    }

    navigateToMixView() {
        if (this.recordId) {
            const url = MIX_URL + this.recordId + VIEW;
            window.location.href = url;
        } else {
            window.history.back();
        }
    }

    handleSave() {
        if(!this.mixValid()) {
            return;
        }

        this.isLoading = true;

        const mix = {
            mixId: this.recordId,
            mixName: this.mixName,
            contactId: this.contactId,
            selectedSongs: this.selectedSongs.map(song => song)
        };

        handleMixUpsert({ mixJson: JSON.stringify(mix) })
        .then(result => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Mix saved successfully.',
                variant: 'success'
            }));

            this.recordId = result;
            this.closeModal();
        })
        .catch(error => {
            this.dispatchToastError(error.body.message);
        });

        this.isLoading = false;
    }

    mixValid()
    {
        if (!this.mixName) {
            this.dispatchToastError('Please enter a mix name.');
            return false;
        }

        if (!this.contactId) {
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
