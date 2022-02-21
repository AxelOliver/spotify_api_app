import 'dart:convert';

import 'package:http/http.dart' as http;

import 'endpoints.dart';

class ApiManager {
  Endpoints endpoints = Endpoints();

   Future getArtistDetails(String artistName) async{
    var response = await http.get(
      Uri.parse(Uri.encodeFull(endpoints.getArtistDetails + (artistName))),
    );

    var detailsResponse = jsonDecode(response.body);
    if (detailsResponse['artists'] != null) {
      return detailsResponse['artists'][0]['strBiographyEN'] as String;
    } else {
      return 'Couldn\'t find artist summary';
    }
  }
}