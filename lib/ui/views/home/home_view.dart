import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_app/pages/playlistsPage.dart';
import 'package:stacked/stacked.dart';
import 'dart:convert' as convert;

import '../../../pages/artistsPage.dart';
import '../../../services/storage.dart';
import '../../../services/endpoints.dart';
import '../../../pages/favouritesPage.dart';
import 'home_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isLoading = true;
  bool isSearching = false;
  final artistController = TextEditingController();
  final SecureStorage secureStorage = SecureStorage();
  dynamic newRelease;
  dynamic topArtist;
  Endpoints endpoints = Endpoints();
  dynamic playlists;
  dynamic featuredPlaylist;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => _getContext());
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    artistController.dispose();
    super.dispose();
  }

  _getContext() async {
    isLoading = true;
    var response = await http.get(
      Uri.parse(endpoints.getFeaturedPlaylist),
      headers: <String, String>{
        'Authorization':
        'Bearer ${await secureStorage.readSecureData('apiToken')}',
        'Content-Type': 'application/json',
      },
    );
    var playlistsJson = convert.jsonDecode(response.body);
    playlists = playlistsJson['playlists']['items'];
    imageUrl = playlistsJson['playlists']['items'][0]['images'][0]['url'];
    setState(() {
      isLoading = false;
    });
  }

  _searchArtists (String searchString) async {
    setState(() {
      isSearching = true;
    });
    if (searchString.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Please enter an artist to search'),
          );
        },
      );
      setState(() {
        isSearching = false;
      });
    } else {
      var response = await http.get(
        Uri.parse(endpoints.getSearchQuery + searchString),
        headers: <String, String>{
          'Authorization':
          'Bearer ${await secureStorage.readSecureData('apiToken')}',
          'Content-Type': 'application/json',
        },
      );
      var artists = convert.jsonDecode(response.body);
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ArtistsPage(artists)));
      setState(() {
        isSearching = false;
      });
    }
  }

  _getPlaylists() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => PlaylistsPage(playlists)));
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      builder: (context, model, child) => GestureDetector(
          onTap: () { //here
            FocusScope.of(context).unfocus();
            TextEditingController().clear();
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Home Page'),
              actions: [
                IconButton(
                    onPressed: () {Navigator.push(
                        context, MaterialPageRoute(builder: (_) => FavouritesPage()));},
                    icon: const Icon(Icons.favorite_border)
                )
              ],
            ),
            body: Center(
              child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: <Widget>[
                    !isSearching ? Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          child: Text(
                            'Enter an artist for similar recommendations',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          child: TextField(
                            onEditingComplete: () => _searchArtists(artistController.text),
                            controller: artistController,
                            decoration: const InputDecoration(
                                prefixIcon:
                                Icon(Icons.search),
                                border: OutlineInputBorder(),
                                labelText: 'Favourite Artist',
                                hintText: 'Enter your Favourite Artist'
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          child: ElevatedButton(
                              onPressed: () => _searchArtists(artistController.text),
                              child: const Text('Search for similar artists')
                          )
                        ),
                      ],
                    ) : const Center(child: CircularProgressIndicator()),
                    !isLoading ? Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              const Text(
                                'Featured Playlists',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                height: 360,
                                child: InkWell(
                                  onTap: () => _getPlaylists(),
                                )
                              ),
                            ],
                          )
                        ),
                      ],
                    ) : const LinearProgressIndicator(),
                  ]
              )
            ),
          ),
        ),
      viewModelBuilder: () => HomeViewModel(),
    );
  }
}