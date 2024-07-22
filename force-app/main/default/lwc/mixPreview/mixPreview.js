import { getRecord } from 'lightning/uiRecordApi';
import { LightningElement, api, track, wire } from 'lwc';

export default class MixPreview extends LightningElement {
    // Define columns for the lightning-datatable
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Artist', fieldName: 'Artist__c' },
        { label: 'Genre', fieldName: 'Genre__c' },
        { label: 'Length', fieldName: 'formattedLength' }
    ];

    @api selectedContactId;
    @api mixName;
    
    @track _selectedSongs = [];
    @track contactName;

    @api
    get selectedSongs() {
        return this._selectedSongs;
    }

    set selectedSongs(value) {
        this._selectedSongs = value.map(song => ({
            ...song,
            formattedLength: this.formatTime(song.Length__c)
        }));
    }

    get trackCount() {
        return this._selectedSongs.length;
    }

    get mixLength(){
        const totalLength = this._selectedSongs.reduce((acc, song) => acc + song.Length__c, 0);
        return this.formatTime(totalLength);
    }

    formatTime(minutes) {
        const totalMinutes = Math.floor(minutes);
        const decimalMinutes = minutes - totalMinutes;
        const seconds = Math.round(decimalMinutes * 60);
        return `${totalMinutes}:${seconds < 10 ? '0' : ''}${seconds}`;
    }

    @wire(getRecord, { recordId: '$selectedContactId', fields: ['Contact.Name'] })
    wiredContact({ error, data })
    {
        if (data)
        {
            this.contactName = data.fields.Name.value;
        }
        else if (error)
        {
            console.error(error);
        }
    }
}
