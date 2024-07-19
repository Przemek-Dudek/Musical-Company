import { LightningElement } from 'lwc';

export default class MusicSelector extends LightningElement
{
    musicRecordId;

    handleSelect(event)
    {
        this.musicRecordId = event.detail.recordId;
    }

    handleAddSong()
    {
        const selectedEvent = new CustomEvent('select', { detail: { recordId: this.musicRecordId } });

        this.dispatchEvent(selectedEvent);

        this.musicRecordId = null;
    }
}