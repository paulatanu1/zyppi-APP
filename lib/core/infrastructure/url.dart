class Url {
  static const version = 'v1';

  static const baseUrl = 'http://13.233.47.211:2015/api/$version/';

  //Google Sign-In
  static const googleSignIn = '${baseUrl}user/google/login';

  //Login
  static const login = '${baseUrl}user/login';

  //Google API
  static const googleApi = 'https://maps.googleapis.com/maps/api';

  //Add Address
  static const addAddress = '${baseUrl}user-addesss';
}
