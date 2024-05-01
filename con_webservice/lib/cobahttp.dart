import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/*
   
   {"data":[{"ID Nation":"01000US","Nation":"United States",
   "ID Year":2019,"Year":"2019","Population":328239523,"Slug Nation":"united-states"},
   {"ID Nation":"01000US","Nation":"United States","ID Year":2018,"Year":"2018","Population":327167439,
   "Slug Nation":"united-states"},{"ID Nation":"01000US","Nation":"United States","ID 
   …. 
    Year":2014,"Year":"2014","Population":318857056,"Slug Nation":"united-states"},
    {"ID Nation":"01000US","Nation":"United States","ID Year":2013,"Year":"2013",
    "Population":316128839,"Slug Nation":"united-states"}],
    "source":
    [{"measures":["Population"],"annotations":
    { ... },"name":"acs_yg_total_population_1","substitutions":[]}]}

*/

class PopulasiTahun {
  int tahun;
  int populasi;
  PopulasiTahun({required this.tahun, required this.populasi});
}

class Populasi {
  List<PopulasiTahun> ListPop = <PopulasiTahun>[];

  Populasi(Map<String, dynamic> json) {
    // isi listPop disini
    var data = json["data"];
    for (var val in data) {
      var tahun = int.parse(val["Year"]); //thn dijadikan int
      var populasi = val["Population"]; //pouliasi sudah int
      ListPop.add(PopulasiTahun(tahun: tahun, populasi: populasi));
    }
  }
  //map dari json ke atribut
  factory Populasi.fromJson(Map<String, dynamic> json) {
    return Populasi(json);
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
  late Future<Populasi> futurePopulasi;

  //https://datausa.io/api/data?drilldowns=Nation&measures=Population
  String url =
      "https://datausa.io/api/data?drilldowns=Nation&measures=Population";

  //fetch data
  Future<Populasi> fetchData() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // jika server mengembalikan 200 OK (berhasil),
      // parse json
      return Populasi.fromJson(jsonDecode(response.body));
    } else {
      // jika gagal (bukan  200 OK),
      // lempar exception
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() {
    super.initState();
    futurePopulasi = fetchData();
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
            child: FutureBuilder<Populasi>(
              future: futurePopulasi,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Center(
                    //gunakan listview builder
                    child: ListView.builder(
                      itemCount: snapshot
                          .data!.ListPop.length, //asumsikan data ada isi
                      itemBuilder: (context, index) {
                        return Container(
                            decoration: BoxDecoration(border: Border.all()),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(snapshot.data!.ListPop[index].tahun
                                      .toString()),
                                  Text(snapshot.data!.ListPop[index].populasi
                                      .toString()),
                                ]));
                      },
                    ),
                  );
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