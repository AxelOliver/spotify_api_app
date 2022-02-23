import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_app/pages/artistDetailsPage.dart';
import 'dart:convert';

import '../services/storage.dart';
import '../services/endpoints.dart';
import 'favouritesPage.dart';
import 'widgets/imageInteractionCard.dart';

class ArtistsPage extends StatefulWidget {
  dynamic artists;
  ArtistsPage(this.artists, {Key? key}) : super(key: key);

  @override
  _ArtistsPageState createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  final SecureStorage secureStorage = SecureStorage();
  final Endpoints endpoints = Endpoints();
  bool isLoading = true;
  dynamic artistList;

  // TODO: refactor function to be usable more globally
  _getRelatedArtists(String id) async {
    setState(() {
      isLoading = true;
    });
    var response = await http.get(
      Uri.parse(endpoints.getRelatedArtists(id)),
      headers: <String, String>{
        'Authorization':
            'Bearer ${await secureStorage.readSecureData('apiToken')}',
        'Content-Type': 'application/json',
      },
    );
    artistList = jsonDecode(response.body);
    setState(() {
      isLoading = false;
    });
  }

  _getArtistDetails(dynamic artist) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => ArtistDetails(artist)));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.artists['artists']['items'].length > 0) {
      WidgetsBinding.instance?.addPostFrameCallback((_) =>
              _getRelatedArtists(widget.artists['artists']['items'][0]['id']));
    } else {
      artistList = null;
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artists Page'),
        actions: [
          IconButton(
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => FavouritesPage()));
                // TODO: confirm if theres a better practise to refresh state
                //empty setState to reload state when new page gets popped
                setState(() {});
              },
              icon: const Icon(Icons.favorite_border))
        ],
      ),
      body: Center(
        child: isLoading
            ? const Center(child: LinearProgressIndicator())
            : artistList == null?
        const Text('Couldn\'t find artist')
        : ListView(
                children: [
                  Column(
                    children: [
                      const Padding(
                        padding:
                          EdgeInsets.only(top: 15, left: 15, right: 15),
                        child: Text(
                          'You Searched for artists similar to:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ImageInteractionCard(widget.artists['artists']['items'][0],
                            _getArtistDetails),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: artistList['artists'].length >0? Text(
                          'If you like ${widget.artists['artists']['items'][0]['name']}, maybe you\'ll like',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ) : const Text(
                          'Couldn\'t find any similar artists',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (var artist in artistList['artists'])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ImageInteractionCard(artist, _getArtistDetails),
                    ),
                ],
              ),
      ),
    );
  }
}
