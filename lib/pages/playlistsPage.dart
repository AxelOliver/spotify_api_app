import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_app/pages/artistDetailsPage.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import '../services/storage.dart';
import '../constants/endpoints.dart';
import 'widgets/imageInteractionCard.dart';

class PlaylistsPage extends StatefulWidget {
  dynamic playlists;
  PlaylistsPage(this.playlists, {Key? key}) : super(key: key);

  @override
  _PlaylistsPageState createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final SecureStorage secureStorage = SecureStorage();
  final Endpoints endpoints = Endpoints();
  bool isLoading = false;
  dynamic artistList;

  void _launchURL(dynamic playlist) async {
    if (!await launch(playlist['external_urls']['spotify'])) {
      throw 'Could not launch ${playlist['external_urls']['spotify']}';
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.playlists);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Featured Playlists'),
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
                for (var playlist in widget.playlists)
                  imageInteractionCard(playlist, _launchURL),
              ]
            )
          ],
        ),
      ),
    );
  }
}
