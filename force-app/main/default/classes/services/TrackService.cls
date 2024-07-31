public with sharing class TrackService
{
    public static void processAddedTracks(List<Track__c> newTracks)
    {
        Set<Id> affectedMixIds = Utils.getIdFieldValue(newTracks, Consts.FIELD_MIX);
        List<Track__c> selectedTracks = TrackSelector.selectByMixId(affectedMixIds);
        Map<Id, List<Track__c>> tracksByMixId = Utils.getParentIdToChildrenMapping(selectedTracks, Consts.FIELD_MIX);

        for(Track__c track : newTracks)
        {
            if (!tracksByMixId.containsKey(track.Mix__c))
            {
                tracksByMixId.put(track.Mix__c, new List<Track__c>());
            }

            Set<Track__c> tracks = new Set<Track__c>(tracksByMixId.get(track.Mix__c));
            tracks.add(track);

            if(tracks.size() > Consts.MAX_TRACKS_PER_MIX)
            {
                track.addError('Cannot add more than ' + Consts.MAX_TRACKS_PER_MIX + ' tracks to a mix');
            }

            tracksByMixId.put(track.Mix__c, new List<Track__c>(tracks));
        }
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