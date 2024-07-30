@isTest
public with sharing class MixServiceTest
{
    @TestSetup
    static void makeData()
    {
        TestHelper.insertTestMixes();
    }

    @isTest
    static void getMixGenreCountMap()
    {
        Set<Id> mixIds = new Set<Id>();

        List<Mix__c> mixes = [SELECT Id FROM Mix__c LIMIT 3];

        for(Mix__c mix : mixes)
        {
            mixIds.add(mix.Id);
        }

        Map<Id, Map<String, Integer>> mixGenreCount = MixService.getMixGenreCountMap(mixIds);

        System.assertEquals(3, mixGenreCount.size());

        for(Mix__c mix : mixes)
        {
            System.assertEquals(10, mixGenreCount.get(mix.Id).get(TestHelper.GENRE_ROCK));
        }
    }

    @isTest
    static void updateMixFields()
    {
        List<Mix__c> mixes = [SELECT Id FROM Mix__c LIMIT 3];

        Set<Id> mixIds = Utils.getIdFieldValue(mixes, Consts.FIELD_ID);

        Test.startTest();
        MixService.updateMixFields(mixIds);
        Test.stopTest();

        List<Mix__c> updatedMixes = [SELECT Id, Primary_Genre__c, Secondary_Genre__c FROM Mix__c LIMIT 3];

        for(Mix__c mix : updatedMixes)
        {
            System.assertEquals(TestHelper.GENRE_ROCK, mix.Primary_Genre__c);
            System.assertEquals(null, mix.Secondary_Genre__c);
        }
    }

    @isTest
    static void getFullMixIdsNoFullMixes()
    {
        List<Mix__c> mixes = [SELECT Id FROM Mix__c LIMIT 3];

        Set<Id> mixIds = Utils.getIdFieldValue(mixes, Consts.FIELD_ID);

        Set<Id> fullMixIds = MixService.getFullMixIds(mixIds);

        System.assertEquals(0, fullMixIds.size());
    }

    @isTest
    static void getFullMixIds()
    {
        List<Mix__c> mixes = [SELECT Id FROM Mix__c LIMIT 3];

        Set<Id> mixIds = Utils.getIdFieldValue(mixes, Consts.FIELD_ID);

        Mix__c fullMix = new Mix__c(Name = 'Full Mix');
        insert fullMix;

        List<Track__c> tracksToAdd = new List<Track__c>();

        List<Song__c> songs = [SELECT Id FROM Song__c LIMIT 20];

        for(Integer i = 0; i < 20; i++)
        {
            Track__c track = new Track__c();
            track.Mix__c = fullMix.Id;
            track.Song__c = songs[i].Id;

            tracksToAdd.add(track);
        }

        insert tracksToAdd;

        mixIds.add(fullMix.Id);

        Test.startTest();
        Set<Id> fullMixIds = MixService.getFullMixIds(mixIds);
        Test.stopTest();

        System.assertEquals(1, fullMixIds.size());
        System.assertEquals(fullMix.Id, fullMixIds.iterator().next());
    }

    @isTest
    static void createNewMix()
    {
        List<Mix__c> mixes = [SELECT Id FROM Mix__c];

        delete mixes;

        List<Song__c> songs = new List<Song__c>();

        for(Integer i = 0; i < 20; i++)
        {
            Song__c song = new Song__c();
            song.Name = 'Test' + i;
            song.Length__c = 180;
            song.Artist__c = 'Test Artist' + i;
            song.Track_Count__c = 0;
            song.Track_Licenses__c = 10;

            if(i < 15) 
            {
                song.Genre__c = TestHelper.GENRE_ROCK;
            }
            else
            {
                song.Genre__c = TestHelper.GENRE_POP;
            }

            songs.add(song);
        }

        insert songs;

        MixWrapper mix = new MixWrapper(null, 'New Mix', null, songs);

        Test.startTest();
        MixService.createNewMix(mix);
        Test.stopTest();

        mixes = [SELECT Id, Name, Customer__c, Primary_Genre__c, Secondary_Genre__c FROM Mix__c];

        System.assertEquals(1, mixes.size());
        System.assertEquals('New Mix', mixes[0].Name);
        System.assertEquals(TestHelper.GENRE_ROCK, mixes[0].Primary_Genre__c);
        System.assertEquals(TestHelper.GENRE_POP, mixes[0].Secondary_Genre__c);
    }

    @isTest
    static void updateExistingMixMoreSongs()
    {
        Mix__c mixToUpdate = [SELECT Id FROM Mix__c LIMIT 1];

        List<Song__c> songs = [SELECT Id FROM Song__c LIMIT 20];

        MixWrapper mixWrapper = new MixWrapper(mixToUpdate.Id, 'Updated Mix', null, songs);

        Test.startTest();
        MixService.updateExistingMix(mixWrapper);
        Test.stopTest();

        Mix__c mix = [SELECT Id, Name FROM Mix__c WHERE Id = :mixToUpdate.Id];

        System.assertEquals('Updated Mix', mix.Name);
        System.assertEquals(20, [SELECT count() FROM Track__c WHERE Mix__c = :mix.Id]);
    }

    @isTest
    static void updateExistingMixLessSongs()
    {
        Mix__c mixToUpdate = [SELECT Id FROM Mix__c LIMIT 1];

        List<Song__c> songs = [SELECT Id FROM Song__c LIMIT 5];

        MixWrapper mixWrapper = new MixWrapper(mixToUpdate.Id, 'Updated Mix', null, songs);

        Test.startTest();
        MixService.updateExistingMix(mixWrapper);
        Test.stopTest();

        Mix__c mix = [SELECT Id, Name FROM Mix__c WHERE Id = :mixToUpdate.Id];

        System.assertEquals('Updated Mix', mix.Name);
        System.assertEquals(5, [SELECT count() FROM Track__c WHERE Mix__c = :mix.Id]);
    }
}