import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// sebaiknya di class terpisah
// menapung data hasil pemanggilan API
class CatFact {

  String fakta;
  int panjang;

  CatFact({required this.fakta, required this.panjang});

  //map dari json ke atribut
  factory CatFact.fromJson(Map<String, dynamic> json) {
    return CatFact(
      fakta: json['fact'],
      panjang: json['length'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

//class state
class MyAppState extends State<MyApp> {
  late Future<CatFact> futureCatFact;
  String url = "https://catfact.ninja/fact";


  //fetch data
  Future<CatFact> fetchData() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // jika server mengembalikan 200 OK (berhasil),
      // parse json
      return CatFact.fromJson(jsonDecode(response.body));
    } else {
      // jika gagal (bukan  200 OK),
      // lempar exception
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() {
    super.initState();
    futureCatFact = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'coba http',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('coba http'),
          ),
          body: Center(
            child: FutureBuilder<CatFact>(
              future: futureCatFact,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Text(snapshot.data!.fakta),
                        Text(snapshot.data!.panjang.toString())
                      ]));
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
          ),
        ));
  }
}