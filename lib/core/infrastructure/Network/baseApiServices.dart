abstract class BaseApiServices {
  Future<dynamic> getApiRequest({required String url});
  Future<dynamic> postApiRequest({required String url, required Map<String, dynamic> payload});
}