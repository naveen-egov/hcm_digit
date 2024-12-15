import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> postFetchUserInfo(
  String code,
  String clientId,
  String redirectUri,
  String grantType,
) async {
  const String baseUrl = "http://localhost:8888"; // Replace with your base URL
  const String fetchUserInfoEndPoint = "/fetchUserInfo"; // Replace with your endpoint

  final Uri endpoint = Uri.parse(baseUrl + fetchUserInfoEndPoint);

  final Map<String, String> request = {
    "code": code,
    "client_id": clientId,
    "redirect_uri": redirectUri,
    "grant_type": grantType,
  };

  try {
    final http.Response response = await http.post(
      endpoint,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(request),
    );

    if (response.statusCode == 200) {
      // Parse and return the response data
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          "Failed to fetch user info. Status code: ${response.statusCode}");
    }
  } catch (error) {
    throw Exception("Error during API call: $error");
  }
}

