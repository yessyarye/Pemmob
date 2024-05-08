import 'package:flutter/material.dart'; //Impor paket material.dart dari Flutter
import 'package:http/http.dart' as http; // Import library http untuk melakukan HTTP requests
import 'dart:convert'; // Import library json untuk mengurai data JSON
import 'package:flutter_bloc/flutter_bloc.dart'; //Impor paket flutter_bloc yang digunakan untuk mengelola state aplikasi menggunakan BLoC 
import 'university_cubit.dart'; //Impor file university_cubit.dart yang berisi definisi dari AseanCountryCubit.

// Definisikan model University untuk mewakili data universitas
class University {
  String name; // Nama universitas
  String website; // Situs web universitas

  University({required this.name, required this.website}); // Constructor

  // Factory method untuk membuat objek University dari JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University( //mengembalikan university
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

void main() { //dijalnakan pertama kali saat aplikasi dimulai
  runApp(MyApp()); // Jalankan aplikasi Flutter
}

class MyApp extends StatefulWidget { //mendefinisikan myapp yang turunan dari statefullwidget
  @override
  State<StatefulWidget> createState() { //menginisialisasi state widget
    return MyAppState(); // Buat dan kembalikan state untuk MyApp
  }
}

class MyAppState extends State<MyApp> { //mendefinisikan kelas MyAppState yang merupakan turunan dari kelas State dengan parameter MyApp.
  late Future<UniversitiesList> futureUniversitiesList; //mendeklarasikan variabel futureUniversitiesList yang akan menyimpan hasil dari pemanggilan fetchData()
  late AseanCountryCubit countryCubit; // Mendeklarasikan variabel countryCubit yang akan digunakan untuk mengelola negara ASEAN

  String baseUrl = "http://universities.hipolabs.com/search?country="; // Base URL untuk data universitas

  @override
  void initState() { //digunakan untuk melakukan inisialisasi awal pada saat state pertama kali dibuat
    super.initState(); //memastikan bahwa logika inisialisasi dari superclass juga dieksekusi
    countryCubit = AseanCountryCubit(); // Inisialisasi Cubit negara ASEAN
    futureUniversitiesList = fetchData(countryCubit.state); // Mulai pengambilan data universitas dengan negara default
  }

  Future<UniversitiesList> fetchData(AseanCountry country) async { //deklarasi metode fetchData() yang mengambil sebuah parameter country dengan tipe data AseanCountry dan mengembalikan sebuah Future yang akan berisi objek UniversitiesList
    final response = await http.get(Uri.parse('$baseUrl${_getCountryName(country)}')); // membuat permintaan HTTP GET menggunakan paket http ke URL yang dibentuk dari baseUrl ditambah dengan nama negara yang dipilih yang diperoleh dari fungsi _getCountryName(country)

    if (response.statusCode == 200) { //mengecek apakah status code adalah 200 atau berhasil
      return UniversitiesList.fromJson(jsonDecode(response.body)); //return untuk mengurai respon json yg diterima
    } else { //jika status code tidak 200
      throw Exception('Failed to load universities'); //memberikan pesan pernyataan bahwa gagal
    }
  }

  // Method untuk mendapatkan nama negara berdasarkan enum
  String _getCountryName(AseanCountry country) {
    switch (country) { //Memulai blok switch yang akan mengevaluasi nilai dari parameter country
      case AseanCountry.Singapore: //Ketika nilai country adalah AseanCountry.Singapore
        return "Singapore"; //fungsi akan mengembalikan string "Singapore"
      case AseanCountry.Malaysia:
        return "Malaysia";
      case AseanCountry.Indonesia:
        return "Indonesia";
      case AseanCountry.Thailand:
        return "Thailand";
      case AseanCountry.Vietnam:
        return "Vietnam";
      case AseanCountry.Philippines:
        return "Philippines";
      case AseanCountry.Myanmar:
        return "Myanmar";
      case AseanCountry.Cambodia:
        return "Cambodia";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) { //membuat dan mengembalikan widget yang akan ditampilkan pada layar
    return BlocProvider( //menggunakan BlocProvider untuk menyediakan countryCubit ke dalam widget tree
      create: (context) => countryCubit, // Memberikan Cubit ke widget tree
      child: MaterialApp(  //menyediakan beberapa fitur dasar seperti routing, tema, dan lainnya.
        title: 'Universities in ASEAN', //judul aplikasi
        home: Scaffold( //menyediakan kerangka dasar untuk UI aplikasi
          appBar: AppBar( // appbar
            title: const Text('Universities in ASEAN'), //judul appbar
          ),
          body: Center( //memusatkan widget didalamnya ke tengah
            child: Column( //menempatkan widget secara vertikal
              children: [ //mulai dari atas ke bawah
                BlocBuilder<AseanCountryCubit, AseanCountry>( //membuat widget yang akan dibangun berdasarkan state dari AseanCountryCubit
                  builder: (context, state) { //akan dipanggil saat ada perubahan pasa AseanCountryCubit
                    return DropdownButton<AseanCountry>( //menampilkan dropDownButton yang berisii negara asean
                      value: state, //nilai yg dipilih saat ini adalah state
                      onChanged: (country) { //dipanggil ketika pengguna memilih negara di dropdown
                        countryCubit.selectCountry(country!); //memanggil method selectCOuntry
                        setState(() { //memanggil setState
                          futureUniversitiesList = fetchData(country); // Memperbarui data universitas saat negara dipilih
                        });
                      },
                      items: AseanCountry.values.map((country) { //mengatur properti items dari DropDownButton 
                        return DropdownMenuItem<AseanCountry>( //mengembalikan sebuah objek DropDownButton
                          value: country, //menetapkan nilai opsi menjadi nulai Country
                          child: Text(_getCountryName(country)), //mengatur tampilan teks opsi dropdown
                        );
                      }).toList(), //mengubah hasil pemetaan menjadi sebuah list
                    );
                  },
                ),
                Expanded( //membungkus futurebuilder
                  child: FutureBuilder<UniversitiesList>( //membangun widget berdasarkan hasil dari future yang diberikan
                    future: futureUniversitiesList, //,emetapkan future yang dimonitor FutureBuilder
                    builder: (context, snapshot) { //
                      if (snapshot.hasData) { //memeriksa apakah future sudah memiliki data yang diperoleh
                        return ListView.builder( //menggunakan ListView.builder untuk membangun daftar universitas secara dinamis
                          itemCount: snapshot.data!.universities.length, //menentukan jumlah item dalam daftar berdasarkan panjang dari daftar universitas yang diterima dari future
                          itemBuilder: (context, index) { //embangun tampilan untuk setiap item dalam daftar
                            return Card( //mengembalikan sebuah Card
                              elevation: 3, //menetapkan elevasi 
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5), //menetapkan margin
                              child: ListTile( //menggunakan listtile
                                title: Text(snapshot.data!.universities[index].name), //menetapkan nama universitas
                                subtitle: Text(snapshot.data!.universities[index].website), //menetapkan website universitas
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) { //menampilkan pesan eror
                        return Text('${snapshot.error}'); //menampilkan pesan error dalam bentuk teks
                      }
                      return CircularProgressIndicator(); //menampilkan indikator loading
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
