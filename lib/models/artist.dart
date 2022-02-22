class Artist {
  final int? id;
  final String spotifyId;
  final String name;
  final bool isFavourite;

  const Artist({this.id,
    required this.spotifyId,
    required this.name,
    required this.isFavourite});

  Map<String, dynamic> toMap() {
    int boolToInt;
    if (isFavourite) {
      boolToInt = 1;
    } else {
      boolToInt = 0;
    }
    return {
      'id': id,
      'spotify_id': spotifyId,
      'name': name,
      'is_favourite': boolToInt
    };
  }

  static Artist fromMap(Map<String, dynamic> artist) {
    bool intToBool;
    if( artist['is_favourite'] == 1) {
      intToBool = true;
    } else {
      intToBool = false;
    }
      return Artist(id: artist['id'],
          spotifyId: artist['spotify_id'],
          name: artist['name'],
          isFavourite: intToBool);
    }

  @override
  String toString() {
    return 'Artist{id: $id, spotifyId: $spotifyId, name: $name, isFavourite: $isFavourite';
  }
}
