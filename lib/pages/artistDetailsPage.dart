import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/endpoints.dart';
import '../services/storage.dart';

class ArtistDetails extends StatefulWidget {
  dynamic artist;
  ArtistDetails( this.artist, {Key? key}) : super(key: key);

  @override
  _ArtistDetailsState createState() => _ArtistDetailsState();
}

class _ArtistDetailsState extends State<ArtistDetails> {
  SecureStorage secureStorage = SecureStorage();
  Endpoints endpoints = Endpoints();
  bool isLoading = true;
  String artistSummary = "";

  String _capitalize(String input) {
    final List<String> splitStr = input.split(' ');
    for (int i = 0; i < splitStr.length; i++) {
      splitStr[i] =
      '${splitStr[i][0].toUpperCase()}${splitStr[i].substring(1)}';
    }
    final output = splitStr.join(' ');
    return output;
  }

  Future _getArtistSummary(String name) async {
    setState(() {
      isLoading = true;
    });
    print(Uri.encodeFull(endpoints.getWikiDetails + _capitalize(name)));
    var response = await http.get(
      Uri.parse(Uri.encodeFull(endpoints.getWikiDetails + _capitalize(name))),
    );
    var wikiResponse = jsonDecode(response.body);
    print(wikiResponse['query']['pages'].keys.elementAt(0).runtimeType);
    if (wikiResponse['query']['pages'].keys.elementAt(0) != '-1'){
      artistSummary = wikiResponse['query']['pages'].values.elementAt(0)['extract'];
    } else {
      artistSummary = 'Could not get summary. Page does not exist.';
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
        body: Center(
            child: isLoading? const Center(
                child: LinearProgressIndicator()
            ) : Center(
              child: Text(artistSummary.split('.')[0] + '.'
                  + artistSummary.split('.')[1] + '.')
            )
        )
    );
  }
}
