import { api, LightningElement, wire, track } from 'lwc';
import handleMixUpsert from '@salesforce/apex/MixController.handleMixUpsert';
import getMix from '@salesforce/apex/MixController.getMix';

export default class MixBuilder extends LightningElement
{
    @api recordId;

    @track selectedContactId;
    @track mixName;
    @track selectedSongs = [];
    @track selectedSongIds = [];

    @wire(getMix, { mixId: '$recordId' })
    wiredMix({ error, data }) {
        if (data) {
            data = JSON.parse(data);
            this.mixName = data.mixName;
            this.selectedContactId = data.contactId;
            this.selectedSongIds = data.selectedSongs;
        } else if (error) {
            console.error('Error loading mix', error);
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
        const mix = {
            mixId: this.recordId,
            mixName: this.mixName,
            contactId: this.selectedContactId,
            selectedSongs: this.selectedSongs.map(song => song.Id)
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
}
