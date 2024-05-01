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
  String url = "http://127.0.0.1:8000/update_mhs_put/";

  Future<int> fetchData() async {
    //data disimpan di body
    String nim = "13594022";
    //nim tambahkan di url
    //pastikan http.put! bukan post
    final response = await http.put(Uri.parse(url + nim),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: """
      {
      "nim":"13594022",  
      "nama": "Ahmad Aulia2",
      "id_prov": "142",
      "angkatan": "2022",
      "tinggi_badan": 192} """);
    return response.statusCode; //sukses kalau 200
  }

  @override
  void initState() {
    super.initState();
    respPost = Future.value(0); //init
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Put MHS',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Put MHS'),
        ),
        body: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  respPost = fetchData();
                });
              },
              child: const Text('Klik untuk update data (PUT)'),
            ),
            Text("Hasil:"),
            FutureBuilder<int>(
                future: respPost,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data! == 200) {
                      return Text("Proses Update Berhasil!");
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