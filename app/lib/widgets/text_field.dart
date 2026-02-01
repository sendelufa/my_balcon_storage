import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Custom text field widget with minimal styling and validation states.
///
/// Features:
/// - Thin borders matching design system
/// - Validation states (error, success)
/// - Optional label and hint text
/// - Prefix and suffix support
/// - Character counter
class AppTextField extends StatefulWidget {
  /// Controller for the text field
  final TextEditingController? controller;

  /// Label text displayed above the field
  final String? label;

  /// Hint text displayed when field is empty
  final String? hint;

  /// Error message to display (null = no error)
  final String? errorText;

  /// Whether field is in success state
  final bool showSuccess;

  /// Helper text displayed below the field
  final String? helperText;

  /// Icon to display before input
  final IconData? prefixIcon;

  /// Widget to display before input
  final Widget? prefix;

  /// Icon to display after input
  final IconData? suffixIcon;

  /// Callback for suffix icon tap
  final VoidCallback? onSuffixIconTap;

  /// Widget to display after input
  final Widget? suffix;

  /// Maximum number of characters
  final int? maxLength;

  /// Whether to show character counter
  final bool showCounter;

  /// Keyboard type for the input
  final TextInputType? keyboardType;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Whether field is password (obscured)
  final bool isPassword;

  /// Whether field is enabled
  final bool enabled;

  /// Whether field is read-only
  final bool readOnly;

  /// Max lines for multiline input
  final int? maxLines;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Callback when field is submitted
  final ValueChanged<String>? onSubmitted;

  /// Callback when field is tapped
  final VoidCallback? onTap;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Focus node
  final FocusNode? focusNode;

  /// Initial value
  final String? initialValue;

  /// Text capitalization
  final TextCapitalization textCapitalization;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.showSuccess = false,
    this.helperText,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.suffix,
    this.maxLength,
    this.showCounter = false,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.focusNode,
    this.initialValue,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasError = widget.errorText != null;
    final showSuccessBorder = widget.showSuccess && !hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelMedium.copyWith(
              color: hasError
                  ? AppColors.error
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextField(
          controller: _controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscuringCharacter: '·',
          obscureText: _obscureText,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          inputFormatters: widget.inputFormatters,
          textCapitalization: widget.textCapitalization,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.backgroundDarkSecondary
                : AppColors.backgroundLightSecondary,
            contentPadding: widget.prefixIcon != null ||
                    widget.prefix != null ||
                    widget.suffix != null
                ? const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  )
                : AppSpacing.paddingTextField,
            border: _buildBorder(
              isDark: isDark,
              hasError: false,
              showSuccess: false,
            ),
            enabledBorder: _buildBorder(
              isDark: isDark,
              hasError: false,
              showSuccess: showSuccessBorder,
            ),
            focusedBorder: _buildBorder(
              isDark: isDark,
              hasError: hasError,
              showSuccess: showSuccessBorder,
              isFocused: true,
            ),
            errorBorder: _buildBorder(
              isDark: isDark,
              hasError: true,
              showSuccess: false,
            ),
            focusedErrorBorder: _buildBorder(
              isDark: isDark,
              hasError: true,
              showSuccess: false,
              isFocused: true,
            ),
            disabledBorder: _buildBorder(
              isDark: isDark,
              hasError: false,
              showSuccess: false,
              isDisabled: true,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  )
                : widget.prefix,
            suffixIcon: _buildSuffixIcon(isDark),
            suffix: widget.suffix,
            counterText: widget.showCounter ? null : '',
            errorText: null,
          ),
        ),
        if (widget.errorText != null || widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              left: AppSpacing.sm,
            ),
            child: Text(
              widget.errorText ?? widget.helperText ?? '',
              style: AppTypography.bodySmall.copyWith(
                color: widget.errorText != null
                    ? AppColors.error
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
              ),
            ),
          ),
        if (widget.showCounter && widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              right: AppSpacing.sm,
            ),
            child: Text(
              '${_controller.text.length}/${widget.maxLength}',
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? AppColors.textDisabledDark
                    : AppColors.textDisabledLight,
              ),
              textAlign: TextAlign.right,
            ),
          ),
      ],
    );
  }

  Widget? _buildSuffixIcon(bool isDark) {
    if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onSuffixIconTap,
        child: Icon(
          widget.suffixIcon,
          size: 20,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      );
    }

    if (widget.isPassword) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        child: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      );
    }

    if (widget.showSuccess) {
      return const Icon(
        Icons.check_circle,
        size: 20,
        color: AppColors.success,
      );
    }

    return null;
  }

  InputBorder _buildBorder({
    required bool isDark,
    required bool hasError,
    required bool showSuccess,
    bool isFocused = false,
    bool isDisabled = false,
  }) {
    Color getColor() {
      if (hasError) return AppColors.error;
      if (showSuccess) return AppColors.success;
      if (isDisabled) {
        return isDark
            ? AppColors.textDisabledDark
            : AppColors.textDisabledLight;
      }
      if (isFocused) {
        return isDark ? AppColors.primaryLight : AppColors.primary;
      }
      return isDark ? AppColors.borderDark : AppColors.borderLight;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(
        color: getColor(),
        width: isFocused ? 1.5 : 1,
      ),
    );
  }
}

/// Search text field widget with search icon
class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool enabled;
  final FocusNode? focusNode;

  const AppSearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hint ?? 'Search...',
      prefixIcon: Icons.search_outlined,
      suffixIcon: Icons.close,
      onSuffixIconTap: onClear,
      enabled: enabled,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
    );
  }
}

/// Text area widget for multiline input
class AppTextArea extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  const AppTextArea({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.maxLines = 5,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      helperText: helperText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      onChanged: onChanged,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
