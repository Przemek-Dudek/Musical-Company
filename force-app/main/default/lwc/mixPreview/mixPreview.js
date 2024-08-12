import { getRecord } from 'lightning/uiRecordApi';
import { LightningElement, api, track, wire } from 'lwc';

const COLUMNS = [
    { 
        label: 'Name',
        fieldName: 'url',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' },
        cellAttributes: {
            class: { fieldName: 'format' }
        }
    },
    { 
        label: 'Artist', 
        fieldName: 'Artist__c',
        cellAttributes: {
            class: { fieldName: 'format' }
        }
    },
    { 
        label: 'Genre', 
        fieldName: 'Genre__c',
        cellAttributes: {
            class: { fieldName: 'format' }
        }
    },
    { 
        label: 'Length', 
        fieldName: 'formattedLength',
        cellAttributes: {
            class: { fieldName: 'format' }
        }
    },
];


export default class MixPreview extends LightningElement
{
    @api selectedContactId;
    @api mixName;
    
    @track _selectedSongs = [];
    @track contactName;

    @api
    get selectedSongs() {
        return this._selectedSongs;
    }

    @wire(getRecord, { recordId: '$selectedContactId', fields: ['Contact.Name'] })
    wiredContact({ error, data }) {
        if (data) {
            this.contactName = data.fields.Name.value;
        }
        else if (error) {
            console.error(error);
            this.dispatchToastError('Error loading contact preview', error.message);
        }
    }

    get columns() {
        return COLUMNS;
    }

    set selectedSongs(value) {
        this._selectedSongs = value.map(song => {
            const formatClass = song.Is_Active__c ? null : 'slds-theme_alert-texture slds-text-color_inverse-weak';
            
            return {
                ...song,
                format: formatClass,
                formattedLength: this.formatTime(song.Length__c)
            };
        });
    } 

    get isSongsLimitExceeded() {
        return this._selectedSongs.length > 20;
    }

    get limitExceeded() {
        return this._selectedSongs.length - 20;
    }

    get isMixLengthExceeded() {
        return this._selectedSongs.reduce((acc, song) => acc + song.Length__c, 0) > 90;
    }

    get trackCount() {
        return this._selectedSongs.length;
    }

    get mixLength() {
        const totalLength = this._selectedSongs.reduce((acc, song) => acc + song.Length__c, 0);
        return this.formatTime(totalLength);
    }

    get mixLengthExceeded() {
        let totalLength = this._selectedSongs.reduce((acc, song) => acc + song.Length__c, 0);
        totalLength -= 90;
        return this.formatTime(totalLength);
    }

    formatTime(minutes) {
        const totalMinutes = Math.floor(minutes);
        const decimalMinutes = minutes - totalMinutes;
        const seconds = Math.round(decimalMinutes * 60);
        return `${totalMinutes}:${seconds < 10 ? '0' : ''}${seconds}`;
    }
}
