import { LightningElement, api, track } from 'lwc';

import handleVinylProduce from '@salesforce/apex/MixController.handleVinylProduce';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class VinylProduce extends LightningElement
{
    @api mixName;
    @api selectedContactId;
    @api contactName;
    @api trackCount;
    @api mixLength;
    @api mixId;

    @track _selectedSongs = [];

    @api
    get selectedSongs() {
        return this._selectedSongs;
    }

    set selectedSongs(value) {
        this._selectedSongs = value.map(song => song);
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleReorder(event) {
        this._selectedSongs = event.detail;
    }

    handleProduce() {
        const mix = {
            mixId: this.mixId,
            selectedTracks: this._selectedSongs.map(song => song)
        };

        handleVinylProduce({ mixJson: JSON.stringify(mix) })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent(
                    { title: 'Success', message: 'Mix sent to production', variant: 'success' }));
                this.closeModal();
            })
            .catch(error => {
                console.error('Error saving mix', error);
            });

        this.closeModal();
    }
}