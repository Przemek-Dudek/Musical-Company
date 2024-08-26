public class MixWrapper
{
    public class SongIndex
    {
        public Id songId;
        public Integer songIndex;

        public SongIndex(Id id, Integer index)
        {
            this.songId = id;
            this.songIndex = index;
        }
    }
    
    public Id mixId;
    public String mixName;
    public Id contactId;
    public List<Song__c> selectedSongs;
    public List<SongIndex> songIndexes;

    public mixWrapper(Id mixId, String mixName, Id contactId, List<Song__c> selectedSongs) {
        this.mixId = mixId;
        this.mixName = mixName;
        this.contactId = contactId;
        this.selectedSongs = selectedSongs;
    }

    public mixWrapper(Id mixId, String mixName, Id contactId, List<SongIndex> songIndexes) {
        this.mixId = mixId;
        this.mixName = mixName;
        this.contactId = contactId;
        this.songIndexes = songIndexes;
    }
}