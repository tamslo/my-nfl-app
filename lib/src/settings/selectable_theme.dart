import 'package:flutter/material.dart';

class SelectableTheme {
  SelectableTheme({
    required this.mode,
    required this.displayString,
    required this.storageKey,
  });

  final ThemeMode mode;
  final String displayString;
  final String storageKey;

}