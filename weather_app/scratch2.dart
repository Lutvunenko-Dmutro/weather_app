import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.https('api.openweathermap.org', '/geo/1.0/direct', {
    'q': 'Київ',
    'limit': '5',
    'appid': '2cb4d4edd671231364e6d681c8465a4c',
  });
  final response = await HttpClient().getUrl(url).then((req) => req.close());
  final responseBody = await response.transform(utf8.decoder).join();
  final List data = json.decode(responseBody);
  
  final results = data.map((item) {
    try {
      final localNames = item['local_names'] as Map<String, dynamic>?;
      String name = item['name'] as String;
      if (localNames != null) {
        if (localNames.containsKey('uk')) {
          name = localNames['uk'] as String;
        }
      }
      return name;
    } catch (e) {
      return "ERROR: $e";
    }
  }).toList();
  
  print("Results: $results");
}
