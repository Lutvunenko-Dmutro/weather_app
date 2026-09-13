import 'package:flutter/material.dart';
import 'dart:async';
import '../services/weather_service.dart';

class AddCityDialog extends StatefulWidget {
  final Function(String) onCitySelected;
  final String lang;

  const AddCityDialog({
    super.key,
    required this.onCitySelected,
    this.lang = 'uk',
  });

  @override
  State<AddCityDialog> createState() => _AddCityDialogState();
}

class _AddCityDialogState extends State<AddCityDialog> {
  final TextEditingController _controller = TextEditingController();
  final WeatherService _service = WeatherService();
  List<String> suggestions = [];
  Timer? _debounce;
  bool _isLoading = false;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      if (mounted) setState(() { suggestions = []; _isLoading = false; });
      return;
    }
    if (mounted) setState(() => _isLoading = true);
    final results = await _service.fetchCitySuggestions(query, lang: widget.lang);
    if (mounted) {
      setState(() {
        suggestions = results;
        _isLoading = false;
      });
    }
  }

  void _onSubmit(String value) {
    if (value.isNotEmpty) {
      // Split by comma to just take the city name if the user clicked a suggestion
      final cityName = value.split(',')[0].trim();
      widget.onCitySelected(cityName);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      title: Text(
        widget.lang == 'uk' ? 'Додати місто' : 'Add City',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: widget.lang == 'uk' ? 'Введіть назву міста (натисніть Enter)' : 'Enter city name (press Enter)',
              hintStyle: const TextStyle(color: Colors.white30),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _controller.clear();
                        setState(() => suggestions = []);
                      },
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
            onSubmitted: _onSubmit,
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 2)),
            ),
          if (!_isLoading && suggestions.isNotEmpty)
            SizedBox(
              height: 200,
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(
                    suggestions[index],
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () => _onSubmit(suggestions[index]),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            widget.lang == 'uk' ? 'Скасувати' : 'Cancel',
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }
}
