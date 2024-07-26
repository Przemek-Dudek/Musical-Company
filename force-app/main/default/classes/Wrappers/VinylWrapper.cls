public class VinylWrapper
{
    public Id mixId;
    public String mixName;
    public Id contactId;
    public List<Track__c> selectedTracks;

    public vinylWrapper(Id mixId, String mixName, Id contactId, List<Track__c> selectedTracks) {
        this.mixId = mixId;
        this.mixName = mixName;
        this.contactId = contactId;
        this.selectedTracks = selectedTracks;
    }
}