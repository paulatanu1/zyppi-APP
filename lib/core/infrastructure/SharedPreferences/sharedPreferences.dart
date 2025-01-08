import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String authToken = 'AUTH_TOKEN';
  static const String googleToken = 'GOOGLE_TOKEN';


  Future<void> setString({String? key, String? value}) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setString(key ?? '', value ?? '');
  }

  Future<void> getString({String? key}) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    
    sharedPreferences.getString(key ?? '');
  }
}
