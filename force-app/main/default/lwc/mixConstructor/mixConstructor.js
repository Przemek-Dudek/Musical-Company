import { LightningElement, api } from 'lwc';

export default class MixConstructor extends LightningElement
{
    @api selectedContactId;
    @api mixName = 'New Mix';

    selectedSongs = [];

    handleContactSelect(event)
    {
        this.selectedContactId = event.detail.recordId;

        console.log('Contact ID: ' + this.selectedContactId);
    }

    handleMixNameChange(event)
    {
        this.mixName = event.detail.value;

        console.log('Mix name: ' + this.mixName);
    }

    handleSongSelect(event)
    {
        this.selectedSongs = event.detail;

        console.log('Selected songs: ' + this.selectedSongs);
    }
}
