import 'package:flutter/material.dart';

/// Consistent spacing and sizing constants for WaveMart
abstract class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double xxxl = 24;
  static const double xxxxl = 32;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);

  // Border radii matching web's rounded-sm (4px) as the base
  static const double borderRadiusXs = 2;
  static const double borderRadiusSm = 4;
  static const double borderRadiusMd = 8;
  static const double borderRadiusLg = 12;
  static const double borderRadiusXl = 16;
  static const double borderRadiusXxl = 20;

  static const BorderRadius borderRadiusAllXs = BorderRadius.all(Radius.circular(borderRadiusXs));
  static const BorderRadius borderRadiusAllSm = BorderRadius.all(Radius.circular(borderRadiusSm));
  static const BorderRadius borderRadiusAllMd = BorderRadius.all(Radius.circular(borderRadiusMd));
  static const BorderRadius borderRadiusAllLg = BorderRadius.all(Radius.circular(borderRadiusLg));
  static const BorderRadius borderRadiusAllXl = BorderRadius.all(Radius.circular(borderRadiusXl));
  static const BorderRadius borderRadiusAllXxl = BorderRadius.all(Radius.circular(borderRadiusXxl));

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  static const double buttonHeightSm = 40;
  static const double buttonHeightMd = 48;
  static const double buttonHeightLg = 56;

  static const double cardElevation = 2;
  static const double dialogElevation = 8;
}
