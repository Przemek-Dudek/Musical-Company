import { LightningElement, api } from 'lwc';

export default class MixSettings extends LightningElement
{
    @api selectedContactId;
    @api mixName = 'New Mix';
    @api selectedSongs = [];

    handleContactSelect(event)
    {
        this.selectedContactId = event.detail.recordId;

        const selectedEvent = new CustomEvent('contact', { detail: { recordId: this.selectedContactId } });

        this.dispatchEvent(selectedEvent);
    }

    handleMixNameChange(event)
    {
        this.mixName = event.target.value;

        const selectedEvent = new CustomEvent('name', { detail: { value: this.mixName } });

        this.dispatchEvent(selectedEvent);
    }

    handleSongSelect(event)
    {
        const songId = event.detail.recordId;

        if (this.selectedSongs.includes(songId))
        {
            this.selectedSongs = this.selectedSongs.filter(song => song !== songId);
        }
        else
        {
            this.selectedSongs.push(songId);
        }
    }
}