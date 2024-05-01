import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Future<int> respPost; //201 artinya berhasil
  String url = "http://127.0.0.1:8000/tambah_mhs/";

  Future<int> insertData() async {
    //data disimpan di body
    final response = await http.post(Uri.parse(url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    }, body: """
      {"nim": "13594022",
      "nama": "Sandra Permana",
      "id_prov": "12",
      "angkatan": "2020",
      "tinggi_badan": 190} """);
    return response.statusCode; //sukses kalau 201
  }

  @override
  void initState() {
    super.initState();
    respPost = Future.value(0); //init
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post MHS',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Post MHS'),
        ),
        body: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  respPost = insertData();
                });
              },
              child: const Text('Klik Untuk Insert data (POST)'),
            ),
            Text("Hasil:"),
            FutureBuilder<int>(
                future: respPost,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data! == 201) {
                      return Text("Proses Insert Berhasil!");
                    }
                    if (snapshot.data! == 0) {
                      return Text("");
                    } else {
                      return Text("Proses insert gagal");
                    }
                  }
                  // default: loading spinner.
                  return const CircularProgressIndicator();
                })
          ],
        )), //column center
      ), //Scaffold
    ); //Material APP
  }
}