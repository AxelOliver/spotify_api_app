class Endpoints {
  final String getToken = 'https://accounts.spotify.com/api/token';
  final String getNewAlbum = 'https://api.spotify.com/v1/browse/new-releases';
  final String getFeaturedPlaylist = 'https://api.spotify.com/v1/browse/featured-playlists';
  final String getSearchQuery = 'https://api.spotify.com/v1/search?type=artist&include_external=audio&limit=1&q=';
  String getRelatedArtists(String artistID) {
    return 'https://api.spotify.com/v1/artists/$artistID/related-artists';
  }
  final String getWikiDetails = 'https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&explaintext=1&titles=';
}