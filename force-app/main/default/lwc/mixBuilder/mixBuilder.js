import { LightningElement, track } from 'lwc';

export default class MixBuilder extends LightningElement
{
    @track selectedContactId;
    @track mixName;
    @track selectedSongs = [];

    handleSongsEvent(event)
    {
        this.selectedSongs = event.detail;
    }

    handleNameEvent(event)
    {
        this.mixName = event.detail.value;
    }

    handleContactEvent(event)
    {
        this.selectedContactId = event.detail.recordId;
    }

    closeModal()
    {
        const modal = this.template.querySelector('section[role="dialog"]');
        const backdrop = this.template.querySelector('.slds-backdrop');

        if (modal)
        {
            modal.classList.remove('slds-fade-in-open');
            modal.classList.add('slds-hidden');
        }
        if (backdrop)
        {
            backdrop.classList.remove('slds-backdrop_open');
            backdrop.classList.add('slds-hidden');
        }
    }
}
