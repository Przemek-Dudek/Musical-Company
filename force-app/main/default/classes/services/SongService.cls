public with sharing class SongService
{
    public static void updateSongFields(Set<Id> songIds)
    {
        List<AggregateResult> results = TrackSelector.countTracksOnSongs(songIds);

        List<Song__c> songsToUpdate = new List<Song__c>();

        for (AggregateResult res : results)
        {
            Id songId = (Id)res.get('songId');
            Integer trackCount = (Integer)res.get('trackCount');

            songsToUpdate.add(new Song__c(Id = songId, Track_Count__c = trackCount));
        }

        update songsToUpdate;
    }
}