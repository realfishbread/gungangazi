// is_web.dart
import 'package:flutter/material.dart';

bool isWeb(BuildContext context) {
  return MediaQuery.of(context).size.width > 600;
}
