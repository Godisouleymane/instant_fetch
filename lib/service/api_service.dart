import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = "https://social-download-all-in-one.p.rapidapi.com/v1/social/autolink";
  final String apiKey = "1db74e8cd7msh5725b08ba80e220p16cc83jsnc53a8d5b9daf";

  Future<String?> downloadVideo(String videoUrl) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-rapidapi-key': apiKey,
        'x-rapidapi-host': 'social-download-all-in-one.p.rapidapi.com',
      },
      body: jsonEncode({
        'url': videoUrl,
      }),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("API Response: $data");
      return data['url'];
    } else {
      print("API Error: ${response.statusCode}");
      throw Exception('Failed to download video');
    }
  }
}
