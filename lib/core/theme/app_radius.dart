import 'package:flutter/material.dart';

/// Centralized border radii tokens for consistent rounded corners.
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;

  static const Radius rXs = Radius.circular(xs);
  static const Radius rSm = Radius.circular(sm);
  static const Radius rMd = Radius.circular(md);
  static const Radius rLg = Radius.circular(lg);
  static const Radius rXl = Radius.circular(xl);
  static const Radius rXxl = Radius.circular(xxl);

  static const BorderRadius allXs = BorderRadius.all(rXs);
  static const BorderRadius allSm = BorderRadius.all(rSm);
  static const BorderRadius allMd = BorderRadius.all(rMd);
  static const BorderRadius allLg = BorderRadius.all(rLg);
  static const BorderRadius allXl = BorderRadius.all(rXl);
  static const BorderRadius allXxl = BorderRadius.all(rXxl);
  static const BorderRadius allFull = BorderRadius.all(Radius.circular(full));

  static const BorderRadius topLg = BorderRadius.vertical(top: rLg);
  static const BorderRadius topXl = BorderRadius.vertical(top: rXl);
  static const BorderRadius topXxl = BorderRadius.vertical(top: rXxl);
}
