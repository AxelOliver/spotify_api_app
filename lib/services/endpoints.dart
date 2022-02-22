class Endpoints {
  final String getToken = 'https://accounts.spotify.com/api/token';
  final String getNewAlbum = 'https://api.spotify.com/v1/browse/new-releases';

  /* Retrieves featured playlist from spotify API
      json structure:
      {
        "albums": {
          "href": "https://api.spotify.com/v1/me/shows?offset=0&limit=20\n",
          "items": [
            {
              "collaborative": bool,
                "description": "String",
                "external_urls": {
                    "spotify": "String"
                },
                "href": "String",
                "id": "String",
                "images": [
                    {
                        "height": int,
                        "url": "String",
                        "width": int
                    }
                ],
                "name": "String",
                "owner": {
                    "display_name": "String",
                    "external_urls": {
                        "spotify": "String"
                    },
                    "href": "String",
                    "id": "String",
                    "type": "String",
                    "uri": "String"
                },
                "primary_color": null,
                "public": null,
                "snapshot_id": "String",
                "tracks": {
                    "href": "String",
                    "total": int
                },
                "type": "String",
                "uri": "String"
            }
          ],
          "limit": int,
          "next": "String",
          "offset": int,
          "previous": "String",
          "total": int
        },
        "message": "string"
      }
  */
  final String getFeaturedPlaylist = 'https://api.spotify.com/v1/browse/featured-playlists';
  final String getSearchQuery = 'https://api.spotify.com/v1/search?type=artist&limit=1&q=';
  final String getArtistFromId = 'https://api.spotify.com/v1/artists/';

  /*
  Gets Related artists based on entered artist ID
  Json Structure:
    {
      "artists": [
        {
          "external_urls": {
            "spotify": "string"
          },
          "followers": {
            "href": "string",
            "total": 0
          },
          "genres": [
            "Prog rock",
            "Grunge"
          ],
          "href": "string",
          "id": "string",
          "images": [
            {
              "url": "https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228\n",
              "height": 300,
              "width": 300
            }
          ],
          "name": "string",
          "popularity": 0,
          "type": "artist",
          "uri": "string"
        }
      ]
    }
   */
  String getRelatedArtists(String artistID) {
    return 'https://api.spotify.com/v1/artists/$artistID/related-artists';
  }
  final String getArtistDetails = 'https://theaudiodb.com/api/v1/json/2/search.php?s=';
  final String getSeveralArtists = 'https://api.spotify.com/v1/artists&ids=';
}