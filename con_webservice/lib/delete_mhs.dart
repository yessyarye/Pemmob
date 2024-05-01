import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late Future<int> respPost; 
  String url = "http://127.0.0.1:8000/delete_mhs/";

  Future<int> fetchData() async {
    //data disimpan di body
    String nim = "13594022";
    //nim tambahkan di url
    //pastikan http.delete
    final response = await http.delete(Uri.parse(url + nim)); //hanya ganti nama saja
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
      title: 'Delete MHS',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Delete'),
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
              child: const Text('Klik untuk delete data'),
            ),
            Text("Hasil:"),
            FutureBuilder<int>(
                future: respPost,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data! == 200) {
                      return Text("Proses delete berhasil!");
                    }
                    if (snapshot.data! == 0) {
                      return Text("");
                    } else {
                      return Text("Proses delete gagal");
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