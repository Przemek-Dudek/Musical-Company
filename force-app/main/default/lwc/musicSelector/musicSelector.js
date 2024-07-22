import { LightningElement, wire, track } from 'lwc';
import getSongsByGenre from '@salesforce/apex/SongController.getSongsByGenre';
import getGenres from '@salesforce/apex/SongController.getGenres';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MusicSelector extends LightningElement
{
    chosenGenre = 'all';
    @track musicList = [];
    @track genres
    @track chosenSongs = [];

    @track columns = [
        { 
            label: 'Name',
            fieldName: 'url',
            type: 'url',
            typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
        },
        { label: 'Artist', fieldName: 'Artist__c' },
        { label: 'Genre', fieldName: 'Genre__c' },
        { label: 'Length', fieldName: 'formattedTime' }
    ];

    handleGenreChange(event)
    {
        this.chosenGenre = event.detail.value;
    }

    handleRowAction(event)
    {
        this.chosenSongs = event.detail.selectedRows;

        const songEvent = new CustomEvent('songsselected', { detail: this.chosenSongs });
        this.dispatchEvent(songEvent);
    }

    formatTime(minutes)
    {
        const totalMinutes = Math.floor(minutes);
        const decimalMinutes = minutes - totalMinutes;
        const seconds = Math.round(decimalMinutes * 60);
        return `${totalMinutes}:${seconds < 10 ? '0' : ''}${seconds}`;
    }

    @wire(getSongsByGenre, { genre: '$chosenGenre' })
    wiredSongs({ error, data })
    {
        if (data)
        {
            this.musicList = data.map(song => ({
                ...song,
                formattedTime: this.formatTime(song.Length__c),
                url: '/lightning/r/Song__c/' + song.Id + '/view'
            }));
        }
        else if (error)
        {
            console.error(error);
        }
    }

    @wire(getGenres)
    wiredGenres({ error, data })
    {
        if (data)
        {
            this.genres = data.map(genre => ({ label: genre, value: genre }));
            this.genres.unshift({ label: 'All', value: 'all' });
        }
        else if (error)
        {
            console.error(error);
        }
    }
}
