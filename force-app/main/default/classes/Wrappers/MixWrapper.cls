public class MixWrapper
{
    public Id mixId;
    public String mixName;
    public Id contactId;
    public List<Song__c> selectedSongs;

    public mixWrapper(Id mixId, String mixName, Id contactId, List<Song__c> selectedSongs) {
        this.mixId = mixId;
        this.mixName = mixName;
        this.contactId = contactId;
        this.selectedSongs = selectedSongs;
    }
}