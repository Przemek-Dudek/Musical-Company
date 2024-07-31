@isTest
public class TestHelper
{
    public static final String GENRE_ROCK = 'Rock';
    public static final String GENRE_POP = 'Pop';
    public static final String PDF_BASE64 = 'JVBERi0xLjUKJYCBgoMKMSAwIG9iago8PC9GaWx0ZXIvRmxhdGVEZWNvZGUvRmlyc3QgMTQxL04gMjAvTGVuZ3==';

    public static final Integer CONTACT_AMOUNT = 200;
    public static final Integer MIX_AMOUNT = 200;
    public static final Integer SONG_AMOUNT = 200;

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

    @isTest
    public static void insertContacts()
    {
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < CONTACT_AMOUNT; i++)
        {
            Contact contact = new Contact();
            contact.LastName = 'Test' + i;
            contact.email = 'test' + i + '@test.com';
            contacts.add(contact);
        }

        insert contacts;
    }

    @isTest
    public static void insertEmptyMixes()
    {
        List<Mix__c> mixes = new List<Mix__c>();

        for(Integer i = 0; i < MIX_AMOUNT; i++)
        {
            Mix__c mix = new Mix__c();
            mix.Name = 'Test' + i;
            mixes.add(mix);
        }

        insert mixes;
    }

    @isTest
    public static void insertSongs()
    {
        List<Song__c> songs = new List<Song__c>();

        for(Integer i = 0; i < SONG_AMOUNT; i++)
        {
            Song__c song = new Song__c();
            song.Name = 'Test' + i;
            song.Length__c = 180;
            song.Artist__c = 'Test Artist' + i;
            song.Track_Count__c = 0;
            song.Track_Licenses__c = 10;

            if(i < SONG_AMOUNT / 2)
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

    public static List<Song__c> insert20Songs()
    {
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

        return songs;
    }
}