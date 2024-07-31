@isTest
private class MixBuilderControllerTest 
{
    @TestSetup
    static void makeData(){
        TestHelper.insertTestMixes();
    }

    @isTest
    static void testGetMix()
    {
        Mix__c mix = [SELECT Id, Name, Customer__c FROM Mix__c LIMIT 1];

        Test.startTest();
        String mixJson = MixBuilderController.getMix(mix.Id);
        Test.stopTest();

        MixWrapper wrapper = (MixWrapper)JSON.deserialize(mixJson, MixWrapper.class);

        System.assertEquals(mix.Id, wrapper.mixId);
        System.assertEquals(mix.Name, wrapper.mixName);
        System.assertEquals(mix.Customer__c, wrapper.contactId);
        System.assertEquals(10, wrapper.selectedSongs.size());
    }

    @isTest
    static void testHandleMixUpsertNew()
    {
        List<Mix__c> mixes = [SELECT Id, Name FROM Mix__c];
        delete mixes;

        MixWrapper wrapper = new MixWrapper(
            null, 'Name', null,
            [SELECT Id, Name FROM Song__c LIMIT 10]
        );

        Test.startTest();
        MixBuilderController.handleMixUpsert(JSON.serialize(wrapper));
        Test.stopTest();

        List<Mix__c> newMixes = [SELECT Id, Name, Customer__c FROM Mix__c];

        List<Track__c> mixTracks = [SELECT Id, Song__c FROM Track__c WHERE Mix__c = :newMixes[0].Id];

        System.assertEquals(1, newMixes.size());
        Mix__c newMix = newMixes[0];
        System.assertEquals(wrapper.mixName, newMix.Name);
        System.assertEquals(wrapper.contactId, newMix.Customer__c);
        System.assertEquals(10, mixTracks.size());
    }

    @isTest
    static void updateExistingMixLessSongs()
    {
        Mix__c mix = [SELECT Id, Name FROM Mix__c LIMIT 1];
        List<Track__c> tracks = [SELECT Id, Song__c FROM Track__c WHERE Mix__c = :mix.Id];

        MixWrapper wrapper = new MixWrapper(
            mix.Id, mix.Name, null,
            [SELECT Id, Name FROM Song__c LIMIT 5]
        );

        Test.startTest();
        MixBuilderController.handleMixUpsert(JSON.serialize(wrapper));
        Test.stopTest();

        List<Track__c> updatedTracks = [SELECT Id, Index__c FROM Track__c WHERE Mix__c = :mix.Id];

        System.assertEquals(5, updatedTracks.size());
    }

    @isTest
    static void updateExistingMixMoreSongs()
    {
        Mix__c mix = [SELECT Id, Name FROM Mix__c LIMIT 1];
        List<Track__c> tracks = [SELECT Id, Song__c FROM Track__c WHERE Mix__c = :mix.Id];

        MixWrapper wrapper = new MixWrapper(
            mix.Id, mix.Name, null,
            [SELECT Id, Name FROM Song__c LIMIT 15]
        );

        Test.startTest();
        MixBuilderController.handleMixUpsert(JSON.serialize(wrapper));
        Test.stopTest();

        List<Track__c> updatedTracks = [SELECT Id, Index__c FROM Track__c WHERE Mix__c = :mix.Id];

        System.assertEquals(15, updatedTracks.size());
    }

    @isTest
    static void produceVinylAndEmail()
    {
        Mix__c mix = [SELECT Id, Name FROM Mix__c LIMIT 1];
        List<Track__c> tracks = [SELECT Id, Song__c, Index__c FROM Track__c WHERE Mix__c = :mix.Id];

        List<MixWrapper.SongIndex> songIndexes = new List<MixWrapper.SongIndex>();

        for(Integer i = 0; i < tracks.size(); i++)
        {
            songIndexes.add(new MixWrapper.SongIndex(tracks[i].Song__c, i));
        }

        MixWrapper wrapper = new MixWrapper(
            mix.Id, mix.Name, null,
            songIndexes
        );

        Test.startTest();
        MixBuilderController.handleVinylProduce(JSON.serialize(wrapper));
        Test.stopTest();

        tracks = [SELECT Id, Song__c, Index__c FROM Track__c WHERE Mix__c = :mix.Id];
        for(Track__c track : tracks)
        {
            System.assertNotEquals(null, track.Index__c);
        }
    }

    @isTest
    static void testSendEmailPdf()
    {
        insert new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@email.com');
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        MixBuilderController.sendEmailWithPdf(contact.Id, TestHelper.PDF_BASE64, 'Test');
        Test.stopTest();

        List<EmailMessage> emails = [SELECT Id FROM EmailMessage];
        System.assertEquals(1, emails.size());
    }

    @isTest
    static void getSongsByIds()
    {
        List<Song__c> songs = [SELECT Id FROM Song__c LIMIT 50];
        Set<Id> songIds = Utils.getIdFieldValue(songs, 'Id');

        Test.startTest();
        List<Song__c> selectedSongs = MixBuilderController.getSongsByIds(new List<Id>(songIds));
        Test.stopTest();

        System.assertEquals(50, selectedSongs.size());
    }

    @isTest
    static void getSongsByGenre()
    {
        Test.startTest();
        List<Song__c> songs = MixBuilderController.getSongsByGenre(TestHelper.GENRE_ROCK, 0);
        Test.stopTest();

        if(Consts.PAGINATION_BATCH_SIZE < 100)
        {
            System.assertEquals(Consts.PAGINATION_BATCH_SIZE, songs.size());
        }
        else
        {
            System.assertEquals(100, songs.size());
        }

        for(Song__c song : songs)
        {
            System.assertEquals(TestHelper.GENRE_ROCK, song.Genre__c);
        }
    }

    @isTest
    static void getGenres()
    {
        Test.startTest();
        List<String> res = MixBuilderController.getGenres();
        Test.stopTest();

        List<String> genres = new List<String>();
        List<Schema.PicklistEntry> picklistEntries = Song__c.Genre__c.getDescribe().getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            genres.add(entry.getLabel());
        }

        System.assertEquals(genres, res);
    }

    @isTest
    static void getTrackOrder()
    {
        Mix__c mix = [SELECT Id FROM Mix__c LIMIT 1];

        Test.startTest();
        List<Map<String, Object>> trackOrder = MixBuilderController.getTrackOrder(mix.Id);
        Test.stopTest();

        for(Map<String, Object> track : trackOrder)
        {
            System.assertNotEquals(null, track.get(Consts.FIELD_ID));
            System.assertEquals(null, track.get(Consts.FIELD_INDEX));
        }
    }

    @isTest
    static void getPages()
    {
        Test.startTest();
        Integer pages = MixBuilderController.getPages(TestHelper.GENRE_ROCK);
        Test.stopTest();

        System.assertEquals(5, pages);
    }
}