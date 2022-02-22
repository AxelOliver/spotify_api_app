import 'package:flutter/material.dart';
import 'package:spotify_app/data/dbHelper.dart';
import 'package:sqflite/sqflite.dart';

import '../models/artist.dart';
import 'artistDetailsPage.dart';
import '../services/apiManager.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final ApiManager _apiManager = ApiManager();

  _removeFavourite(String spotifyId) async {
    await DbHelper.instance.remove(spotifyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
      ),
      body: Center(
          child: FutureBuilder<List<Artist>>(
            future: DbHelper.instance.getFavourites(),
            builder: (BuildContext context, AsyncSnapshot<List<Artist>> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Text('Loading...'));
              }
              return snapshot.data!.isEmpty
                  ? Center(child: Text('No Artists in List.'))
                  : ListView(
                children: snapshot.data!.map((artist) {
                  return Center(
                    child: ListTile(
                      title: Text(
                          artist.name,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w700),
                      ),
                      minVerticalPadding: 9,
                      trailing: IconButton(
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 36,
                          ),
                          onPressed: () {
                            setState(() {
                              _removeFavourite(artist.spotifyId);
                            });
                          }
                      ),
                      onTap: () async {
                        var artistObject = (await _apiManager.getArtistFromId(spotifyId: artist.spotifyId));
                        await Navigator.push(
                            context, MaterialPageRoute(builder: (_) => ArtistDetails(artistObject)));
                        setState(() {});
                      },
                    ),
                  );
              }).toList(),
              );
            }),
          ),
      );
  }
}
