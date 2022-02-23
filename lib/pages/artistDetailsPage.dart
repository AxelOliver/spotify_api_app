import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../data/dbHelper.dart';
import '../models/artist.dart';
import '../services/endpoints.dart';
import '../services/storage.dart';
import '../services/apiManager.dart';

class ArtistDetails extends StatefulWidget {
  dynamic artist;
  ArtistDetails(this.artist, {Key? key}) : super(key: key);

  @override
  _ArtistDetailsState createState() => _ArtistDetailsState();
}

class _ArtistDetailsState extends State<ArtistDetails> {
  final SecureStorage secureStorage = SecureStorage();
  final Endpoints endpoints = Endpoints();
  final ApiManager _apiManager = ApiManager();
  bool isLoading = true;
  var f = NumberFormat('###,###,###,##0', 'fr');
  var artistSummary;

  void _launchURL(dynamic artist) async {
    if (!await launch(artist['external_urls']['spotify'])) {
      throw 'Could not launch ${artist['external_urls']['spotify']}';
    }
  }

  Future _getArtistSummary(String name) async {
    setState(() {
      isLoading = true;
    });
    var response = await http.get(
      Uri.parse(Uri.encodeFull(endpoints.getArtistDetails + (name))),
    );
    var detailsResponse = jsonDecode(response.body);
    if (detailsResponse['artists'] != null) {
      debugPrint('not null');
      artistSummary = detailsResponse['artists'][0];
    } else {
      debugPrint('null');
      artistSummary = null;
    }
    setState(() {
      isLoading = false;
    });
  }

  _addFavourite(dynamic context) async {
    await DbHelper.instance.add(
      Artist(
          spotifyId: context['id'], name: context['name'], isFavourite: true),
    );
  }

  _removeFavourite(dynamic context) async {
    await DbHelper.instance.remove(context['id']);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => _getArtistSummary(widget.artist['name']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.artist['name']),
        ),
        body: Container(
          child: isLoading
              ? const Center(child: LinearProgressIndicator())
              : Center(
                  child: ListView(
                    children: [
                      Column(
                        children: [
                          artistSummary != null &&
                                  artistSummary['strArtistFanart'] != null
                              ? Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              artistSummary['strArtistFanart']),
                                          fit: BoxFit.cover)),
                                  child: const SizedBox(
                                    width: double.infinity,
                                    height: 300,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(widget
                                              .artist['images'][0]['url']),
                                          fit: BoxFit.cover)),
                                  child: const SizedBox(
                                    width: double.infinity,
                                    height: 300,
                                  ),
                                ),
                          const SizedBox(
                            height: 20,
                          ),
                          Stack(children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                widget.artist['name'],
                                style: const TextStyle(
                                    fontSize: 25.0,
                                    color: Colors.black,
                                    letterSpacing: 2.0,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FutureBuilder(
                                    future: DbHelper.instance
                                        .isFavourite(widget.artist['id']),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<bool> snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Center(
                                            child: Text('Loading...'));
                                      }
                                      return !snapshot.data!
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.favorite_border,
                                                color: Colors.black,
                                                size: 36,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _addFavourite(widget.artist);
                                                });
                                              })
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.favorite,
                                                color: Colors.red,
                                                size: 36,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _removeFavourite(widget.artist);
                                                });
                                              });
                                    }),
                              ),
                            ),
                          ]),
                          const SizedBox(
                            height: 10,
                          ),
                          artistSummary != null &&
                                  artistSummary['strCountry'] != null
                              ? Text(
                                  artistSummary['strCountry'],
                                  style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black54,
                                      letterSpacing: 2.0,
                                      fontWeight: FontWeight.w600),
                                )
                              : const SizedBox(
                                  height: 10,
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 8.0),
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Followers",
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 7,
                                        ),
                                        Text(
                                          f.format(widget.artist['followers']
                                              ['total']),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Text(
                                          "Popularity",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(
                                          height: 7,
                                        ),
                                        Text(
                                          f.format(widget.artist['popularity']),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 22.0,
                                              fontWeight: FontWeight.w500),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: artistSummary != null &&
                                    artistSummary['strBiographyEN'] != null
                                ? Text(
                                    artistSummary['strBiographyEN'],
                                    style: const TextStyle(
                                        fontSize: 15, wordSpacing: 1),
                                  )
                                : const Text('Could not find summary'),
                          ),
                          ElevatedButton(
                              onPressed: () => _launchURL(widget.artist),
                              child: const Text('Open in spotify')),
                        ],
                      )
                    ],
                  ),
                ),
        ));
  }
}
