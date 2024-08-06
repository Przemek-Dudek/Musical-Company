public with sharing class SongService
{
    public static void updateSongFields(Set<Id> songIds)
    {
        List<Song__c> songsToUpdate = new List<Song__c>();

        List<AggregateResult> results = TrackSelector.countTracksOnSongs(songIds);

        Map<Id, Integer> songTrackCounts = new Map<Id, Integer>();
        for(Id songId : songIds)
        {
            songTrackCounts.put(songId, 0);
        }

        for (AggregateResult res : results)
        {
            Id songId = (Id)res.get(Consts.FIELD_SONG);
            Integer trackCount = (Integer)res.get(Consts.AGGREGATE_COUNT);

            songTrackCounts.put(songId, trackCount);
        }

        for(Id songId : songIds)
        {
            Song__c song = new Song__c(Id = songId);
            song.Track_Count__c = songTrackCounts.get(songId);
            songsToUpdate.add(song);
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