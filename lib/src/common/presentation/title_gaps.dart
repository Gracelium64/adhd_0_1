import 'package:flutter/material.dart';

// Compute responsive gaps above/below SubTitle based on aspect ratio buckets.
// Buckets from user:
// - 1080x2408, 1080x2400, 1080x2340  => ~20:9 (≈2.17–2.23)
// - 828x1792                          => ~19.5:9 (≈2.16)
// - 750x1334                          => 16:9   (≈1.78)

bool _near(double value, double target, [double tol = 0.03]) =>
    (value - target).abs() <= tol;

double subtitleTopGap(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final ratio = size.height / size.width;
  if (_near(ratio, 2.23) || _near(ratio, 2.22) || _near(ratio, 2.17)) {
    // Tall 20:9 devices
    // // 16
    return 4;
  }
  if (_near(ratio, 2.16)) {
    // ~19.5:9
    return 2;
  }
  if (_near(ratio, 1.78)) {
    // 16:9
    return 0;
  }
  // Fallback
  return 2;
}

double subtitleBottomGap(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final ratio = size.height / size.width;
  if (_near(ratio, 2.23) || _near(ratio, 2.22) || _near(ratio, 2.17)) {
    // Tall 20:9 devices
    return 4;
  }
  if (_near(ratio, 2.16)) {
    // ~19.5:9
    return 6;
  }
  if (_near(ratio, 1.78)) {
    // 16:9
    return 0;
  }
  // Fallback
  return 4;
}
