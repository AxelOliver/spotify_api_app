import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

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

  String _capitalize(String input) {
    final List<String> splitStr = input.split(' ');
    for (int i = 0; i < splitStr.length; i++) {
      splitStr[i] =
          '${splitStr[i][0].toUpperCase()}${splitStr[i].substring(1)}';
    }
    final output = splitStr.join(' ');
    return output;
  }

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
                  child: artistSummary == null
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Could not find Artist summary.'),
                        )
                      : ListView(
                          children: [
                            Column(
                              children: [
                                artistSummary['strArtistFanart'] != null
                                    ? Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    artistSummary[
                                                        'strArtistFanart']),
                                                fit: BoxFit.cover)),
                                        child: Container(
                                          width: double.infinity,
                                          height: 300,
                                          child: Container(),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    widget.artist['images'][0]
                                                        ['url']),
                                                fit: BoxFit.cover)),
                                        child: Container(
                                          width: double.infinity,
                                          height: 300,
                                          child: Container(),
                                        ),
                                      ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  artistSummary['strArtist'],
                                  style: const TextStyle(
                                      fontSize: 25.0,
                                      color: Colors.black,
                                      letterSpacing: 2.0,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
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
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const SizedBox(
                                                height: 7,
                                              ),
                                              Text(
                                                f.format(
                                                    widget.artist['followers']
                                                        ['total']),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 22.0,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              const Text(
                                                "Rank",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontSize: 22.0,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const SizedBox(
                                                height: 7,
                                              ),
                                              Text(
                                                f.format(widget
                                                    .artist['popularity']),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 22.0,
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                  child: artistSummary['strBiographyEN'] != null
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