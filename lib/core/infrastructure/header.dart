import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/core/data/dataSource/keyNames.dart';

class Header {
  Map<String, dynamic> header() {
    return {'Accept-Language': 'en'};
  }

  // Future<Map<String, dynamic>> authenticatedHeader() async {
  //   final bearerToken = await SharedPreferences.getInstance();
  //   return {
  //     'Accept-Language': 'en',

  //     // 'Authorization': 'Bearer ${bearerToken.getString(KeyNames.token)}'
  //     'Authorization':
  //         'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTczODUxNzYwMCwiZXhwIjoxNzQxMTA5NjAwfQ.JEKa0ZCr4A9_HlGcpX9EjcAwm4HrZppr2V7rLlyQSsM'
  //   };
  // }

  Map<String, dynamic> authenticatedHeader() {
    // final bearerToken = await SharedPreferences.getInstance();
    return {
      'Accept-Language': 'en',

      // 'Authorization': 'Bearer ${bearerToken.getString(KeyNames.token)}'
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTczODUxNzYwMCwiZXhwIjoxNzQxMTA5NjAwfQ.JEKa0ZCr4A9_HlGcpX9EjcAwm4HrZppr2V7rLlyQSsM'
    };
  }
}
