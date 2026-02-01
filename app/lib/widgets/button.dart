import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Custom button widget with multiple variants.
///
/// Supports primary, secondary, danger, and text variants with
/// minimal styling and thin borders as per design system.
class AppButton extends StatelessWidget {
  /// Text to display on the button
  final String text;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button variant
  final AppButtonVariant variant;

  /// Button size
  final AppButtonSize size;

  /// Optional icon to display before text
  final IconData? icon;

  /// Whether button is in loading state
  final bool isLoading;

  /// Whether button is full width
  final bool isFullWidth;

  /// Optional tooltip text
  final String? tooltip;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    Widget buttonChild = _buildButtonContent(context);

    if (isFullWidth) {
      buttonChild = SizedBox(
        width: double.infinity,
        child: buttonChild,
      );
    }

    return SizedBox(
      height: _getHeight(),
      child: _buildButton(context, isEnabled, buttonChild),
    );
  }

  Widget _buildButton(BuildContext context, bool isEnabled, Widget child) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (variant) {
      case AppButtonVariant.primary:
        return _ElevatedButtonVariant(
          onPressed: isEnabled ? onPressed : null,
          isDark: isDark,
          isLoading: isLoading,
          child: child,
        );

      case AppButtonVariant.secondary:
        return _OutlinedButtonVariant(
          onPressed: isEnabled ? onPressed : null,
          isDark: isDark,
          isLoading: isLoading,
          child: child,
        );

      case AppButtonVariant.danger:
        return _DangerButtonVariant(
          onPressed: isEnabled ? onPressed : null,
          isDark: isDark,
          isLoading: isLoading,
          child: child,
        );

      case AppButtonVariant.text:
        return _TextButtonVariant(
          onPressed: isEnabled ? onPressed : null,
          isDark: isDark,
          isLoading: isLoading,
          child: child,
        );
    }
  }

  Widget _buildButtonContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return _LoadingIndicator(
        variant: variant,
        isDark: isDark,
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _getIconSize()),
          if (text.isNotEmpty) const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: _getTextStyle(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle(),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 36;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.large:
        return 52;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 18;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.labelMedium.copyWith(
          fontWeight: AppTypography.weightMedium,
          letterSpacing: AppTypography.letterSpacingWide,
        );
      case AppButtonSize.medium:
        return AppTypography.labelLarge.copyWith(
          fontWeight: AppTypography.weightMedium,
          letterSpacing: AppTypography.letterSpacingWide,
        );
      case AppButtonSize.large:
        return AppTypography.labelLarge.copyWith(
          fontWeight: AppTypography.weightSemiBold,
          letterSpacing: AppTypography.letterSpacingWide,
          fontSize: 16,
        );
    }
  }
}

/// Primary elevated button variant
class _ElevatedButtonVariant extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isDark;
  final bool isLoading;

  const _ElevatedButtonVariant({
    required this.onPressed,
    required this.child,
    required this.isDark,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight,
        disabledForegroundColor: Colors.white54,
        padding: AppSpacing.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      child: child,
    );
  }
}

/// Secondary outlined button variant
class _OutlinedButtonVariant extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isDark;
  final bool isLoading;

  const _OutlinedButtonVariant({
    required this.onPressed,
    required this.child,
    required this.isDark,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        side: BorderSide(
          color: onPressed == null
              ? (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight)
              : (isDark ? AppColors.primaryLight : AppColors.primary),
          width: 1,
        ),
        disabledForegroundColor:
            isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight,
        padding: AppSpacing.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      child: child,
    );
  }
}

/// Danger button variant for destructive actions
class _DangerButtonVariant extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isDark;
  final bool isLoading;

  const _DangerButtonVariant({
    required this.onPressed,
    required this.child,
    required this.isDark,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        disabledBackgroundColor:
            isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight,
        disabledForegroundColor: Colors.white54,
        padding: AppSpacing.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      child: child,
    );
  }
}

/// Text button variant for minimal actions
class _TextButtonVariant extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isDark;
  final bool isLoading;

  const _TextButtonVariant({
    required this.onPressed,
    required this.child,
    required this.isDark,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        disabledForegroundColor:
            isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight,
        padding: AppSpacing.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
      child: child,
    );
  }
}

/// Loading indicator for buttons
class _LoadingIndicator extends StatelessWidget {
  final AppButtonVariant variant;
  final bool isDark;

  const _LoadingIndicator({
    required this.variant,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      switch (variant) {
        case AppButtonVariant.primary:
          return Colors.white;
        case AppButtonVariant.secondary:
        case AppButtonVariant.text:
          return isDark ? AppColors.primaryLight : AppColors.primary;
        case AppButtonVariant.danger:
          return Colors.white;
      }
    }

    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(getColor()),
      ),
    );
  }
}

/// Button variant enum
enum AppButtonVariant { primary, secondary, danger, text }

/// Button size enum
enum AppButtonSize { small, medium, large }

/// Icon-only button variant
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final bool isLoading;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultColor = color ??
        (isDark ? AppColors.primaryLight : AppColors.primary);

    Widget child = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(defaultColor),
            ),
          )
        : Icon(icon, color: color);

    return IconButton(
      onPressed: isLoading ? null : onPressed,
      tooltip: tooltip,
      icon: child,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
