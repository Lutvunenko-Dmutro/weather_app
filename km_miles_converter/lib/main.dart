import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Конвертор одиниць',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Converter(
        isDarkMode: _isDarkMode,
        toggleTheme: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
      ),
    );
  }
}

class Converter extends StatefulWidget {
  final bool isDarkMode;
  final Function toggleTheme;

  Converter({required this.isDarkMode, required this.toggleTheme});

  @override
  _ConverterState createState() => _ConverterState();
}

class ConversionHistory {
  final String conversionType;
  final double inputValue;
  final double outputValue;

  ConversionHistory(this.conversionType, this.inputValue, this.outputValue);
}

class _ConverterState extends State<Converter> with SingleTickerProviderStateMixin {
  final Map<String, double> _conversionFactors = {
    'Кілометри в Мілі': 0.621371,
    'Мілі в Кілометри': 1 / 0.621371,
    'Дюйми в Сантиметри': 2.54,
    'Сантиметри в Дюйми': 1 / 2.54,
    'Акри в Гектари': 0.404686,
    'Гектари в Акри': 1 / 0.404686,
    'Кілограми в Фунти': 2.20462,
    'Фунти в Кілограми': 1 / 2.20462,
    'Літри в Галони': 0.264172,
    'Галони в Літри': 1 / 0.264172,
  };

  String _selectedConversion = 'Кілометри в Мілі';
  String _input = '';
  String _output = '';
  AnimationController? _controller;
  Animation<double>? _animation;

  // Use AnimatedList for history
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<ConversionHistory> _history = [];

  void _addToHistory(String conversionType, double inputValue, double outputValue) {
    final historyItem = ConversionHistory(conversionType, inputValue, outputValue);
    _history.insert(0, historyItem); // Insert at the start of the list
    _listKey.currentState?.insertItem(0); // Animate the addition of the item
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    );
  }

  void _convert() {
    if (_input.isNotEmpty) {
      double value = double.parse(_input);
      setState(() {
        _output = (value * _conversionFactors[_selectedConversion]!).toStringAsFixed(2);
        _addToHistory(_selectedConversion, value, double.parse(_output)); // Save to history
        _controller?.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Конвертор одиниць',
                style: GoogleFonts.comingSoon(),
              ),
            ),
            IconButton(
              icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
              onPressed: () {
                widget.toggleTheme();
              },
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Оберіть тип конвертації:',
              style: GoogleFonts.montserratAlternates(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedConversion,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedConversion = newValue!;
                  _output = '';
                });
              },
              isExpanded: true,
              items: _conversionFactors.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.montserratAlternates()),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Введіть значення:',
              style: GoogleFonts.montserratAlternates(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Значення',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _input = value;
                });
              },
            ),
            SizedBox(height: 20),
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                CurvedAnimation(
                  parent: _controller!,
                  curve: Curves.easeInOut,
                ),
              ),
              child: ElevatedButton(
                onPressed: _convert,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: GoogleFonts.montserratAlternates(fontSize: 18),
                ),
                child: Text('Конвертувати'),
              ),
            ),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _animation!,
              child: _output.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Результат:',
                          style: GoogleFonts.montserratAlternates(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _controller!,
                              curve: Curves.easeOut,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              _output,
                              style: GoogleFonts.montserratAlternates(fontSize: 24),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ),
            SizedBox(height: 20),
            Text(
              'Історія конверсій:',
              style: GoogleFonts.montserratAlternates(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            AnimatedList(
              key: _listKey,
              shrinkWrap: true, // Use shrinkWrap to take only necessary space
              physics: NeverScrollableScrollPhysics(), // Disable scrolling
              initialItemCount: _history.length,
              itemBuilder: (context, index, animation) {
                final historyItem = _history[index];
                return _buildHistoryItem(historyItem, animation);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(ConversionHistory item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text('${item.inputValue} ${item.conversionType} = ${item.outputValue}', style: GoogleFonts.montserratAlternates()),
      ),
    );
  }
}
