import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class CTheme {
  final String name;
  final CColors colors;

  CTheme({required this.name, required this.colors});

  factory CTheme.fromJson(Map<String, dynamic> json) => _$CThemeFromJson(json);
  Map<String, dynamic> toJson() => _$CThemeToJson(this);
}

@JsonSerializable()
class CColors {
  @JsonKey(name: '--color-long-round')
  final String colorLongRound;

  @JsonKey(name: '--color-short-round')
  final String colorShortRound;

  @JsonKey(name: '--color-focus-round')
  final String colorFocusRound;

  @JsonKey(name: '--color-background')
  final String colorBackground;

  @JsonKey(name: '--color-background-light')
  final String colorBackgroundLight;

  @JsonKey(name: '--color-background-lightest')
  final String colorBackgroundLightest;

  @JsonKey(name: '--color-foreground')
  final String colorForeground;

  @JsonKey(name: '--color-foreground-darker')
  final String colorForegroundDarker;

  @JsonKey(name: '--color-foreground-darkest')
  final String colorForegroundDarkest;

  @JsonKey(name: '--color-accent')
  final String colorAccent;

  CColors({
    required this.colorLongRound,
    required this.colorShortRound,
    required this.colorFocusRound,
    required this.colorBackground,
    required this.colorBackgroundLight,
    required this.colorBackgroundLightest,
    required this.colorForeground,
    required this.colorForegroundDarker,
    required this.colorForegroundDarkest,
    required this.colorAccent,
  });

  factory CColors.fromJson(Map<String, dynamic> json) => _$CColorsFromJson(json);
  Map<String, dynamic> toJson() => _$CColorsToJson(this);
}

Future<CTheme> getThemeByName(String themeName) async {
  var jsonString = await rootBundle.loadString("assets/themes/$themeName.json");
  return CTheme.fromJson(jsonDecode(jsonString));
}