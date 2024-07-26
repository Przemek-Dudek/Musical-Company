public with sharing class TrackService
{
    public static void processAddedTracks(List<Track__c> newTracks)
    {
        Set<Id> mixIds = new Set<Id>();
        for (Track__c track : newTracks)
        {
            mixIds.add(track.Mix__c);
        }

        Set<Id> fullMixesIds = MixService.getFullMixIds(mixIds);

        if (fullMixesIds.isEmpty())
        {
            return;
        }

        for(Track__c track : newTracks)
        {
            if (fullMixesIds.contains(track.Mix__c))
            {
                track.addError('Max amount of tracks per mix reached');
            }
        }
    }

    public static Set<Id> getMixIdsFromTracks(Set<Id> trackIds)
    {
        List<Track__c> tracks = TrackSelector.selectByIds(trackIds);

        Set<Id> mixIds = new Set<Id>();
        for (Track__c track : tracks)
        {
            if(track.Mix__c != null)
            {
                mixIds.add(track.Mix__c);
            }
        }

        return mixIds;
    }

    public static Set<Id> getTrackIdsFromSongs(Set<Id> songIds)
    {
        List<Track__c> tracks = TrackSelector.getTracksBySongIds(songIds);

        Set<Id> trackIds = new Set<Id>();
        for (Track__c track : tracks)
        {
            trackIds.add(track.Id);
        }

        return trackIds;
    }

    public static Set<Id> getSongIdsFromTracks(List<Track__c> tracks)
    {
        Set<Id> songIds = new Set<Id>();
        for (Track__c track : tracks)
        {
            if(track.Song__c != null)
            {
                songIds.add(track.Song__c);
            }
        }

        return songIds;
    }

    public static void createTracks(Id mixId, List<Song__c> songs)
    {
        List<Track__c> newTracks = new List<Track__c>();
        for (Song__c song : songs)
        {
            newTracks.add(new Track__c(Mix__c = mixId, Song__c = song.Id));
        }

        insert newTracks;
    }
}