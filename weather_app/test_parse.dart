import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lib/models/forecast_model.dart';

void main() async {
  final url = Uri.https('api.openweathermap.org', '/data/2.5/forecast', {
    'q': 'Одеса',
    'appid': '2cb4d4edd671231364e6d681c8465a4c',
    'units': 'metric',
    'lang': 'uk',
    'cnt': '40',
  });
  final response = await http.get(url);
  final data = json.decode(response.body);
  final List list = data['list'];
  try {
    final parsed = list.map((item) => ForecastItem.fromJson(item)).toList();
    print('Parsed ${parsed.length} items successfully.');
  } catch (e) {
    print('Parse error: $e');
  }
}
