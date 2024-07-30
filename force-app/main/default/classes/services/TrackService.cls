public with sharing class TrackService
{
    public static void processAddedTracks(List<Track__c> newTracks)
    {
        Set<Id> affectedMixIds = Utils.getIdFieldValue(newTracks, Consts.FIELD_MIX);

        Map<Id, Integer> trackCountByMixId = getTrackCountByMixIds(affectedMixIds);

        for(Track__c track : newTracks)
        {
            if (!trackCountByMixId.containsKey(track.Mix__c))
            {
                trackCountByMixId.put(track.Mix__c, 0);
            }

            Integer newCount = trackCountByMixId.get(track.Mix__c) + 1;

            if (newCount > Consts.MAX_TRACKS_PER_MIX)
            {
                track.addError('Max amount of tracks per mix reached');
            }

            trackCountByMixId.put(track.Mix__c, newCount);
        }
    }

    public static Map<Id, Integer> getTrackCountByMixIds(Set<Id> mixIds)
    {
        List<AggregateResult> results = TrackSelector.getTrackCountByMixIds(mixIds);

        Map<Id, Integer> trackCountByMixId = new Map<Id, Integer>();
        for (AggregateResult result : results)
        {
            trackCountByMixId.put((Id)result.get(Consts.FIELD_MIX), (Integer)result.get(Consts.AGGREGATE_COUNT));
        }

        return trackCountByMixId;
    }

    public static Set<Id> getMixIdsFromTracks(Set<Id> trackIds)
    {
        List<Track__c> tracks = TrackSelector.selectByIds(trackIds);

        return Utils.getIdFieldValue(tracks, Consts.FIELD_MIX);
    }

    public static Set<Id> getTrackIdsFromSongs(Set<Id> songIds)
    {
        List<Track__c> tracks = TrackSelector.getTracksBySongIds(songIds);

        return Utils.getIdFieldValue(tracks, Consts.FIELD_ID);
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