import { LightningElement, api, track, wire } from 'lwc';
import getMix from '@salesforce/apex/MixController.getMix';
import getTrackOrder from '@salesforce/apex/SongController.getTrackOrder';
import sendEmailWithPdf from '@salesforce/apex/EmailManager.sendEmailWithPdf';

import { getRecord } from 'lightning/uiRecordApi';

import pdfLib from '@salesforce/resourceUrl/pdfLib';
import mixTemplate from '@salesforce/resourceUrl/mixPDFTemplate';

import { loadScript } from 'lightning/platformResourceLoader';

const SONG_URL = '/lightning/r/Song__c/';
const VIEW = '/view';
const CREATED_BY = 'Created By: ';

export default class MixLookup extends LightningElement {
    @api recordId;

    @track selectedContactId;
    @track contactName;
    @track mixName;
    @track selectedSongs = [];

    @track vinylModal = false;

    pdfLibInitialized = false;

    @wire(getMix, { mixId: '$recordId' })
    wiredMix({ error, data }) {
        if (data) {
            data = JSON.parse(data);
            this.mixName = data.mixName;
            this.selectedContactId = data.contactId;
            this.selectedSongs = data.selectedSongs.map(song => ({
                ...song,
                url: SONG_URL + song.Id + VIEW,
                formattedLength: this.formatTime(song.Length__c)
            }));

            this.organizeSongs();
        } else if (error) {
            console.error('Error loading mix', error);
        }
    }

    @wire(getRecord, { recordId: '$selectedContactId', fields: ['Contact.Name'] })
    wiredContact({ error, data })
    {
        if (data)
        {
            this.contactName = data.fields.Name.value;
        }
        else if (error)
        {
            console.error(error);
        }
    }

    @wire(getTrackOrder, { mixId: '$recordId' })
    wiredOrder({ error, data }) {
        if (data)
        {
            this.songOrder = new Map(data.map(track => [track.Id, track.Index__c]));
            this.organizeSongs();
        } else if (error) {
            console.error('Error loading order', error);
        }
    }

    organizeSongs() {
        if (!this.songOrder || !this.selectedSongs) {
            return;
        }

        this.selectedSongs = this.selectedSongs.map(song => ({
            ...song,
            Index__c: this.songOrder.get(song.Id)
        }));
        
        this.selectedSongs.sort((a, b) => a.Index__c - b.Index__c);
    }

    renderedCallback() {
        if (this.pdfLibInitialized) {
            return;
        }
        this.pdfLibInitialized = true;

        loadScript(this, pdfLib).then(() => {
            console.log('PDFLib loaded successfully');
        }).catch(error => {
            console.error('Error loading PDFLib', error);
        });
    }

    formatTime(minutes) {
        const totalMinutes = Math.floor(minutes);
        const decimalMinutes = minutes - totalMinutes;
        const seconds = Math.round(decimalMinutes * 60);
        return `${totalMinutes}:${seconds < 10 ? '0' : ''}${seconds}`;
    }

    get customerName()
    {
        return CREATED_BY + this.contactName;
    }

    get songTitles()
    {
        let songs = '';

        this.selectedSongs.forEach(song => {
            songs += song.Name + '\n';
        });

        return songs;
    }

    get songArtists()
    {
        let artists = '';

        this.selectedSongs.forEach(song => {
            artists += song.Artist__c + '\n';
        });

        return artists;
    }

    get songLengths()
    {
        let lengths = '';

        this.selectedSongs.forEach(song => {
            lengths += song.formattedLength + '\n';
        });

        return lengths;
    }

    get songGenres()
    {
        let genres = '';

        this.selectedSongs.forEach(song => {
            genres += song.Genre__c + '\n';
        });

        return genres;
    }

    get trackCount()
    {
        return this.selectedSongs.length;
    }

    get mixLength(){
        const totalLength = this.selectedSongs.reduce((acc, song) => acc + song.Length__c, 0);
        return this.formatTime(totalLength);
    }

    get mixStats()
    {
        return 'A custom mix comprised of ' + this.trackCount + ' unique Tracks.'
            + ' Total listening time: ' + this.mixLength + ' minutes.';
    }

    async downloadPdf() {
        try {
            const pdfBytes = await this.createPdf();
            this.saveByteArray(this.mixName, pdfBytes);
        } catch (error) {
            console.error('Error creating PDF:', error.message);
            console.error('Stack trace:', error.stack);
            console.error('Error details:', error);
        }
    }
    

    async sendPdf() {
        try {
            const pdfBytes = await this.createPdf();
            const pdfBase64 = this.arrayBufferToBase64(pdfBytes);

            await sendEmailWithPdf({ contactId: this.selectedContactId, pdfBase64: pdfBase64, fileName: this.mixName });
        } catch (error) {
            console.error('Error creating PDF to send:', error.message);
            console.error('Stack trace:', error.stack);
            console.error('Error details:', error);
        }
    }

    arrayBufferToBase64(buffer) {
        let binary = '';
        const bytes = new Uint8Array(buffer);
        const len = bytes.byteLength;
        for (let i = 0; i < len; i++) {
            binary += String.fromCharCode(bytes[i]);
        }
        return btoa(binary);
    }

    async createPdf()
    {
        const existingPdfBytes = await fetch(mixTemplate).then(res => res.arrayBuffer())
        const pdfDoc = await PDFLib.PDFDocument.load(existingPdfBytes);

        const helveticaBold = await pdfDoc.embedFont(PDFLib.StandardFonts.HelveticaBold);
        const helvetica = await pdfDoc.embedFont(PDFLib.StandardFonts.Helvetica);
    
        const page = pdfDoc.getPages()[0];
        const { width, height } = page.getSize();
        const titlefontSize = 75;
        const authorfontSize = 22;
        const songsfontSize = 12;
        const statsfontSize = 13;
        const songHeight = height - 325;

        const white = PDFLib.rgb(1, 1, 1);

        page.drawText(this.mixName, {
            x: 60,
            y: height - 120,
            size: titlefontSize,
            font: helveticaBold,
            color: white,
        });

        page.drawText(this.customerName, {
            x: 70,
            y: height - 155,
            size: authorfontSize,
            font: helvetica,
            color: white,
        });

        page.drawText(this.mixStats, {
            x: 60,
            y: height - 245,
            size: statsfontSize,
            font: helvetica,
            color: white,
        });

        page.drawText(this.songTitles, {
            x: 70,
            y: songHeight,
            size: songsfontSize,
            font: helvetica,
            color: white,
        });

        page.drawText(this.songArtists, {
            x: 230,
            y: songHeight,
            size: songsfontSize,
            font: helvetica,
            color: white,
        });

        page.drawText(this.songLengths, {
            x: 400,
            y: songHeight,
            size: songsfontSize,
            font: helvetica,
            color: white,
        });

        page.drawText(this.songGenres, {
            x: 440,
            y: songHeight,
            size: songsfontSize,
            font: helvetica,
            color: white,
        });

        return await pdfDoc.save();
    }

    saveByteArray(pdfName, byte) {
        var blob = new Blob([byte], { type: "application/pdf" });
        var link = document.createElement('a');
        link.href = window.URL.createObjectURL(blob);
        var fileName = pdfName;
        link.download = fileName;
        link.click();
    }

    openVinylModal() {
        this.vinylModal = true;
    }

    closeVinylModal() {
        this.vinylModal = false;
    }

    handleReorder(event) {
        this.selectedSongs = event.detail;
    }
}
