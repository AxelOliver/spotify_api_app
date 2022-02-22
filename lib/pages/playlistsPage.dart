import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_app/pages/artistDetailsPage.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import '../services/storage.dart';
import '../services/endpoints.dart';
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
                for (var playlist in widget.playlists)
                  ImageInteractionCard(playlist, _launchURL, isFavouritable: false),
              ]
            )
          ],
        ),
      ),
    );
  }
}
