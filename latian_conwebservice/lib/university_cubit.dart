import 'package:flutter_bloc/flutter_bloc.dart';

// Enum untuk daftar negara ASEAN
enum AseanCountry { Singapore, Malaysia, Indonesia, Thailand, Vietnam, Philippines, Myanmar, Cambodia }

// Cubit untuk mengelola negara ASEAN yang dipilih
class AseanCountryCubit extends Cubit<AseanCountry> {
  AseanCountryCubit() : super(AseanCountry.Indonesia); // Negara default adalah Indonesia

  // Method untuk mengubah negara yang dipilih
  void selectCountry(AseanCountry country) => emit(country);
}
