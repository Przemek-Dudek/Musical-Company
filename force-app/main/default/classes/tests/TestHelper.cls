@isTest
public class TestHelper
{
    public static final String GENRE_ROCK = 'Rock';
    public static final String GENRE_POP = 'Pop';
    public static final String PDF_BASE64 = 'JVBERi0xLjUKJYCBgoMKMSAwIG9iago8PC9GaWx0ZXIvRmxhdGVEZWNvZGUvRmlyc3QgMTQxL04gMjAvTGVuZ3==';

    @isTest
    public static void insertTestMixes()
    {
        List<Song__c> songs = new List<Song__c>();
        List<Track__c> tracks = new List<Track__c>();
        List<Mix__c> mixes = new List<Mix__c>();

        for(Integer i = 0; i < 50; i++)
        {
            Song__c song = new Song__c();
            song.Name = 'Test' + i;
            song.Length__c = 180;
            song.Artist__c = 'Test Artist' + i;
            song.Track_Count__c = 0;
            song.Track_Licenses__c = 10;
            song.Genre__c = GENRE_ROCK;

            songs.add(song);
        }

        insert songs;

        for(Integer i = 0; i < 3; i++)
        {
            Mix__c mix = new Mix__c();
            mix.Name = 'Test Mix' + i;

            mixes.add(mix);
        }

        insert mixes;

        for(Mix__c mix : mixes)
        {
            for(Integer i = 0; i < 10; i++)
            {
                Track__c track = new Track__c();
                track.Mix__c = mix.Id;
                track.Song__c = songs[i].Id;

                tracks.add(track);
            }
        }

        insert tracks;
    }
}