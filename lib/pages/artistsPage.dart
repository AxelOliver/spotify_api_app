import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_app/pages/artistDetailsPage.dart';
import 'dart:convert';

import '../services/storage.dart';
import '../constants/endpoints.dart';
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

  _getArtistDetails(dynamic artist) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => ArtistDetails(artist)));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(
        (_) => _getRelatedArtists(widget.artists['artists']['items'][0]['id']));
  }

  @override
  Widget build(BuildContext context) {
    print(widget.artists);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artists Page'),
      ),
      body: Center(
        child: isLoading
            ? const Center(child: LinearProgressIndicator())
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
                      imageInteractionCard(widget.artists['artists']['items'][0],
                          _getArtistDetails),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'If you like ${widget.artists['artists']['items'][0]['name']}, maybe you\'ll like',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (var artist in artistList['artists'])
                    imageInteractionCard(artist, _getArtistDetails),
                ],
              ),
      ),
    );
  }
}
