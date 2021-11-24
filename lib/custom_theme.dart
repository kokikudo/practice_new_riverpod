import 'package:flutter/material.dart';

///TODO Appからの返信を確認し来てればそっちを優先
///さまざまな色を定義し、enumに入れる
///providerの型をThemeModeからenumにかえる
enum ThemeModeList {
  system,
}

const system = ThemeMode.system;
const light = ThemeMode.light;
const dart = ThemeMode.dark;

final summer = ThemeData.from(
  colorScheme: const ColorScheme.light().copyWith(
    primary: const Color(0xff00BCD4),
    onPrimary: const Color(0xff4DD0E1),
    onSecondary: const Color(0xffFDD835),
  ),
  textTheme: const TextTheme(
    button: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
);

enum Flavor {
  development,
  staging,
  production,
}
