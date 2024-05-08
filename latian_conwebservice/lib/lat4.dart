import 'package:flutter/material.dart'; // Import package flutter untuk menggunakan fungsi dan widget dari Flutter
import 'package:http/http.dart' as http; // Import package http untuk melakukan HTTP requests dengan alias http
import 'dart:convert'; // Import package dart:convert untuk mengurai data JSON
import 'package:provider/provider.dart'; // Import package provider untuk manajemen state dengan Provider
import 'package:url_launcher/url_launcher.dart'; // Import package url_launcher untuk membuka URL

// Definisikan model University untuk mewakili data universitas
class University {
  String name; // Variabel untuk menyimpan nama universitas
  String website; // Variabel untuk menyimpan situs web universitas

  University({required this.name, required this.website}); // Konstruktor untuk menginisialisasi variabel

  factory University.fromJson(Map<String, dynamic> json) {
    // Factory method untuk membuat objek University dari data JSON
    return University(
      name: json['name'], // Mengambil nama universitas dari JSON
      website: json['web_pages'][0], // Mengambil situs web pertama dari array dalam JSON
    );
  }
}


// Definisikan model UniversitiesList untuk menyimpan daftar universitas
class UniversitiesList {
  List<University> universities = []; // Inisialisasi daftar universitas sebagai array kosong

  UniversitiesList.fromJson(List<dynamic> json) { // Constructor untuk membuat objek UniversitiesList dari JSON
    universities = json.map((university) => University.fromJson(university)).toList(); // Mengisi daftar universitas dari data JSON yang diterima
  }
}

// Model untuk menyimpan state negara ASEAN yang dipilih
class SelectedCountry extends ChangeNotifier { // Deklarasi kelas SelectedCountry sebagai turunan dari ChangeNotifier
  late String _country; // Deklarasi variabel instance _country yang akan menyimpan negara terpilih
  String get country => _country; // Getter untuk mendapatkan nilai _country

  void setCountry(String country) { // Method untuk mengatur nilai _country
    _country = country; // Set nilai _country dengan nilai baru
    notifyListeners(); // Memberi tahu semua listener tentang perubahan state
  }
}

void main() {
  runApp(MyApp()); //jalankan aplikasi flutter
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedCountry()), //Menyediakan provider SelectedCountry ke dalam widget tree menggunakan ChangeNotifierProvider
      ],
      child: MaterialApp(
        title: 'Universities App', //judul aplikasi
        home: MyHomePage(), //halaman utama aplikasi
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Universities App'), // Judul AppBar
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Menyusun widget secara vertikal di tengah
          children: <Widget>[
            CountryDropdown(), // Tampilkan combobox untuk pilihan negara
            SizedBox(height: 20), // Berikan jarak vertikal sebesar 20
            UniversityList(), // Tampilkan daftar universitas
          ],
        ),
      ),
    );
  }
}


class CountryDropdown extends StatefulWidget {
  @override
  _CountryDropdownState createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  String _selectedCountry = 'Indonesia'; // Negara default

  @override
  Widget build(BuildContext context) {
    var selectedCountryProvider = Provider.of<SelectedCountry>(context, listen: false);
    // Membuat DropdownButton untuk memilih negara
    return DropdownButton<String>(
      value: _selectedCountry, // Menggunakan nilai negara yang dipilih
      onChanged: (String? newValue) {
        setState(() {
          _selectedCountry = newValue!; // Memperbarui negara yang dipilih saat nilai berubah
          selectedCountryProvider.setCountry(newValue); // Set negara yang dipilih ke dalam model SelectedCountry
        });
      },
      // Menampilkan daftar negara ASEAN sebagai item pada DropdownButton
      items: <String>['Indonesia', 'Singapore', 'Malaysia', 'Thailand', 'Cambodia']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}


class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var selectedCountryProvider = Provider.of<SelectedCountry>(context); // Mendapatkan instance dari SelectedCountry dari provider
    String selectedCountry = selectedCountryProvider.country; // Mendapatkan negara yang dipilih dari provider

    String url = "http://universities.hipolabs.com/search?country=$selectedCountry"; // Membuat URL berdasarkan negara yang dipilih

    return FutureBuilder<UniversitiesList>(
      future: fetchData(url), // Mendapatkan data universitas dari URL yang dihasilkan
      builder: (context, snapshot) { // Builder untuk mengatur tampilan berdasarkan status future
        if (snapshot.connectionState == ConnectionState.waiting) { // Jika future sedang loading
          return CircularProgressIndicator(); // Menampilkan indikator loading
        } else if (snapshot.hasError) { // Jika terjadi error
          return Text('${snapshot.error}'); // Menampilkan pesan error
        } else if (!snapshot.hasData || snapshot.data!.universities.isEmpty) { // Jika tidak ada data atau daftar universitas kosong
          return Text('No data found'); // Menampilkan pesan bahwa tidak ada data
        } else { // Jika data diterima dengan sukses
          return Expanded( // Menggunakan Expanded agar daftar universitas dapat memenuhi ruang yang tersedia
            child: ListView.builder( // Menggunakan ListView.builder untuk menampilkan daftar universitas
              itemCount: snapshot.data!.universities.length, // Jumlah item dalam daftar adalah panjang daftar universitas
              itemBuilder: (context, index) { // Builder untuk setiap item dalam daftar
                University university = snapshot.data!.universities[index]; // Ambil universitas pada indeks tertentu
                return Card( // Widget Card untuk menampilkan informasi universitas
                  elevation: 3, // Tingkat elevasi bayangan
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Margin dari Card
                  child: ListTile( // Widget ListTile sebagai isi dari Card
                    title: Text(university.name), // Menampilkan nama universitas
                    subtitle: GestureDetector( // Menggunakan GestureDetector untuk menangani ketika pengguna mengetuk URL
                      onTap: () {
                        launchURL(university.website); // Memanggil fungsi untuk membuka URL
                      },
                      child: Text( // Menampilkan URL situs web universitas
                        university.website,
                        style: TextStyle(
                          color: Colors.blue, // Warna teks biru
                          decoration: TextDecoration.underline, // Garis bawah untuk menandai teks sebagai tautan
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }


    Future<UniversitiesList> fetchData(String url) async { // Fungsi asinkron untuk mengambil data universitas dari URL
    final response = await http.get(Uri.parse(url)); // Mengirim permintaan HTTP GET ke URL yang diberikan
    if (response.statusCode == 200) { // Jika respons berhasil (status code 200)
      return UniversitiesList.fromJson(jsonDecode(response.body)); // Parse respons JSON dan buat objek UniversitiesList
    } else { // Jika terjadi kesalahan dalam mengambil data
      throw Exception('Failed to load universities'); // Lemparkan exception
    }
  }


 void launchURL(String url) async { // Deklarasi fungsi untuk membuka URL
    if (await canLaunch(url)) { // Memeriksa apakah URL dapat diluncurkan
      await launch(url); // Meluncurkan URL jika memungkinkan
    } else { // Jika tidak bisa diluncurkan
      throw 'Could not launch $url'; // Lemparkan pengecualian dengan pesan kesalahan
    }
  }
}