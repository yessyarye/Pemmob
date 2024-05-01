import 'dart:convert';

void main() {
  // String JSON yang mewakili transkrip mahasiswa
  String jsonTranscript = '''
    {
      "mahasiswa": "Yessy Arye",
      "npm": "22082010087",
      "mata_kuliah": [
        {
          "kode": "MK1101",
          "nama": "Pengantar Sistem Informasi",
          "sks": 3,
          "nilai": "A-"
        },
        {
          "kode": "MK2202",
          "nama": "Matematika Komputasi ",
          "sks": 4,
          "nilai": "B"
        },
        {
          "kode": "MK3303",
          "nama": "RPL",
          "sks": 3,
          "nilai": "A"
        },
        {
          "kode": "MK4404",
          "nama": "IMK",
          "sks": 4,
          "nilai": "A"
        }
      ]
    }
  ''';

  // Parsing JSON ke dalam objek Dart
  Map<String, dynamic> transcript = jsonDecode(jsonTranscript);

  // Hitung IPK
  double ipk = calculateGPA(transcript);
  print('IPK Mahasiswa: $ipk');
}

// Fungsi untuk menghitung IPK berdasarkan transkrip mahasiswa
double calculateGPA(Map<String, dynamic> transcript) {
  List<dynamic> mataKuliah = transcript['mata_kuliah'];

  int totalSKS = 0;
  double totalBobot = 0;

  // Loop melalui setiap mata kuliah dalam transkrip
  for (var mk in mataKuliah) {
    int sks = mk['sks']; // Jumlah SKS mata kuliah
    String nilai = mk['nilai']; // Nilai yang diperoleh

    // Hitung bobot nilai
    double bobot = calculateGradePoint(nilai);

    // Total SKS dan total bobot diperoleh
    totalSKS += sks;
    totalBobot += (bobot * sks);
  }

  // Hitung IPK (Indeks Prestasi Kumulatif)
  double ipk = totalBobot / totalSKS;
  return ipk;
}

// Fungsi untuk menghitung bobot nilai
double calculateGradePoint(String grade) {
  switch (grade) {
    case 'A':
      return 4.0;
    case 'A-':
      return 3.7;
    case 'B+':
      return 3.3;
    case 'B':
      return 3.0;
    case 'B-':
      return 2.7;
    case 'C+':
      return 2.3;
    case 'C':
      return 2.0;
    case 'C-':
      return 1.7;
    case 'D+':
      return 1.3;
    case 'D':
      return 1.0;
    case 'E':
      return 0.0;
    default:
      return 0.0; // Default jika nilai tidak valid
  }
}
