import { LightningElement, api, track } from 'lwc';

export default class MixSettings extends LightningElement {
    @api selectedContactId;
    @api mixName = 'New Mix';
    @track _selectedSongs = [];
    @track trackCount = 0;
    @track timeCount = 0;

    @api
    get selectedSongs() {
        return this._selectedSongs;
    }

    set selectedSongs(value) {
        this._selectedSongs = value;
        this.trackCount = this._selectedSongs.length;
        this.extractSongLengths();
    }

    extractSongLengths() {
        this.timeCount = this._selectedSongs.reduce((sum, song) => {
            return sum + (song.Length__c || 0);
        }, 0);
    }

    get remainingTracks() {
        const remainingTracks = 20 - this.trackCount;

        if(remainingTracks < 0) {
            return 'TRACK LIMIT EXCEEDED';
        }

        return remainingTracks;
    }
    
    get formattedTimeCount() {
        return this.formatTime(this.timeCount);
    }

    get remainingTime() {
        const remainingTime = 90 - this.timeCount;
        
        if(remainingTime < 0) {
            return 'TIME LIMIT EXCEEDED';
        }

        return this.formatTime(remainingTime);
    }

    formatTime(minutes) {
        const totalMinutes = Math.floor(minutes);
        const decimalMinutes = minutes - totalMinutes;
        const seconds = Math.round(decimalMinutes * 60);
        return `${totalMinutes}:${seconds < 10 ? '0' : ''}${seconds}`;
    }

    handleContactSelect(event) {
        this.selectedContactId = event.detail.recordId;
        const selectedEvent = new CustomEvent('contact', { detail: { recordId: this.selectedContactId } });
        this.dispatchEvent(selectedEvent);
    }

    handleMixNameChange(event) {
        this.mixName = event.target.value;
        const selectedEvent = new CustomEvent('name', { detail: { value: this.mixName } });
        this.dispatchEvent(selectedEvent);
    }
}
