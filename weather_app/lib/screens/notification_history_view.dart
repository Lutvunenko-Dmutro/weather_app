import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/preferences_service.dart';
import '../widgets/settings/settings_glass_card.dart';

class NotificationHistoryView extends StatefulWidget {
  final String currentLang;

  const NotificationHistoryView({super.key, required this.currentLang});

  @override
  State<NotificationHistoryView> createState() => _NotificationHistoryViewState();
}

class _NotificationHistoryViewState extends State<NotificationHistoryView> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _history = PreferencesService.loadNotificationHistory();
    });
  }

  String _formatTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final isToday = dt.day == DateTime.now().day && dt.month == DateTime.now().month;
    final timeStr = DateFormat('HH:mm').format(dt);
    if (isToday) {
      return widget.currentLang == 'uk' ? 'Сьогодні $timeStr' : 'Today $timeStr';
    }
    return DateFormat('dd.MM HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final tTitle = widget.currentLang == 'uk' ? 'Історія сповіщень' : 'Notification History';
    final tEmpty = widget.currentLang == 'uk' ? 'Тут поки порожньо 🌤️' : 'It is empty here 🌤️';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              tTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _history.isEmpty
                  ? Center(
                      child: Text(
                        tEmpty,
                        style: const TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _history.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return SettingsGlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Text(
                                  item['emoji'] ?? '☀️',
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['body'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatTime(item['time'] ?? 0),
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
