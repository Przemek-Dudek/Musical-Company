import { LightningElement, api, track } from 'lwc';

import handleVinylProduce from '@salesforce/apex/MixBuilderController.handleVinylProduce';

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
        const songIndexes = this._selectedSongs.map(song => {
            return {
                songId: song.Id,
                songIndex: song.Index__c
            };
        });

        const mix = {
            mixId: this.mixId,
            songIndexes: songIndexes
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

        this.dispatchEvent(new CustomEvent("reorder", {
            detail: this.selectedSongs
        }));

        this.dispatchEvent(new CustomEvent("produce"));

        this.closeModal();
    }
}