import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import library http untuk melakukan HTTP requests
import 'dart:convert'; // Import library json untuk mengurai data JSON

// Definisikan model University untuk mewakili data universitas
class University {
  String name; // Nama universitas
  String website; // Situs web universitas

  University({required this.name, required this.website}); // Constructor

  // Factory method untuk membuat objek University dari JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], // Ambil nama universitas dari JSON
      website: json['web_pages'][0], // Ambil situs web pertama dari array dalam JSON
    );
  }
}

// Definisikan model UniversitiesList untuk menyimpan daftar universitas
class UniversitiesList {
  List<University> universities = []; // List universitas

  // Constructor untuk membuat objek UniversitiesList dari JSON
  UniversitiesList.fromJson(List<dynamic> json) {
    // Map setiap item dalam JSON menjadi objek University dan tambahkan ke dalam list universities
    universities = json.map((university) => University.fromJson(university)).toList();
  }
}

void main() {
  runApp(MyApp()); // Jalankan aplikasi Flutter
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState(); // Buat dan kembalikan state untuk MyApp
  }
}

class MyAppState extends State<MyApp> {
  late Future<UniversitiesList> futureUniversitiesList; // Future untuk menyimpan hasil pengambilan data universitas

  String url = "http://universities.hipolabs.com/search?country=Indonesia"; // URL endpoint untuk data universitas Indonesia

  // Method untuk mengambil data universitas dari URL
  Future<UniversitiesList> fetchData() async {
    final response = await http.get(Uri.parse(url)); // Lakukan HTTP GET request

    if (response.statusCode == 200) {
      // Jika respons berhasil (status code 200),
      return UniversitiesList.fromJson(jsonDecode(response.body)); // Parse respons JSON dan buat objek UniversitiesList
    } else {
      // Jika respons gagal,
      throw Exception('Failed to load universities'); // Lemparkan exception
    }
  }

  @override
  void initState() {
    super.initState();
    futureUniversitiesList = fetchData(); // Mulai pengambilan data universitas saat initState dipanggil
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universities in Indonesia', // Judul aplikasi
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Universities in Indonesia'), // Judul AppBar
        ),
        body: Center(
          child: FutureBuilder<UniversitiesList>(
            future: futureUniversitiesList, // Future yang akan dipantau
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Jika future telah selesai dan memiliki data,
                return ListView.builder(
                  itemCount: snapshot.data!.universities.length, // Jumlah item dalam ListView
                  itemBuilder: (context, index) {
                    return Card( // Widget Card untuk setiap item universitas
                      elevation: 3, // Tingkat elevasi bayangan
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Margin dari Card
                      child: ListTile( // Widget ListTile sebagai isi dari Card
                        title: Text(snapshot.data!.universities[index].name), // Judul universitas
                        subtitle: Text(snapshot.data!.universities[index].website), // Subjudul situs web universitas
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                // Jika terjadi error saat mengambil data,
                return Text('${snapshot.error}'); // Tampilkan pesan error
              }
              return CircularProgressIndicator(); // Tampilkan indikator loading saat future sedang berjalan
            },
          ),
        ),
      ),
    );
  }
}
