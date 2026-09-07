import 'package:flutter/material.dart';
import '../models/forecast_model.dart';

class ForecastWidget extends StatefulWidget {
  final List<ForecastItem> forecast;
  final bool isCelsius;
  final Color accent;

  const ForecastWidget({
    super.key,
    required this.forecast,
    required this.isCelsius,
    required this.accent,
  });

  @override
  State<ForecastWidget> createState() => _ForecastWidgetState();
}

class _ForecastWidgetState extends State<ForecastWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ПРОГНОЗ',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 11,
            letterSpacing: 4,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SizedBox(
            height: 118,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.forecast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = widget.forecast[index];
                return Container(
                  width: 66,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        item.date,
                        style: const TextStyle(color: Color(0x33FFFFFF), fontSize: 9),
                      ),
                      Text(
                        item.time,
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      Image.network(
                        item.iconUrl,
                        width: 30,
                        height: 30,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.cloud,
                          color: widget.accent.withValues(alpha: 0.5),
                          size: 26,
                        ),
                      ),
                      Text(
                        item.displayTemp(widget.isCelsius),
                        style: TextStyle(
                          color: widget.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
