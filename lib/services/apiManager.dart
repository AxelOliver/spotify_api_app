import 'dart:convert';

import 'storage.dart';
import 'package:http/http.dart' as http;
import 'endpoints.dart';

class ApiManager {
  Endpoints endpoints = Endpoints();
  SecureStorage secureStorage = SecureStorage();

   Future getArtistDetails(String artistName) async{
    var response = await http.get(
      Uri.parse(Uri.encodeFull(endpoints.getArtistDetails + (artistName))),
      headers: <String, String>{
        'Authorization':
        'Bearer ${await secureStorage.readSecureData('apiToken')}',
        'Content-Type': 'application/json',
      },
    );
    var detailsResponse = jsonDecode(response.body);
    if (detailsResponse['artists'] != null) {
      return detailsResponse['artists'][0]['strBiographyEN'] as String;
    } else {
      return 'Couldn\'t find artist summary';
    }
  }

  Future getSeveralArtists({required List<String> spotifyIds}) async {
     String idString = "";
     spotifyIds.forEach((element) { idString += element + ','; });
    var response = await http.get(
      Uri.parse(Uri.encodeFull(endpoints.getSeveralArtists + idString)),
      headers: <String, String>{
        'Authorization':
        'Bearer ${await secureStorage.readSecureData('apiToken')}',
        'Content-Type': 'application/json',
      },
    );
     var artistList = jsonDecode(response.body);
     if (artistList['artists'] != null) {
       return artistList['artists'];
     } else {
       return 'Couldn\'t find artists';
     }
  }

  Future getArtistFromId({required spotifyId}) async {
    var response = await http.get(
      Uri.parse(Uri.encodeFull(endpoints.getArtistFromId + (spotifyId))),
      headers: <String, String>{
        'Authorization':
        'Bearer ${await secureStorage.readSecureData('apiToken')}',
        'Content-Type': 'application/json',
      },
    );
    var detailsResponse = jsonDecode(response.body);
    if (detailsResponse != null) {
      return detailsResponse;
    } else {
      return 'Couldn\'t find artist summary';
    }
  }
}