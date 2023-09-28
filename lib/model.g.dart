// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CTheme _$CThemeFromJson(Map<String, dynamic> json) => CTheme(
      name: json['name'] as String,
      colors: CColors.fromJson(json['colors'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CThemeToJson(CTheme instance) => <String, dynamic>{
      'name': instance.name,
      'colors': instance.colors,
    };

CColors _$CColorsFromJson(Map<String, dynamic> json) => CColors(
      colorLongRound: json['--color-long-round'] as String,
      colorShortRound: json['--color-short-round'] as String,
      colorFocusRound: json['--color-focus-round'] as String,
      colorBackground: json['--color-background'] as String,
      colorBackgroundLight: json['--color-background-light'] as String,
      colorBackgroundLightest: json['--color-background-lightest'] as String,
      colorForeground: json['--color-foreground'] as String,
      colorForegroundDarker: json['--color-foreground-darker'] as String,
      colorForegroundDarkest: json['--color-foreground-darkest'] as String,
      colorAccent: json['--color-accent'] as String,
    );

Map<String, dynamic> _$CColorsToJson(CColors instance) => <String, dynamic>{
      '--color-long-round': instance.colorLongRound,
      '--color-short-round': instance.colorShortRound,
      '--color-focus-round': instance.colorFocusRound,
      '--color-background': instance.colorBackground,
      '--color-background-light': instance.colorBackgroundLight,
      '--color-background-lightest': instance.colorBackgroundLightest,
      '--color-foreground': instance.colorForeground,
      '--color-foreground-darker': instance.colorForegroundDarker,
      '--color-foreground-darkest': instance.colorForegroundDarkest,
      '--color-accent': instance.colorAccent,
    };
