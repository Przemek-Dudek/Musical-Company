@isTest
private class SongSelectorTest
{
    @TestSetup
    static void makeData()
    {
        List<Song__c> songs = new List<Song__c>();

        for(Integer i = 0; i < 200; i++)
        {
            Song__c song = new Song__c();
            song.Name = 'Test' + i;
            song.Length__c = 180;
            song.Artist__c = 'Test Artist' + i;
            song.Track_Count__c = 0;
            song.Track_Licenses__c = 10;

            if(i < 100)
            {
                song.Genre__c = 'Rock';
            }
            else
            {
                song.Genre__c = 'Pop';
            }

            songs.add(song);
        }

        insert songs;
    }

    @isTest
    static void selectById()
    {
        List<Song__c> songs = [SELECT Id FROM Song__c LIMIT 50];

        Set<Id> songIds = Utils.getIdFieldValue(songs, 'Id');

        Test.startTest();
        List<Song__c> selectedSongs = SongSelector.selectById(songIds);
        Test.stopTest();

        System.assertEquals(50, selectedSongs.size());
    }

    @isTest
    static void selectByGenre()
    {
        Test.startTest();
        List<Song__c> songs = SongSelector.selectByGenre('Rock', 0);
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
            System.assertEquals('Rock', song.Genre__c);
        }
    }

    @isTest
    static void numberOfRecords()
    {
        Test.startTest();
        AggregateResult result = SongSelector.numberOfRecords('Rock');
        Test.stopTest();

        System.debug(result);

        Integer numberOfRecords = (Integer) result.get('n');

        System.assertEquals(100, numberOfRecords);
    }
}