import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/storage.dart';
import 'pages/homePage.dart';
import 'services/endpoints.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SecureStorage secureStorage = SecureStorage();
  bool isLoading = false;
  TextEditingController clientIdController = TextEditingController();
  TextEditingController clientSecretController = TextEditingController();

  _loginPressed(
    String clientID,
    String clientSecret,
  ) async {
    setState(() {
      isLoading = true;
    });
    String credentials = "$clientID:$clientSecret";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);
    Endpoints endPoints = Endpoints();

    var response = await http.post(
      Uri.parse(endPoints.getToken),
      headers: <String, String>{
        'Authorization': 'Basic $encoded',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: <String, String>{
        'grant_type': 'client_credentials',
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      secureStorage.writeSecureData(
          'apiToken', jsonResponse['access_token'].toString());
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Request failed with code: ${response.statusCode}'),
          );
        },
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Login Page"),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isLoading
                  ? const CircularProgressIndicator(
                      semanticsLabel: 'Linear progress indicator',
                    )
                  : Container(
                      height: 50,
                      width: 250,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                        onPressed: () => _loginPressed(
                            dotenv.env['CLIENT_ID'] ?? 'Client id not found',
                            dotenv.env['CLIENT_SECRET'] ??
                                'Client secret not found'),
                        child: const Text(
                          'Start exploring',
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ),
            ],
          ),
        ));
  }
}
