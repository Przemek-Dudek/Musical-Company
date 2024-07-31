public class VinylWrapper
{
    public Id mixId;
    public String mixName;
    public Id contactId;
    public List<SongIndex> selectedTracks;

    public vinylWrapper(Id mixId, String mixName, Id contactId, List<SongIndex> selectedTracks) {
        this.mixId = mixId;
        this.mixName = mixName;
        this.contactId = contactId;
        this.selectedTracks = selectedTracks;
    }

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
}