import 'package:flutter/material.dart';

/// Responsive utility — call [Responsive.init(context)] once at the top of
/// each build method (or pass [context] directly to the static helpers).
class Responsive {
  static late double _width;
  static late double _height;
  static late double _pixelRatio;
  static late EdgeInsets _padding;

  /// Call once per build to capture current screen metrics.
  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    _width = mq.size.width;
    _height = mq.size.height;
    _pixelRatio = mq.devicePixelRatio;
    _padding = mq.padding;
  }

  // ── Screen dimensions ────────────────────────────────────
  static double get width => _width;
  static double get height => _height;
  static double get pixelRatio => _pixelRatio;
  static EdgeInsets get safePadding => _padding;

  // ── Breakpoints ──────────────────────────────────────────
  /// < 360 dp  — very small phones (e.g. Galaxy A01)
  static bool get isXSmall => _width < 360;

  /// 360–414 dp — typical compact phones
  static bool get isSmall => _width >= 360 && _width < 415;

  /// 415–480 dp — large phones / phablets
  static bool get isMedium => _width >= 415 && _width < 481;

  /// > 480 dp  — tablets / foldables
  static bool get isLarge => _width >= 481;

  // ── Adaptive spacing ─────────────────────────────────────
  /// Horizontal screen padding that scales with width.
  static double get hPad {
    if (isXSmall) return 12;
    if (isSmall) return 16;
    if (isMedium) return 20;
    return 24;
  }

  /// Vertical padding for section gaps.
  static double get vGap {
    if (isXSmall) return 10;
    if (isSmall) return 12;
    return 16;
  }

  // ── Adaptive font sizes ──────────────────────────────────
  /// Large display / hero text
  static double get fontHero {
    if (isXSmall) return 22;
    if (isSmall) return 26;
    if (isMedium) return 30;
    return 34;
  }

  /// Section / card title
  static double get fontTitle {
    if (isXSmall) return 14;
    if (isSmall) return 16;
    return 18;
  }

  /// Body / label text
  static double get fontBody {
    if (isXSmall) return 11;
    if (isSmall) return 12;
    return 13;
  }

  /// Small caption / hint text
  static double get fontCaption {
    if (isXSmall) return 9;
    if (isSmall) return 10;
    return 11;
  }

  // ── Adaptive icon / avatar sizes ─────────────────────────
  static double get iconMd {
    if (isXSmall) return 18;
    if (isSmall) return 20;
    return 22;
  }

  static double get avatarSm {
    if (isXSmall) return 36;
    if (isSmall) return 40;
    return 46;
  }

  static double get avatarMd {
    if (isXSmall) return 44;
    if (isSmall) return 48;
    return 54;
  }

  // ── Border radii ─────────────────────────────────────────
  static double get radiusSm => isXSmall ? 10 : 12;
  static double get radiusMd => isXSmall ? 14 : 16;
  static double get radiusLg => isXSmall ? 18 : 20;
  static double get radiusXl => isXSmall ? 20 : 24;

  // ── Card internal padding ────────────────────────────────
  static EdgeInsets get cardPad => EdgeInsets.all(isXSmall ? 12 : 16);
  static EdgeInsets get sectionPad =>
      EdgeInsets.symmetric(horizontal: hPad, vertical: vGap);

  // ── Header top padding (status bar aware) ───────────────
  static double headerTop(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return top + (isXSmall ? 8 : 12);
  }

  // ── Bottom nav bar height ────────────────────────────────
  static double bottomNavHeight(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return (isXSmall ? 56 : 64) + bottom;
  }

  // ── Grid helpers ─────────────────────────────────────────
  /// Aspect ratio for the quick-stat grid cards.
  static double get statCardAspect {
    if (isXSmall) return 1.2;
    if (isSmall) return 1.35;
    return 1.5;
  }

  /// Aspect ratio for the module grid cards.
  static double get moduleCardAspect {
    if (isXSmall) return 0.95;
    if (isSmall) return 1.0;
    return 1.1;
  }

  // ── FAB bottom offset ────────────────────────────────────
  static double fabBottom(BuildContext context) {
    return bottomNavHeight(context) + (isXSmall ? 8 : 12);
  }

  // ── Chart sizes ──────────────────────────────────────────
  static double get chartHeight {
    if (isXSmall) return 160;
    if (isSmall) return 180;
    return 200;
  }
}