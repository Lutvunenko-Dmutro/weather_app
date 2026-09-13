import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.https('api.openweathermap.org', '/geo/1.0/direct', {
    'q': 'київ',
    'limit': '5',
    'appid': '2cb4d4edd671231364e6d681c8465a4c',
  });
  final response = await HttpClient().getUrl(url).then((req) => req.close());
  final responseBody = await response.transform(utf8.decoder).join();
  final List data = json.decode(responseBody);
  
  for (var item in data) {
    var localNames = item['local_names'];
    String name = item['name'] as String;
    if (localNames is Map) {
      if (localNames.containsKey('uk')) {
        name = localNames['uk'].toString();
      }
    }
    print("API returned: ${item['name']}, Resolved: $name");
  }
}
