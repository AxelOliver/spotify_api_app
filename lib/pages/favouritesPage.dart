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
  final TextEditingController _searchController = TextEditingController();
  String searchString = "";

  _removeFavourite(String spotifyId) async {
    await DbHelper.instance.remove(spotifyId);
  }
  VoidCallback? _searchFavourites() {
    setState(() {
      searchString = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                      hintText: 'Search Favourites'),
                  onChanged: (String? newValue) {
                    setState(() {
                      searchString = newValue!;
                    });
                  }
              ),
            ),
            FutureBuilder<List<Artist>>(
              // searchFavourites returns all favourites if passed empty string
                future: DbHelper.instance.searchFavourites(searchString),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Artist>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Loading...'));
                  }
                  return snapshot.data!.isEmpty
                      ? const Center(
                      child: Text(
                      'No Artists found.',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w700),
                  ))
                      : Flexible(
                          child: ListView(
                            // map each artist to a tile
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
                                      }),
                                  onTap: () async {
                                    var artistObject =
                                        (await _apiManager.getArtistFromId(
                                            spotifyId: artist.spotifyId));
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                ArtistDetails(artistObject)));
                                    setState(() {});
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                }),
          ],
        ),
      ),
    );
  }
}
