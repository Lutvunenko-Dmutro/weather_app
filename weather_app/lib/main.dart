import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

// Замініть цю змінну на ваш API-ключ
const String apiKey = '2cb4d4edd671231364e6d681c8465a4c';

class WeatherWidget extends StatefulWidget {
  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  List<String> cities = ["Київ", "Львів", "Одеса", "Харків"];
  List<String> allUkrainianCities = [];
  Map<String, Map<String, dynamic>> citiesWeather = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadCities();
  }

  Future<void> loadCities() async {
    try {
      final String response =
          await rootBundle.loadString('assets/ukrainian_cities.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        allUkrainianCities = data.cast<String>();
      });
      await fetchWeatherForAllCities();
    } catch (e) {
      setState(() {
        errorMessage = 'Помилка при завантаженні списку міст: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchWeather(String city) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=uk');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double temp = data['main']['temp'];
        int roundedTemperature = temp.round(); // Округлення температури
        setState(() {
          citiesWeather[city] = {
            "temperature": "$roundedTemperature°C",
            "condition": data['weather'][0]['description'],
            "iconUrl":
                "http://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png",
          };
        });
      } else {
        setState(() {
          citiesWeather[city] = {
            "temperature": "N/A",
            "condition": "Не вдалося отримати дані",
            "iconUrl": "",
          };
        });
      }
    } catch (e) {
      setState(() {
        citiesWeather[city] = {
          "temperature": "N/A",
          "condition": "Помилка: $e",
          "iconUrl": "",
        };
      });
    }
  }

  Future<void> fetchWeatherForAllCities() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await Future.wait(cities.map((city) => fetchWeather(city)));
    } catch (e) {
      setState(() {
        errorMessage = 'Помилка при завантаженні даних: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addCity(String city) async {
    if (cities.contains(city)) {
      setState(() {
        errorMessage = 'Місто "$city" вже додано.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    await fetchWeather(city);

    if (citiesWeather[city]!['temperature'] != "N/A") {
      setState(() {
        cities.add(city);
      });
    } else {
      setState(() {
        citiesWeather.remove(city);
        errorMessage =
            'Не вдалося знайти місто "$city". Будь ласка, спробуйте інше.';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget buildWeatherTab(String city) {
    final weather = citiesWeather[city];

    if (weather == null) {
      return Center(child: Text('Завантаження...'));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          weather['iconUrl'] != ""
              ? Image.network(
                  weather['iconUrl'],
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error, size: 100, color: Colors.red);
                  },
                )
              : Icon(Icons.error, size: 100, color: Colors.red),
          SizedBox(height: 20),
          Text(
            weather['temperature'],
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            weather['condition'],
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  void showAddCityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddCityDialog(onCitySelected: addCity, allCities: allUkrainianCities);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: cities.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Погода в містах України'),
          bottom: TabBar(
            isScrollable: true,
            tabs: cities.map((city) => Tab(text: city)).toList(),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: showAddCityDialog,
              tooltip: "Додати місто",
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : TabBarView(
                    children:
                        cities.map((city) => buildWeatherTab(city)).toList(),
                  ),
      ),
    );
  }
}

class AddCityDialog extends StatefulWidget {
  final Function(String) onCitySelected;
  final List<String> allCities;

  AddCityDialog({required this.onCitySelected, required this.allCities});

  @override
  _AddCityDialogState createState() => _AddCityDialogState();
}

class _AddCityDialogState extends State<AddCityDialog> {
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];
  bool isLoading = false;
  String error = '';

  void fetchCitySuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        suggestions = [];
      });
      return;
    }

    setState(() {
      suggestions = widget.allCities
          .where((city) =>
              city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void onSubmit(String value) {
    if (value.isNotEmpty) {
      widget.onCitySelected(value);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Додати місто"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Введіть назву міста",
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          suggestions = [];
                          error = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              fetchCitySuggestions(value);
            },
            onSubmitted: onSubmit,
          ),
          SizedBox(height: 10),
          if (suggestions.isNotEmpty)
            Container(
              height: 200,
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestions[index]),
                    onTap: () {
                      onSubmit(suggestions[index]);
                    },
                  );
                },
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Скасувати"),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WeatherWidget(),
    debugShowCheckedModeBanner: false,
  ));
}
