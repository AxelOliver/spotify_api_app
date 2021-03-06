import 'package:spotify_app/models/artist.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

class DbHelper {
  // DbHelper class is a singleton to optimise loading times
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final database = openDatabase(
      Path.join(await getDatabasesPath(), 'spotifyAppDBTest.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE favourite_artists(id INTEGER PRIMARY KEY, spotify_id TEXT, name TEXT, is_favourite INTEGER)',
        );
      },
      version: 1,
    );
    return database;
  }

  Future<List<Artist>> getFavourites() async {
    Database db = await instance.database;
    var favourites = await db.query('favourite_artists', orderBy: 'name');
    List<Artist> artists = favourites.isNotEmpty?
      favourites.map((e) => Artist.fromMap(e)).toList()
            : [];
    return artists;
  }

  Future<List<Artist>> searchFavourites(String searchTerm) async {
    // returns all favourites if passed empty string to work with TextFields
    if (searchTerm == "") {
      print(searchTerm);
      return getFavourites();
    } else {
      Database db = await instance.database;
      var result = await db.query(
          'favourite_artists',
          where: 'UPPER(name) LIKE UPPER(\'%$searchTerm%\')',
          orderBy: 'UPPER(name)');
      //SELECT * FROM favourite_artists WHERE UPPER(name) LIKE UPPER(\'$searchTerm\')
      List<Artist> artists = result.isNotEmpty?
      result.map((e) => Artist.fromMap(e)).toList()
          : [];
      return artists;
    }
  }

  Future<int> add(Artist artist) async {
    Database db = await instance.database;
    return await db.insert('favourite_artists', artist.toMap());
  }

  // uses spotify ID so
  Future<int> remove(String spotifyId) async {
    Database db = await instance.database;
    return await db.delete('favourite_artists', where: 'spotify_id = ?', whereArgs: [spotifyId]);
  }

  Future<bool> isFavourite(String spotifyId) async {
    Database db = await instance.database;
    var isFavourite = await db.rawQuery('SELECT is_favourite FROM favourite_artists WHERE spotify_id=\'$spotifyId\'');
    if (isFavourite.isNotEmpty) {
      if (isFavourite[0]['is_favourite'] == 1){
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}