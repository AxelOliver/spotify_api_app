import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_app/pages/playlistsPage.dart';
import 'dart:convert' as convert;

import '../../../pages/artistsPage.dart';
import '../../../services/endpoints.dart';
import '../../../services/storage.dart';
import 'home_view.dart';

class HomeViewModel extends BaseViewModel {
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  TextEditingController _artistController = TextEditingController();
  TextEditingController get artistController => _artistController;
  dynamic _newRelease;
  get newRelease => _newRelease;
  dynamic _topArtist;
  get topArtist => _topArtist;
  dynamic _playlists;
  get playlists => _playlists;
  dynamic _featuredPlaylist;
  get featuredPlaylist => _featuredPlaylist;
  String _imageUrl = '';
  String get imageUrl => _imageUrl;

  final Endpoints _endpoints = Endpoints();
  final SecureStorage _secureStorage = SecureStorage();

  _getContext() async {
    _isLoading = true;
    notifyListeners();
    var response = await http.get(
      Uri.parse(_endpoints.getFeaturedPlaylist),
      headers: <String, String>{
        'Authorization':
        'Bearer ${await _secureStorage.readSecureData('apiToken')}',
        'Content-Type': 'application/json',
      },
    );
    var playlistsJson = convert.jsonDecode(response.body);
    _playlists = playlistsJson['playlists']['items'];
    _imageUrl = playlistsJson['playlists']['items'][0]['images'][0]['url'];
    _isLoading = false;
    notifyListeners();
  }

  _searchArtists (String searchString) async {
    _isSearching = true;
    notifyListeners();
    if (searchString.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Please enter an artist to search'),
          );
        },
      );
      _isSearching = false;
      notifyListeners();
    } else {
      var response = await http.get(
        Uri.parse(_endpoints.getSearchQuery + searchString),
        headers: <String, String>{
          'Authorization':
          'Bearer ${await _secureStorage.readSecureData('apiToken')}',
          'Content-Type': 'application/json',
        },
      );
      var artists = convert.jsonDecode(response.body);
      // TODO: implement auto router
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ArtistsPage(artists)));
      _isSearching = false;
      notifyListeners();
    }
  }

  _getPlaylists() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => PlaylistsPage(_playlists)));
  }
}