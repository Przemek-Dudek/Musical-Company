import { LightningElement, wire, track } from 'lwc';
import getSongsByIds from '@salesforce/apex/SongController.getSongsByIds';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MusicSelector extends LightningElement {
    musicRecordId;

    @track musicList = [];

    @track songs;
    @track columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Artist', fieldName: 'Artist__c' },
        { label: 'Genre', fieldName: 'Genre__c' },
        { label: 'Length', fieldName: 'Length__c' },
        {
            type: 'button-icon',
            fixedWidth: 40,
            typeAttributes: {
                name: 'delete',
                iconName: 'utility:delete',
                variant: 'bare',
                alternativeText: 'Delete',
                class: 'slds-icon slds-icon_x-small slds-icon-text-error'
            }
        }
    ];

    handleSelect(event)
    {
        this.musicRecordId = event.detail.recordId;
    }

    handleAddSong()
    {
        if (!this.musicRecordId)
        {
            return;
        }

        if (this.musicList.length >= 20)
        {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Mix can only have 20 songs',
                variant: 'error'
            });

            this.dispatchEvent(event);
            return;
        }

        if (!this.musicList.includes(this.musicRecordId))
        {
            this.musicList = [...this.musicList, this.musicRecordId];
        }
        else
        {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Song already in mix',
                variant: 'error'
            });

            this.dispatchEvent(event);
        }


    }

    handleRowAction(event)
    {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'delete')
        {
            this.deleteSong(row.Id);
        }
    }

    deleteSong(songId)
    {
        this.musicList = this.musicList.filter(id => id !== songId);
    }

    @wire(getSongsByIds, { musicList: '$musicList' })
    wiredSongs({ error, data })
    {
        if (data)
        {
            this.songs = data;
        }
        else if (error)
        {
            console.error(error);
        }
    }
}
