import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String currentLang;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.currentLang,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.calendar_today_rounded,
        label: currentLang == 'uk' ? 'Сьогодні' : 'Today',
      ),
      _NavItem(
        icon: Icons.notifications_none_rounded,
        label: currentLang == 'uk' ? 'Сповіщення' : 'Alerts',
      ),
      _NavItem(
        icon: Icons.settings_outlined,
        label: currentLang == 'uk' ? 'Налаштування' : 'Settings',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (index) {
              return Expanded(
                child: _NavButton(
                  item: items[index],
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(index);
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavButton extends StatefulWidget {
  final _NavItem item;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Плавний перехід кольору під час натискання
          final color = Color.lerp(
            Colors.white.withValues(alpha: 0.45),
            Colors.blueAccent,
            _controller.value,
          )!;

          return Transform.scale(
            scale: _scaleAnim.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: _glowAnim.value * 0.18),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _glowAnim.value > 0
                        ? [
                            BoxShadow(
                              color: Colors.blueAccent.withValues(alpha: _glowAnim.value * 0.25),
                              blurRadius: 12,
                              spreadRadius: 0,
                            )
                          ]
                        : [],
                  ),
                  child: Icon(
                    widget.item.icon,
                    size: 22,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.item.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
