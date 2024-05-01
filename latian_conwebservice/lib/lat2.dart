import 'package:flutter/material.dart'; // Import library Flutter untuk membangun antarmuka pengguna
import 'package:http/http.dart' as http; // Import library http untuk melakukan HTTP requests
import 'dart:convert'; // Import library json untuk mengurai data JSON

void main() {
  runApp(const MyApp()); // Untuk menjalankan aplikasi Flutter
}

// Kelas model untuk menyimpan data aktivitas dari API
class Activity {
  String aktivitas; // Variabel untuk menyimpan aktivitas
  String jenis; // Variabel untuk menyimpan jenis aktivitas

  Activity({required this.aktivitas, required this.jenis}); // Constructor

  // Factory method untuk membuat objek Activity dari JSON
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      aktivitas: json['activity'], // Ambil aktivitas dari JSON
      jenis: json['type'], // Ambil jenis aktivitas dari JSON
    );
  }
}

// Kelas utama MyApp
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyAppState(); // Buat dan kembalikan state untuk MyApp
  }
}

// State untuk MyApp
class MyAppState extends State<MyApp> {
  late Future<Activity> futureActivity; // Future untuk menyimpan hasil pemanggilan API

  // URL endpoint untuk mengambil data aktivitas dari API
  String url = "https://www.boredapi.com/api/activity";

  // Method untuk menginisialisasi futureActivity
  Future<Activity> init() async {
    return Activity(aktivitas: "", jenis: ""); // Kembalikan objek Activity kosong
  }

  // Method untuk melakukan pemanggilan API dan mendapatkan data aktivitas
  Future<Activity> fetchData() async {
    final response = await http.get(Uri.parse(url)); // Lakukan HTTP GET request

    if (response.statusCode == 200) {
      // Jika respons berhasil (status code 200),
      // parse json dan buat objek Activity
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      // Jika gagal (bukan 200 OK),
      // lempar exception
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() {
    super.initState();
    futureActivity = init(); // Inisialisasi futureActivity saat initState dipanggil
  }

  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  futureActivity = fetchData(); // Ketika tombol ditekan, panggil fetchData untuk mendapatkan aktivitas baru
                });
              },
              child: Text("Saya bosan ..."),
            ),
          ),
          FutureBuilder<Activity>(
            future: futureActivity, // Future yang akan dipantau
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Jika future telah selesai dan memiliki data,
                // tampilkan aktivitas dan jenisnya
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(snapshot.data!.aktivitas), // Tampilkan aktivitas
                      Text("Jenis: ${snapshot.data!.jenis}") // Tampilkan jenis aktivitas
                    ]));
              } else if (snapshot.hasError) {
                // Jika terjadi error saat mengambil data,
                // tampilkan pesan error
                return Text('${snapshot.error}');
              }
              // Default: tampilkan indikator loading
              return const CircularProgressIndicator();
            },
          ),
        ]),
      ),
    ));
  }
}
