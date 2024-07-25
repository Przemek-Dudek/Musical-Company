import { LightningElement, api, track } from 'lwc';

export default class VinylProduce extends LightningElement
{
    @api mixName;
    @api selectedContactId;
    @api contactName;
    @api trackCount;
    @api mixLength;

    @track _selectedSongs = [];
    
    columns = [
        { 
            label: 'Name',
            fieldName: 'url',
            type: 'url',
            typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
        },
        { label: 'Artist', fieldName: 'Artist__c' },
        { label: 'Genre', fieldName: 'Genre__c' },
        { label: 'Length', fieldName: 'formattedLength' }
    ];

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
}