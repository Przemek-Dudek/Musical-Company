public with sharing class TrackService
{
    public static void processAddedTracks(List<Track__c> newTracks)
    {
        Set<Id> mixIds = new Set<Id>();
        for (Track__c track : newTracks)
        {
            mixIds.add(track.Mix__c);
        }

        Set<Id> fullMixesIds = MixSelector.selectFullMixIds(mixIds);

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
        List<Track__c> tracks = [
            SELECT Mix__c
            FROM Track__c
            WHERE Id IN :trackIds];

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
}