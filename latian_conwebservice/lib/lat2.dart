import 'package:flutter/material.dart'; //untuk mengimport package flutter
import 'package:http/http.dart' as http; //untuk mengimport package http, memungkinkan aplikasi Flutter melakukan permintaan HTTP ke server
import 'dart:convert'; // untuk mengurai dan mengonversi data dari dan ke format JSON dalam Flutter

import 'package:flutter_bloc/flutter_bloc.dart'; //digunakan untuk mengimpor library Flutter Bloc ke dalam proyek Flutter

// Definisikan model University untuk mewakili data universitas
class University {
  String name; // Nama universitas
  String website; // Situs web universitas

  University({required this.name, required this.website}); // Constructor

  // Factory method untuk membuat objek University dari JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University( //untuk mengembalikan objek University yang baru dibuat 
      name: json['name'], // Ambil nama universitas dari JSON
      website: json['web_pages'][0], // Ambil situs web pertama dari array dalam JSON
    );
  }
}

// Definisikan model UniversitiesList untuk menyimpan daftar universitas
class UniversitiesList {
  List<University> universities; // List universitas

  // Constructor untuk membuat objek UniversitiesList dari JSON
  UniversitiesList({required this.universities});

  // Factory method untuk membuat objek UniversitiesList dari JSON
  factory UniversitiesList.fromJson(List<dynamic> json) {
    // Map setiap item dalam JSON menjadi objek University dan tambahkan ke dalam list universities
    List<University> universities = json.map((university) => University.fromJson(university)).toList();
    return UniversitiesList(universities: universities); //mengembalikan objek UniversitiesList
  }
}


// Cubit untuk mengelola state aplikasi
class UniversityCubit extends Cubit<UniversitiesList> {
  UniversityCubit() : super(UniversitiesList(universities: [])); /*Pernyataan ini digunakan untuk menginisialisasi state awal Cubit. Dalam kasus ini, 
                                                                state awal adalah objek UniversitiesList dengan daftar universitas yang kosong. */

  // Method untuk mengambil data universitas dari URL berdasarkan negara
  Future<void> fetchUniversities(String country) async { //mendeklarasikan metode fetchUniversities yang mengambil negara sebagai parameter dan mengembalikan Future<void>
    final url = "http://universities.hipolabs.com/search?country=$country"; //membuat URL yang akan digunakan untuk mengambil data universitas dari server berdasarkan negara yang diberikan
    final response = await http.get(Uri.parse(url)); //package http untuk melakukan permintaan HTTP GET ke URL yang telah dibuat

    if (response.statusCode == 200) { //memeriksa status code dari respons HTTP
      emit(UniversitiesList.fromJson(jsonDecode(response.body))); //jika berhasil maka, menggunakan jsonDecode untuk mengonversi respons HTTP yang berupa string JSON menjadi objek Dart
    } else { //jika respon tidak berhasil
      throw Exception('Failed to load universities'); //pesan untuk menandakan bahwa ada kesalahan dalam mengambil data universitas
    }
  }
}

void main() { //deklarasi fungsi main
  runApp(MyApp()); // Jalankan aplikasi Flutter
}

class MyApp extends StatelessWidget { //Deklarasi kelas MyApp, yang merupakan turunan dari StatelessWidget
  @override
  Widget build(BuildContext context) { //Override dari metode build, yang akan membangun tampilan UI untuk MyApp.
    return MaterialApp( //Mengembalikan widget MaterialApp
      title: 'Universities in ASEAN', //Judul aplikasi
      home: BlocProvider( //Tempat utama untuk membuat dan mengakses Cubit dan menyediakan state ke seluruh aplikasi
        create: (context) => UniversityCubit(), //Membuat instance baru dari UniversityCubit dan menyediakannya ke dalam widget tree menggunakan BlocProvider
        child: UniversityPage(), //Menunjukkan widget anak UniversityPage, yang akan menjadi halaman utama aplikasi
      ),
    );
  }
}

class UniversityPage extends StatefulWidget { //Deklarasi kelas UniversityPage, yang merupakan turunan dari StatefulWidget
  @override
  _UniversityPageState createState() => _UniversityPageState(); //Bertanggung jawab untuk membuat dan mengembalikan state baru yang akan dihubungkan dengan UniversityPage
}

class _UniversityPageState extends State<UniversityPage> { //Deklarasi kelas _UniversityPageState, yang merupakan turunan dari State dan terkait dengan widget UniversityPage
  late UniversityCubit _universityCubit; //Deklarasi variabel _universityCubit yang bertipe UniversityCubit
  String _selectedCountry = 'Indonesia'; // Tambahkan variabel untuk menyimpan negara terpilih

  @override
  void initState() {
    super.initState(); //untuk memastikan bahwa logika yang didefinisikan dalam metode initState() kelas induk dijalankan sebelum logika yang didefinisikan di dalam metode initState() kelas ini
    _universityCubit = BlocProvider.of<UniversityCubit>(context); //untuk mendapatkan instance dari UniversityCubit dari widget tree
    _universityCubit.fetchUniversities("Indonesia"); // Mulai dengan negara Indonesia
  }

  @override
  Widget build(BuildContext context) { //deklarasi method build yang bertanggungjawab mmembangun UI widget UniversityPage
    return Scaffold( //Mengembalikan widget Scaffold
      appBar: AppBar( //Mengatur AppBar
        title: Text('Universities in ASEAN'), //Mengatur AppBar dengan judul 'Universities in ASEAN'.
      ),
      body: Column( //Mengatur body dari Scaffold sebagai Column
        children: [ //yang akan menempatkan child widgets secara vertikal.
          SizedBox(height: 20), //Menambahkan SizedBox dengan tinggi 20 piksel untuk memberi jarak antara AppBar dan DropdownButton
          BlocBuilder<UniversityCubit, UniversitiesList>( //Membuat BlocBuilder untuk membangun UI berdasarkan state dari UniversityCubit. Ini akan memperbarui UI setiap kali ada perubahan state.
            builder: (context, state) {
              // DropdownButton untuk memilih negara
              return DropdownButton<String>(
                value: _selectedCountry, // Gunakan nilai terpilih
                onChanged: (String? newValue) { //Mendefinisikan fungsi anonim yang akan dieksekusi ketika nilai dropdown berubah
                  if (newValue != null) { //Mengecek apakah nilai yang dipilih tidak null
                    setState(() { //memanggil setstate
                      _selectedCountry = newValue; // Perbarui nilai terpilih
                    });
                    _universityCubit.fetchUniversities(newValue); // Ambil data universitas berdasarkan negara yang dipilih
                  }
                },
                items: <String>[
                  //Menampilkan daftar negara-negara ASEAN sebagai opsi dalam DropdownButton
                  'Indonesia',
                  'Singapore',
                  'Malaysia',
                  'Thailand',
                  'Vietnam',
                  'Philippines',
                  'Cambodia',
                ].map<DropdownMenuItem<String>>((String value) { //mengubah setiap nilai dalam list string negara-negara ASEAN menjadi DropdownMenuItem<String>
                  return DropdownMenuItem<String>( //Setiap nilai dalam list diubah menjadi objek DropdownMenuItem<String>, yang merupakan item dropdown
                    value: value, //Nilai dari DropdownMenuItem diatur sebagai nilai string dari negara-negara ASEAN yang sesuai
                    child: Text(value), //Child dari DropdownMenuItem diatur sebagai Text
                  );
                }).toList(), 
              );
            },
          ),
          Expanded( //digunakan untuk mengisi ruang yang tersisa dalam parent widget
            child: BlocBuilder<UniversityCubit, UniversitiesList>( //mengambil dua argumen: tipe Cubit yang digunakan (UniversityCubit) dan tipe state (UniversitiesList).
              builder: (context, state) { //menerima dua argumen: context, yang menyediakan akses ke konteks lokal, dan state, yang merupakan state saat ini dari Cubit.
                // ListView untuk menampilkan daftar universitas
                if (state.universities.isEmpty) {
                  return Center( //mengembalikan ke center
                    child: CircularProgressIndicator(), //widget Center digunakan untuk mengatur CircularProgressIndicator
                  );
                } else { //menangani kasus ketika state.universities tidak kosong
                  return ListView.builder( //Mengembalikan sebuah ListView.builder
                    itemCount: state.universities.length, //Menentukan jumlah item dalam ListView berdasarkan panjang dari daftar state.universities
                    itemBuilder: (context, index) { //membangun tampilan untuk setiap item dalam daftar.
                      return Card( //mengembalikan card
                        elevation: 3, //menentukan tingkat bayangan
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), // menentukan margin
                        child: ListTile( //mengembalikan listTile
                          title: Text(state.universities[index].name), //menampilkan judul universitas pada listTile
                          subtitle: Text(state.universities[index].website), //menampilkan website universitas pada ListTile
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
