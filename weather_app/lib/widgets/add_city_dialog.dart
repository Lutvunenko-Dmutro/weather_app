import 'package:flutter/material.dart';

class AddCityDialog extends StatefulWidget {
  final Function(String) onCitySelected;
  final List<String> allCities;

  const AddCityDialog({
    super.key,
    required this.onCitySelected,
    required this.allCities,
  });

  @override
  State<AddCityDialog> createState() => _AddCityDialogState();
}

class _AddCityDialogState extends State<AddCityDialog> {
  final TextEditingController _controller = TextEditingController();
  List<String> suggestions = [];

  void _fetchSuggestions(String query) {
    setState(() {
      suggestions = query.isEmpty
          ? []
          : widget.allCities
              .where((city) =>
                  city.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  void _onSubmit(String value) {
    if (value.isNotEmpty) {
      widget.onCitySelected(value);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Додати місто'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Введіть назву міста',
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() => suggestions = []);
                      },
                    )
                  : null,
            ),
            onChanged: _fetchSuggestions,
            onSubmitted: _onSubmit,
          ),
          const SizedBox(height: 10),
          if (suggestions.isNotEmpty)
            SizedBox(
              height: 200,
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(suggestions[index]),
                  onTap: () => _onSubmit(suggestions[index]),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
      ],
    );
  }
}
