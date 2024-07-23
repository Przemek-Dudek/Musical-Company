import { LightningElement, api, track } from 'lwc';

export default class MixConstructor extends LightningElement
{
    @api selectedContactId;
    @api mixName = 'New Mix';
    @track selectedSongs = [];
    @api selectedSongIds = [];

    connectedCallback()
    {
        this.dispatchEvent(new CustomEvent('name', { detail: { value: this.mixName } }));
        this.dispatchEvent(new CustomEvent('contact', { detail: { recordId: this.selectedContactId } }));
    }

    handleContactSelect(event) {
        this.selectedContactId = event.detail.recordId;
        this.dispatchEvent(new CustomEvent('contact', { detail: { recordId: this.selectedContactId } }));
    }

    handleMixNameChange(event) {
        this.mixName = event.detail.value;
        this.dispatchEvent(new CustomEvent('name', { detail: { value: this.mixName } }));
    }

    handleSongSelect(event) {
        this.selectedSongs = event.detail;
        this.dispatchEvent(new CustomEvent('songsloaded', { detail: this.selectedSongs }));
    }
}
