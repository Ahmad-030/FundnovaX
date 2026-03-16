import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  final String title;
  final String value;
  final String total;
  final double progress;
  final Color color;
  final String icon;
  final String? subtitle;

  const ProgressCard({
    super.key,
    required this.title,
    required this.value,
    required this.total,
    required this.progress,
    required this.color,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color)),
                  Text('/ $total', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: clampedProgress,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 1 ? Colors.red : color,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
          ],
        ],
      ),
    );
  }
}

class AnimatedProgressRing extends StatefulWidget {
  final double progress;
  final Color color;
  final double size;
  final String centerText;
  final String bottomLabel;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    required this.color,
    required this.size,
    required this.centerText,
    required this.bottomLabel,
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _animation = Tween<double>(begin: 0, end: widget.progress.clamp(0, 1)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 10,
                      backgroundColor: widget.color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '${(_animation.value * 100).toInt()}%',
                    style: TextStyle(fontSize: widget.size * 0.22, fontWeight: FontWeight.w800, color: widget.color),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(widget.centerText, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        Text(widget.bottomLabel, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
