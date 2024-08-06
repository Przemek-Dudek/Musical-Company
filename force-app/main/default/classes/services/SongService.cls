public with sharing class SongService
{
    public static void updateSongFields(Set<Id> songIds)
    {
        List<AggregateResult> results = TrackSelector.countTracksOnSongs(songIds);
        if(results.isEmpty())
        {
            return;
        }

        List<Song__c> songsToUpdate = new List<Song__c>();
        for (AggregateResult res : results)
        {
            Id songId = (Id)res.get(Consts.FIELD_SONG);
            Integer trackCount = (Integer)res.get(Consts.AGGREGATE_COUNT);

            songsToUpdate.add(new Song__c(Id = songId, Track_Count__c = trackCount));
        }

        update songsToUpdate;
    }

    public static List<String> getUnavailableSongNames(List<Song__c> songs)
    {
        List<String> songNames = new List<String>();
        for (Song__c song : songs)
        {
            if(song.Track_Count__c == song.Track_Licenses__c)
            {
                songNames.add(song.Name);
            }
        }

        return songNames;
    }
}