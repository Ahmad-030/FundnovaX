import 'package:flutter/material.dart';
import '../responsive.dart';
import '../theme/app_theme.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final List<Color> gradient;
  final String icon;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.gradient,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(Responsive.radiusLg),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(Responsive.isXSmall ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(icon,
                    style: TextStyle(
                        fontSize: Responsive.isXSmall ? 22 : 28)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: Responsive.fontCaption,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            SizedBox(height: Responsive.isXSmall ? 10 : 14),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.isXSmall ? 18 : 22,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: Responsive.fontCaption)),
          ],
        ),
      ),
    );
  }
}

class SummaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String icon;

  const SummaryStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isXSmall ? 8 : 12,
        vertical: Responsive.isXSmall ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(Responsive.radiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
            EdgeInsets.all(Responsive.isXSmall ? 5 : 6),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(
                    Responsive.radiusSm - 2)),
            child: Text(icon,
                style: TextStyle(
                    fontSize: Responsive.isXSmall ? 13 : 15)),
          ),
          SizedBox(height: Responsive.isXSmall ? 6 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                  fontSize: Responsive.isXSmall ? 15 : 17,
                  fontWeight: FontWeight.w800,
                  color: color),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
                fontSize: Responsive.fontCaption,
                color: isDark ? Colors.white54 : Colors.black45,
                fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Widget? trailing;

  const GradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final topPad = Responsive.headerTop(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          Responsive.hPad, topPad, Responsive.hPad, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trailing != null)
            Align(alignment: Alignment.topRight, child: trailing!),
          Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: Responsive.fontTitle + 8,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: Responsive.fontBody)),
        ],
      ),
    );
  }
}