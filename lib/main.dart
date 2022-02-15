import 'package:flutter/material.dart';
import 'package:spotify_app/services/storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'pages/homePage.dart';
import 'constants/endpoints.dart';

void main() {
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
  final clientIdController = TextEditingController();
  final clientSecretController = TextEditingController();


  _loginPressed(String clientID, String clientSecret,) async {
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

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      secureStorage.writeSecureData('clientID', clientID);
      secureStorage.writeSecureData('clientSecret', clientSecret);
      var jsonResponse = convert.jsonDecode(response.body) as Map<String, dynamic>;
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Request failed with code: ${response.statusCode}'
                '$clientID'),
          );
        },
      );
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              child: TextField(
                //controller: clientIdController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Client ID',
                    hintText: 'Enter your client ID'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              child: TextField(
                //controller: clientSecretController,
                obscureText: false,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Client Secret',
                    hintText: 'Enter Client Secret'),
              ),
            ),
            isLoading ? const CircularProgressIndicator(
              semanticsLabel: 'Linear progress indicator',
            ) : Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () => _loginPressed('a38f22a8e6854b0f83dbfa45047b0a89', '4ee03c36e29a43d788e57980ab35c743'),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}