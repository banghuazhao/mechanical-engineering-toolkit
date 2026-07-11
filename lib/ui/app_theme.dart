import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.space1,
    required this.space2,
    required this.space3,
    required this.space4,
    required this.space5,
    required this.space6,
    required this.radiusSmall,
    required this.radiusMedium,
    required this.radiusLarge,
    required this.contentMaxWidth,
    required this.cardShadow,
  });

  static const standard = AppTokens(
    space1: 4,
    space2: 8,
    space3: 12,
    space4: 16,
    space5: 24,
    space6: 32,
    radiusSmall: 8,
    radiusMedium: 12,
    radiusLarge: 16,
    contentMaxWidth: 720,
    cardShadow: [
      BoxShadow(
        color: Color(0x12000000),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );

  final double space1;
  final double space2;
  final double space3;
  final double space4;
  final double space5;
  final double space6;
  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final double contentMaxWidth;
  final List<BoxShadow> cardShadow;

  @override
  AppTokens copyWith({
    double? space1,
    double? space2,
    double? space3,
    double? space4,
    double? space5,
    double? space6,
    double? radiusSmall,
    double? radiusMedium,
    double? radiusLarge,
    double? contentMaxWidth,
    List<BoxShadow>? cardShadow,
  }) {
    return AppTokens(
      space1: space1 ?? this.space1,
      space2: space2 ?? this.space2,
      space3: space3 ?? this.space3,
      space4: space4 ?? this.space4,
      space5: space5 ?? this.space5,
      space6: space6 ?? this.space6,
      radiusSmall: radiusSmall ?? this.radiusSmall,
      radiusMedium: radiusMedium ?? this.radiusMedium,
      radiusLarge: radiusLarge ?? this.radiusLarge,
      contentMaxWidth: contentMaxWidth ?? this.contentMaxWidth,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      space1: lerpDouble(space1, other.space1, t),
      space2: lerpDouble(space2, other.space2, t),
      space3: lerpDouble(space3, other.space3, t),
      space4: lerpDouble(space4, other.space4, t),
      space5: lerpDouble(space5, other.space5, t),
      space6: lerpDouble(space6, other.space6, t),
      radiusSmall: lerpDouble(radiusSmall, other.radiusSmall, t),
      radiusMedium: lerpDouble(radiusMedium, other.radiusMedium, t),
      radiusLarge: lerpDouble(radiusLarge, other.radiusLarge, t),
      contentMaxWidth: lerpDouble(contentMaxWidth, other.contentMaxWidth, t),
      cardShadow:
          BoxShadow.lerpList(cardShadow, other.cardShadow, t) ?? cardShadow,
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}

abstract final class AppTheme {
  static const _brand = Color(0xFF8B654B);
  static const _brandDark = Color(0xFFD7B79F);

  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _brand,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF5E5D9),
    onPrimaryContainer: Color(0xFF342116),
    secondary: Color(0xFF53665A),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD8E8DC),
    onSecondaryContainer: Color(0xFF14251A),
    tertiary: Color(0xFF526A83),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD6E4F4),
    onTertiaryContainer: Color(0xFF102638),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFFFBF8),
    onSurface: Color(0xFF211A17),
    onSurfaceVariant: Color(0xFF57443A),
    outline: Color(0xFF89736A),
    outlineVariant: Color(0xFFDDC2B5),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF372F2B),
    onInverseSurface: Color(0xFFFCEFE9),
    inversePrimary: _brandDark,
    surfaceTint: _brand,
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _brandDark,
    onPrimary: Color(0xFF4E2F1E),
    primaryContainer: Color(0xFF6A4832),
    onPrimaryContainer: Color(0xFFF5E5D9),
    secondary: Color(0xFFBCCCBD),
    onSecondary: Color(0xFF27352B),
    secondaryContainer: Color(0xFF3D4C40),
    onSecondaryContainer: Color(0xFFD8E8DC),
    tertiary: Color(0xFFBAC9DC),
    onTertiary: Color(0xFF243549),
    tertiaryContainer: Color(0xFF3B4C61),
    onTertiaryContainer: Color(0xFFD6E4F4),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF171210),
    onSurface: Color(0xFFEDE0DA),
    onSurfaceVariant: Color(0xFFDDC2B5),
    outline: Color(0xFFA58D82),
    outlineVariant: Color(0xFF57443A),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFEDE0DA),
    onInverseSurface: Color(0xFF372F2B),
    inversePrimary: _brand,
    surfaceTint: _brandDark,
  );

  static ThemeData light() => _build(lightScheme);
  static ThemeData dark() => _build(darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    const tokens = AppTokens.standard;
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
    final textTheme = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.4),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radiusMedium),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radiusLarge),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: const [tokens],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        surfaceTintColor: scheme.surfaceTint,
        iconTheme: IconThemeData(color: scheme.onPrimary),
        actionsIconTheme: IconThemeData(color: scheme.onPrimary),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: scheme.surfaceTint,
        shape: shape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        floatingLabelStyle: TextStyle(color: scheme.primary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMedium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 52),
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMedium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: scheme.surfaceContainerLow,
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: scheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMedium),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusSmall),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLarge),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minTileHeight: 56,
        iconColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMedium),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: scheme.surfaceTint,
        shape: shape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        modalBackgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: scheme.surfaceTint,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMedium),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.secondaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSmall),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
