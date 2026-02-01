import 'package:flutter/material.dart';
import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

/// App theme configuration combining colors, typography, and spacing.
///
/// Supports light and dark themes with Material Design 3.
/// Uses teal/cyan accent color with minimal styling and thin borders.
class AppTheme {
  AppTheme._();

  /// Light theme data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: AppTypography.createTextTheme(AppColors.textPrimaryLight),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: _appBarThemeLight,
      cardTheme: _cardThemeDataLight,
      elevatedButtonTheme: _elevatedButtonThemeLight,
      textButtonTheme: _textButtonThemeLight,
      outlinedButtonTheme: _outlinedButtonThemeLight,
      inputDecorationTheme: _inputDecorationThemeLight,
      dividerTheme: _dividerThemeLight,
      floatingActionButtonTheme: _floatingActionButtonThemeLight,
      bottomNavigationBarTheme: _bottomNavigationBarThemeLight,
      navigationBarTheme: _navigationBarThemeLight,
      navigationRailTheme: _navigationRailThemeLight,
      bottomSheetTheme: _bottomSheetThemeLight,
      dialogTheme: _dialogThemeDataLight,
      snackBarTheme: _snackBarThemeLight,
      chipTheme: _chipThemeLight,
      switchTheme: _switchThemeLight,
      checkboxTheme: _checkboxThemeLight,
      radioTheme: _radioThemeLight,
      sliderTheme: _sliderThemeLight,
      progressIndicatorTheme: _progressIndicatorThemeLight,
      tabBarTheme: _tabBarThemeDataLight,
      listTileTheme: _listTileThemeLight,
      iconTheme: _iconThemeLight,
      primaryIconTheme: _iconThemeLight,
    );
  }

  /// Dark theme data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      textTheme: AppTypography.createTextTheme(AppColors.textPrimaryDark),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: _appBarThemeDark,
      cardTheme: _cardThemeDataDark,
      elevatedButtonTheme: _elevatedButtonThemeDark,
      textButtonTheme: _textButtonThemeDark,
      outlinedButtonTheme: _outlinedButtonThemeDark,
      inputDecorationTheme: _inputDecorationThemeDark,
      dividerTheme: _dividerThemeDark,
      floatingActionButtonTheme: _floatingActionButtonThemeDark,
      bottomNavigationBarTheme: _bottomNavigationBarThemeDark,
      navigationBarTheme: _navigationBarThemeDark,
      navigationRailTheme: _navigationRailThemeDark,
      bottomSheetTheme: _bottomSheetThemeDark,
      dialogTheme: _dialogThemeDataDark,
      snackBarTheme: _snackBarThemeDark,
      chipTheme: _chipThemeDark,
      switchTheme: _switchThemeDark,
      checkboxTheme: _checkboxThemeDark,
      radioTheme: _radioThemeDark,
      sliderTheme: _sliderThemeDark,
      progressIndicatorTheme: _progressIndicatorThemeDark,
      tabBarTheme: _tabBarThemeDataDark,
      listTileTheme: _listTileThemeDark,
      iconTheme: _iconThemeDark,
      primaryIconTheme: _iconThemeDark,
    );
  }

  // ================================
  // COLOR SCHEMES
  // ================================

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryTransparent,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0x1F7E57C2),
    onSecondaryContainer: AppColors.secondaryDark,
    tertiary: AppColors.primary,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.primaryTransparent,
    onTertiaryContainer: AppColors.primaryDark,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorBackground,
    onErrorContainer: AppColors.error,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    surfaceContainerHighest: AppColors.backgroundLightSecondary,
    onSurfaceVariant: AppColors.textSecondaryLight,
    outline: AppColors.borderLight,
    outlineVariant: AppColors.dividerLight,
    shadow: AppColors.shadow,
    scrim: AppColors.overlay,
    inverseSurface: AppColors.surfaceDark,
    onInverseSurface: AppColors.textPrimaryDark,
    inversePrimary: AppColors.primaryLight,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    primaryContainer: Color(0x2F00BCD4),
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: Colors.black,
    secondaryContainer: Color(0x2F7E57C2),
    onSecondaryContainer: AppColors.secondaryLight,
    tertiary: AppColors.primaryLight,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0x2F00BCD4),
    onTertiaryContainer: AppColors.primaryLight,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0x2FE53935),
    onErrorContainer: AppColors.error,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.backgroundDarkSecondary,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.dividerDark,
    shadow: AppColors.shadow,
    scrim: AppColors.overlay,
    inverseSurface: AppColors.surfaceLight,
    onInverseSurface: AppColors.textPrimaryLight,
    inversePrimary: AppColors.primary,
  );

  // ================================
  // LIGHT THEME COMPONENTS
  // ================================

  static const AppBarTheme _appBarThemeLight = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.surfaceLight,
    foregroundColor: AppColors.textPrimaryLight,
    iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimaryLight,
      fontSize: AppTypography.h5Size,
      fontWeight: AppTypography.weightSemiBold,
      letterSpacing: AppTypography.letterSpacingNormal,
    ),
    surfaceTintColor: Colors.transparent,
  );

  static const CardThemeData _cardThemeDataLight = CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
      side: BorderSide(color: AppColors.borderLight, width: 1),
    ),
    color: AppColors.surfaceLight,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
  );

  static final ElevatedButtonThemeData _elevatedButtonThemeLight =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      textStyle: AppTypography.labelLarge,
      padding: AppSpacing.paddingButton,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      minimumSize: const Size(88, 44),
    ),
  );

  static final TextButtonThemeData _textButtonThemeLight = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: AppTypography.labelLarge,
      padding: AppSpacing.paddingButton,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      minimumSize: const Size(88, 44),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonThemeLight =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: AppTypography.labelLarge,
      padding: AppSpacing.paddingButton,
      side: const BorderSide(color: AppColors.primary, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      minimumSize: const Size(88, 44),
    ),
  );

  static const InputDecorationTheme _inputDecorationThemeLight =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.backgroundLightSecondary,
    contentPadding: AppSpacing.paddingTextField,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.borderLight, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.borderLight, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.textDisabledLight, width: 1),
    ),
    labelStyle: TextStyle(
      color: AppColors.textSecondaryLight,
      fontSize: AppTypography.bodyMediumSize,
    ),
    hintStyle: TextStyle(
      color: AppColors.textDisabledLight,
      fontSize: AppTypography.bodyMediumSize,
    ),
    errorStyle: TextStyle(
      color: AppColors.error,
      fontSize: AppTypography.bodySmallSize,
    ),
  );

  static const DividerThemeData _dividerThemeLight = DividerThemeData(
    color: AppColors.dividerLight,
    thickness: 1,
    space: 1,
  );

  static const FloatingActionButtonThemeData _floatingActionButtonThemeLight =
      FloatingActionButtonThemeData(
    elevation: 2,
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
    ),
  );

  static const BottomNavigationBarThemeData _bottomNavigationBarThemeLight =
      BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.surfaceLight,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondaryLight,
    selectedLabelStyle: TextStyle(
      fontSize: AppTypography.labelSmallSize,
      fontWeight: AppTypography.weightMedium,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: AppTypography.labelSmallSize,
      fontWeight: AppTypography.weightMedium,
    ),
    type: BottomNavigationBarType.fixed,
  );

  static const NavigationBarThemeData _navigationBarThemeLight =
      NavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.surfaceLight,
    indicatorColor: AppColors.primaryTransparent,
    labelTextStyle: WidgetStatePropertyAll(
      TextStyle(
        fontSize: AppTypography.labelSmallSize,
        fontWeight: AppTypography.weightMedium,
      ),
    ),
    iconTheme: WidgetStatePropertyAll(
      IconThemeData(color: AppColors.textSecondaryLight),
    ),
  );

  static const NavigationRailThemeData _navigationRailThemeLight =
      NavigationRailThemeData(
    elevation: 0,
    backgroundColor: AppColors.surfaceLight,
    indicatorColor: AppColors.primaryTransparent,
    selectedIconTheme: IconThemeData(color: AppColors.primary),
    unselectedIconTheme: IconThemeData(color: AppColors.textSecondaryLight),
  );

  static const BottomSheetThemeData _bottomSheetThemeLight =
      BottomSheetThemeData(
    backgroundColor: AppColors.surfaceLight,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
  );

  static const DialogThemeData _dialogThemeDataLight = DialogThemeData(
    backgroundColor: AppColors.surfaceLight,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
    ),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimaryLight,
      fontSize: AppTypography.h4Size,
      fontWeight: AppTypography.weightSemiBold,
    ),
    contentTextStyle: TextStyle(
      color: AppColors.textSecondaryLight,
      fontSize: AppTypography.bodyMediumSize,
    ),
  );

  static const SnackBarThemeData _snackBarThemeLight = SnackBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    contentTextStyle: TextStyle(color: AppColors.textPrimaryDark),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
    ),
    behavior: SnackBarBehavior.floating,
  );

  static const ChipThemeData _chipThemeLight = ChipThemeData(
    backgroundColor: AppColors.backgroundLightSecondary,
    deleteIconColor: AppColors.textSecondaryLight,
    disabledColor: AppColors.dividerLight,
    selectedColor: AppColors.primaryTransparent,
    secondarySelectedColor: AppColors.primaryTransparent,
    padding: AppSpacing.paddingChip,
    labelStyle: TextStyle(
      color: AppColors.textPrimaryLight,
      fontSize: AppTypography.labelMediumSize,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      side: BorderSide(color: AppColors.borderLight, width: 1),
    ),
  );

  static const SwitchThemeData _switchThemeLight = SwitchThemeData(
    thumbColor: WidgetStatePropertyAll(AppColors.primary),
    trackColor: WidgetStatePropertyAll(AppColors.primarySubtle),
  );

  static const CheckboxThemeData _checkboxThemeLight = CheckboxThemeData(
    fillColor: WidgetStatePropertyAll(AppColors.primary),
    checkColor: WidgetStatePropertyAll(Colors.white),
    side: BorderSide(color: AppColors.borderLight, width: 1.5),
  );

  static const RadioThemeData _radioThemeLight = RadioThemeData(
    fillColor: WidgetStatePropertyAll(AppColors.primary),
  );

  static const SliderThemeData _sliderThemeLight = SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.dividerLight,
    thumbColor: AppColors.primary,
    overlayColor: AppColors.primaryTransparent,
  );

  static const ProgressIndicatorThemeData _progressIndicatorThemeLight =
      ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.dividerLight,
  );

  static const TabBarThemeData _tabBarThemeDataLight = TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondaryLight,
    labelStyle: TextStyle(
      fontSize: AppTypography.labelMediumSize,
      fontWeight: AppTypography.weightMedium,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: AppTypography.labelMediumSize,
      fontWeight: AppTypography.weightMedium,
    ),
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
  );

  static const ListTileThemeData _listTileThemeLight = ListTileThemeData(
    contentPadding: AppSpacing.paddingListTile,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimaryLight,
      fontSize: AppTypography.bodyLargeSize,
      fontWeight: AppTypography.weightRegular,
    ),
    subtitleTextStyle: TextStyle(
      color: AppColors.textSecondaryLight,
      fontSize: AppTypography.bodyMediumSize,
    ),
  );

  static const IconThemeData _iconThemeLight = IconThemeData(
    color: AppColors.textSecondaryLight,
    size: 24,
  );

  // ================================
  // DARK THEME COMPONENTS
  // ================================

  static const AppBarTheme _appBarThemeDark = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textPrimaryDark,
    iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimaryDark,
      fontSize: AppTypography.h5Size,
      fontWeight: AppTypography.weightSemiBold,
      letterSpacing: AppTypography.letterSpacingNormal,
    ),
    surfaceTintColor: Colors.transparent,
  );

  static const CardThemeData _cardThemeDataDark = CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
      side: BorderSide(color: AppColors.borderDark, width: 1),
    ),
    color: AppColors.surfaceDark,
    surfaceTintColor: Colors.transparent,
    margin: EdgeInsets.zero,
  );

  static final ElevatedButtonThemeData _elevatedButtonThemeDark =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: AppColors.primaryLight,
      foregroundColor: Colors.white,
      textStyle: AppTypography.labelLarge,
      padding: AppSpacing.paddingButton,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      minimumSize: const Size(88, 44),
    ),
  );

  static final TextButtonThemeData _textButtonThemeDark = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      textStyle: AppTypography.labelLarge,
      padding: AppSpacing.paddingButton,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      minimumSize: const Size(88, 44),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonThemeDark =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryLight,
      textStyle: AppTypography.labelLarge,
      padding: AppSpacing.paddingButton,
      side: const BorderSide(color: AppColors.primaryLight, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      minimumSize: const Size(88, 44),
    ),
  );

  static const InputDecorationTheme _inputDecorationThemeDark =
      InputDecorationTheme(
    filled: true,
    fillColor: AppColors.backgroundDarkSecondary,
    contentPadding: AppSpacing.paddingTextField,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.borderDark, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.borderDark, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.primaryLight, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      borderSide: BorderSide(color: AppColors.textDisabledDark, width: 1),
    ),
    labelStyle: TextStyle(
      color: AppColors.textSecondaryDark,
      fontSize: AppTypography.bodyMediumSize,
    ),
    hintStyle: TextStyle(
      color: AppColors.textDisabledDark,
      fontSize: AppTypography.bodyMediumSize,
    ),
    errorStyle: TextStyle(
      color: AppColors.error,
      fontSize: AppTypography.bodySmallSize,
    ),
  );

  static const DividerThemeData _dividerThemeDark = DividerThemeData(
    color: AppColors.dividerDark,
    thickness: 1,
    space: 1,
  );

  static const FloatingActionButtonThemeData _floatingActionButtonThemeDark =
      FloatingActionButtonThemeData(
    elevation: 2,
    backgroundColor: AppColors.primaryLight,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
    ),
  );

  static const BottomNavigationBarThemeData _bottomNavigationBarThemeDark =
      BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.surfaceDark,
    selectedItemColor: AppColors.primaryLight,
    unselectedItemColor: AppColors.textSecondaryDark,
    selectedLabelStyle: TextStyle(
      fontSize: AppTypography.labelSmallSize,
      fontWeight: AppTypography.weightMedium,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: AppTypography.labelSmallSize,
      fontWeight: AppTypography.weightMedium,
    ),
    type: BottomNavigationBarType.fixed,
  );

  static const NavigationBarThemeData _navigationBarThemeDark =
      NavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.surfaceDark,
    indicatorColor: Color(0x2F00BCD4),
    labelTextStyle: WidgetStatePropertyAll(
      TextStyle(
        fontSize: AppTypography.labelSmallSize,
        fontWeight: AppTypography.weightMedium,
      ),
    ),
    iconTheme: WidgetStatePropertyAll(
      IconThemeData(color: AppColors.textSecondaryDark),
    ),
  );

  static const NavigationRailThemeData _navigationRailThemeDark =
      NavigationRailThemeData(
    elevation: 0,
    backgroundColor: AppColors.surfaceDark,
    indicatorColor: Color(0x2F00BCD4),
    selectedIconTheme: IconThemeData(color: AppColors.primaryLight),
    unselectedIconTheme: IconThemeData(color: AppColors.textSecondaryDark),
  );

  static const BottomSheetThemeData _bottomSheetThemeDark =
      BottomSheetThemeData(
    backgroundColor: AppColors.surfaceDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLg),
      ),
    ),
  );

  static const DialogThemeData _dialogThemeDataDark = DialogThemeData(
    backgroundColor: AppColors.surfaceDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
    ),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimaryDark,
      fontSize: AppTypography.h4Size,
      fontWeight: AppTypography.weightSemiBold,
    ),
    contentTextStyle: TextStyle(
      color: AppColors.textSecondaryDark,
      fontSize: AppTypography.bodyMediumSize,
    ),
  );

  static const SnackBarThemeData _snackBarThemeDark = SnackBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    contentTextStyle: TextStyle(color: AppColors.textPrimaryLight),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
    ),
    behavior: SnackBarBehavior.floating,
  );

  static const ChipThemeData _chipThemeDark = ChipThemeData(
    backgroundColor: AppColors.backgroundDarkSecondary,
    deleteIconColor: AppColors.textSecondaryDark,
    disabledColor: AppColors.dividerDark,
    selectedColor: Color(0x2F00BCD4),
    secondarySelectedColor: Color(0x2F00BCD4),
    padding: AppSpacing.paddingChip,
    labelStyle: TextStyle(
      color: AppColors.textPrimaryDark,
      fontSize: AppTypography.labelMediumSize,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusSm)),
      side: BorderSide(color: AppColors.borderDark, width: 1),
    ),
  );

  static const SwitchThemeData _switchThemeDark = SwitchThemeData(
    thumbColor: WidgetStatePropertyAll(AppColors.primaryLight),
    trackColor: WidgetStatePropertyAll(Color(0x2F00BCD4)),
  );

  static const CheckboxThemeData _checkboxThemeDark = CheckboxThemeData(
    fillColor: WidgetStatePropertyAll(AppColors.primaryLight),
    checkColor: WidgetStatePropertyAll(Colors.white),
    side: BorderSide(color: AppColors.borderDark, width: 1.5),
  );

  static const RadioThemeData _radioThemeDark = RadioThemeData(
    fillColor: WidgetStatePropertyAll(AppColors.primaryLight),
  );

  static const SliderThemeData _sliderThemeDark = SliderThemeData(
    activeTrackColor: AppColors.primaryLight,
    inactiveTrackColor: AppColors.dividerDark,
    thumbColor: AppColors.primaryLight,
    overlayColor: Color(0x2F00BCD4),
  );

  static const ProgressIndicatorThemeData _progressIndicatorThemeDark =
      ProgressIndicatorThemeData(
    color: AppColors.primaryLight,
    linearTrackColor: AppColors.dividerDark,
  );

  static const TabBarThemeData _tabBarThemeDataDark = TabBarThemeData(
    labelColor: AppColors.primaryLight,
    unselectedLabelColor: AppColors.textSecondaryDark,
    labelStyle: TextStyle(
      fontSize: AppTypography.labelMediumSize,
      fontWeight: AppTypography.weightMedium,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: AppTypography.labelMediumSize,
      fontWeight: AppTypography.weightMedium,
    ),
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
    ),
  );

  static const ListTileThemeData _listTileThemeDark = ListTileThemeData(
    contentPadding: AppSpacing.paddingListTile,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimaryDark,
      fontSize: AppTypography.bodyLargeSize,
      fontWeight: AppTypography.weightRegular,
    ),
    subtitleTextStyle: TextStyle(
      color: AppColors.textSecondaryDark,
      fontSize: AppTypography.bodyMediumSize,
    ),
  );

  static const IconThemeData _iconThemeDark = IconThemeData(
    color: AppColors.textSecondaryDark,
    size: 24,
  );

  // ================================
  // HELPER METHODS
  // ================================

  /// Get theme based on brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  /// Check if current theme is dark
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get ColorScheme based on context
  static ColorScheme colorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }
}
