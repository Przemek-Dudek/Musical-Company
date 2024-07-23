import { LightningElement, wire, track } from 'lwc';

import getGenres from '@salesforce/apex/SongController.getGenres';

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

    selectedGenre = 'all';
    @track genres;
    @track currentPage = 1;
    @track totalPages = 1;

    @wire(getGenres)
    wiredGenres({ error, data }) {
        if (data) {
            this.genres = data.map(genre => ({ label: genre, value: genre }));
            this.genres.unshift({ label: 'All', value: 'all' });
        } else if (error) {
            console.error(error);
        }
    }

    handleGenreChange(event) {
        this.selectedGenre = event.detail.value;
    }

    handleFirstPage()
    {
        this.currentPage = 1;
    }

    handlePreviousPage()
    {
        this.currentPage = Math.max(1, this.currentPage - 1);
    }

    handleNextPage()
    {
        this.currentPage = Math.min(this.totalPages, this.currentPage + 1);
    }

    handleLastPage()
    {
        this.currentPage = this.totalPages;
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }
}