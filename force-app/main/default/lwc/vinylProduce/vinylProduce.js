import { LightningElement, api, track } from 'lwc';

export default class VinylProduce extends LightningElement
{
    @api mixName;
    @api selectedContactId;
    @api contactName;
    @api trackCount;
    @api mixLength;

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
}