import { LightningElement, wire, track, api } from 'lwc';

import getGenres from '@salesforce/apex/MixBuilderController.getGenres';
import getSongsByGenre from '@salesforce/apex/MixBuilderController.getSongsByGenre';
import getPages from '@salesforce/apex/MixBuilderController.getPages';

const SONG_URL = '/lightning/r/Song__c/';
const VIEW = '/view';

export default class MusicTable extends LightningElement
{
    columns = [
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

    @track selectedGenre = 'all';
    @track genres;
    @track currentPage = 1;
    @track totalPages;
    
    @track musicList = [];
    @track displayList = [];

    @api selectedSongs = [];

    isLoading = true;

    @wire(getPages, { genre: '$selectedGenre'})
    wiredPages({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.totalPages = data;
        } else if (error) {
            console.error(error);
        }

        if(this.genres && this.totalPages && this.musicList) {
            this.isLoading = false;
        }
    }

    @wire(getGenres)
    wiredGenres({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.genres = data.map(genre => ({ label: genre, value: genre }));
            this.genres.unshift({ label: 'All', value: 'all' });
        } else if (error) {
            console.error(error);
        }
        
        if(this.genres && this.totalPages && this.musicList) {
            this.isLoading = false;
        }
    }

    @wire(getSongsByGenre, { genre: '$selectedGenre', offset: '$offset' })
    wiredSongs({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.musicList = data.map(song => ({
                ...song,
                formattedTime: this.formatTime(song.Length__c),
                url: SONG_URL + song.Id + VIEW
            }));

            this.displayList = this.musicList.slice(0, 10);
        } else if (error) {
            console.error(error);
        }
        
        if(this.genres && this.totalPages && this.musicList) {
            this.isLoading = false;
        }
    }

    get offset() {
        //return Math.floor((this.currentPage - 1) / 10);
        return this.currentPage - 1;
    }

    get selectedRowsGet() {
        return this.selectedSongs.filter(
            song => this.displayList.some(
                displaySong => displaySong.Id === song.Id))
                .map(song => song.Id);
    }

    handleRowAction(event) {
        const selectedRows = event.detail.selectedRows;
        const action = event.detail.config.action;

        if (action === 'rowSelect' || action === 'selectAllRows') {
            this.selectedSongs = this.selectedSongs.filter(song => !selectedRows.some(row => row.Id === song.Id));
            this.selectedSongs = this.selectedSongs.concat(selectedRows);
        }
        else if (action === 'rowDeselect') {
            this.selectedSongs = this.selectedSongs.filter(song => song.Id !== event.detail.config.value);
        }
        else if (action === 'deselectAllRows') {
            this.selectedSongs = this.selectedSongs.filter(song => selectedRows.some(row => row.Id === song.Id));
        }

        const songEvent = new CustomEvent('songsselected', { detail: this.selectedSongs });
        this.dispatchEvent(songEvent);
    }

    formatTime(minutes) {
        const totalMinutes = Math.floor(minutes);
        const decimalMinutes = minutes - totalMinutes;
        const seconds = Math.round(decimalMinutes * 60);
        return `${totalMinutes}:${seconds < 10 ? '0' : ''}${seconds}`;
    }

    updateDisplayList() {
        this.displayList = this.musicList.slice((this.currentPage - 1) * 10, this.currentPage * 10);
    }

    handleGenreChange(event) {
        this.currentPage = 1;
        this.selectedGenre = event.detail.value;
    }

    handleFirstPage() {
        this.currentPage = 1;
        this.updateDisplayList();
    }

    handlePreviousPage() {
        this.currentPage = Math.max(1, this.currentPage - 1);
        this.updateDisplayList();
    }

    handleNextPage() {
        this.currentPage = Math.min(this.totalPages, this.currentPage + 1);
        this.updateDisplayList();
    }

    handleLastPage() {
        this.currentPage = this.totalPages;
        this.updateDisplayList();
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }
}