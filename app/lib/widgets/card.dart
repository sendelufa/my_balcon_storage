import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

/// Custom card widget with minimal styling and thin borders.
///
/// Designed for displaying location and item cards in the storage app.
/// Supports different variants, states, and content layouts.
class AppCard extends StatelessWidget {
  /// Card content
  final Widget child;

  /// Optional card title
  final String? title;

  /// Optional subtitle
  final String? subtitle;

  /// Optional leading widget (usually an image or icon)
  final Widget? leading;

  /// Optional trailing widget
  final Widget? trailing;

  /// Card variant
  final AppCardVariant variant;

  /// Card padding
  final EdgeInsetsGeometry? padding;

  /// Card margin
  final EdgeInsetsGeometry? margin;

  /// Whether card is tappable
  final bool isTappable;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when card is long pressed
  final VoidCallback? onLongPress;

  /// Border radius
  final double? borderRadius;

  /// Optional custom border color
  final Color? borderColor;

  /// Optional custom background color
  final Color? backgroundColor;

  /// Whether to show elevation (shadow)
  final bool showElevation;

  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.variant = AppCardVariant.default_,
    this.padding,
    this.margin,
    this.isTappable = false,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.showElevation = false,
  });

  /// Factory constructor for location cards
  factory AppCard.location({
    Key? key,
    required String name,
    String? description,
    String? imagePath,
    Widget? trailing,
    VoidCallback? onTap,
    int itemCount = 0,
    Widget? child,
  }) {
    return AppCard(
      key: key,
      title: name,
      subtitle: description,
      leading: imagePath != null
          ? _LocationImage(imagePath: imagePath)
          : const _LocationPlaceholder(),
      trailing: trailing,
      isTappable: onTap != null,
      onTap: onTap,
      variant: AppCardVariant.location,
      child: child ?? const SizedBox.shrink(),
    );
  }

  /// Factory constructor for item cards
  factory AppCard.item({
    Key? key,
    required String name,
    String? description,
    String? locationName,
    String? imagePath,
    Widget? trailing,
    VoidCallback? onTap,
    Widget? child,
  }) {
    return AppCard(
      key: key,
      title: name,
      subtitle: description,
      leading: imagePath != null
          ? _ItemThumbnail(imagePath: imagePath)
          : const _ItemPlaceholder(),
      trailing: trailing,
      isTappable: onTap != null,
      onTap: onTap,
      variant: AppCardVariant.item,
      child: child ?? const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultMargin = margin ?? (variant == AppCardVariant.list
        ? const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs)
        : EdgeInsets.zero);

    final effectivePadding = padding ?? _getDefaultPadding();

    final effectiveBorderRadius = borderRadius ?? _getDefaultBorderRadius();

    final defaultBorderColor = borderColor ??
        (isDark ? AppColors.borderDark : AppColors.borderLight);

    final defaultBackgroundColor = backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    Widget content = _buildContent(context, effectivePadding);

    if (title != null || leading != null || trailing != null) {
      content = _buildWithHeader(context, effectivePadding);
    }

    Widget cardWidget = Container(
      margin: defaultMargin,
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: Border.all(
          color: defaultBorderColor,
          width: 1,
        ),
        boxShadow: showElevation
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isTappable ? onTap : null,
            onLongPress: onLongPress,
            child: content,
          ),
        ),
      ),
    );

    return cardWidget;
  }

  Widget _buildContent(BuildContext context, EdgeInsetsGeometry padding) {
    return Padding(
      padding: padding,
      child: child,
    );
  }

  Widget _buildWithHeader(BuildContext context, EdgeInsetsGeometry padding) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (variant == AppCardVariant.location ||
            variant == AppCardVariant.item)
          _buildMediaHeader(isDark)
        else
          _buildTextHeader(isDark),
        Padding(
          padding: padding,
          child: child,
        ),
      ],
    );
  }

  Widget _buildTextHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title!,
                  style: AppTypography.h5.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // ignore: use_null_aware_elements
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  Widget _buildMediaHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title!,
                  style: AppTypography.h5.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // ignore: use_null_aware_elements
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (variant) {
      case AppCardVariant.location:
      case AppCardVariant.item:
        return const EdgeInsets.all(AppSpacing.md);
      case AppCardVariant.list:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case AppCardVariant.default_:
        return AppSpacing.paddingCard;
    }
  }

  double _getDefaultBorderRadius() {
    switch (variant) {
      case AppCardVariant.location:
      case AppCardVariant.item:
        return AppSpacing.radiusMd;
      case AppCardVariant.list:
        return AppSpacing.radiusSm;
      case AppCardVariant.default_:
        return AppSpacing.radiusMd;
    }
  }
}

/// Card variant enum
enum AppCardVariant {
  default_,
  location,
  item,
  list,
}

// ================================
// INTERNAL WIDGETS
// ================================

/// Location image widget
class _LocationImage extends StatelessWidget {
  final String imagePath;

  const _LocationImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Image.asset(
        imagePath,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const _LocationPlaceholder();
        },
      ),
    );
  }
}

/// Location placeholder when no image
class _LocationPlaceholder extends StatelessWidget {
  const _LocationPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryTransparent
            : AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Icon(
        Icons.place_outlined,
        size: 32,
        color: isDark ? AppColors.primaryLight : AppColors.primary,
      ),
    );
  }
}

/// Item thumbnail widget
class _ItemThumbnail extends StatelessWidget {
  final String imagePath;

  const _ItemThumbnail({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Image.asset(
        imagePath,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const _ItemPlaceholder();
        },
      ),
    );
  }
}

/// Item placeholder when no image
class _ItemPlaceholder extends StatelessWidget {
  const _ItemPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDarkSecondary
            : AppColors.dividerLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        size: 24,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
    );
  }
}

/// Compact list tile card variant
class AppListTileCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDivider;

  const AppListTileCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: AppSpacing.paddingListTile,
              child: Row(
                children: [
                  if (leadingIcon != null) ...[
                    Icon(
                      leadingIcon,
                      size: 20,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle!,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // ignore: use_null_aware_elements
          if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
      ],
    );
  }
}

/// Action card with buttons
class AppActionCard extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> actions;
  final IconData? icon;

  const AppActionCard({
    super.key,
    required this.title,
    this.description,
    required this.actions,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      title: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 24,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTypography.h5.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions
                .map((action) => Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: action,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// Card widget for displaying containers with type badge.
///
/// Used in ContentsScreen to show storage containers like Boxes (Bo) and
/// Shelves (Sh). Features a circular type badge on the left and container
/// details on the right.
class ContainerCard extends StatelessWidget {
  /// Container name
  final String name;

  /// Optional container description
  final String? description;

  /// Two-letter type abbreviation (e.g., "Bo" for Box, "Sh" for Shelf)
  final String typeAbbreviation;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  const ContainerCard({
    super.key,
    required this.name,
    this.description,
    required this.typeAbbreviation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final textPrimaryColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Type badge
              _TypeBadge(
                abbreviation: typeAbbreviation,
                primaryColor: primaryColor,
                borderColor: borderColor,
              ),
              const SizedBox(width: AppSpacing.md),
              // Name and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: AppTypography.h6.copyWith(
                        color: textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Type badge widget for ContainerCard.
///
/// Displays a circular badge with a two-letter abbreviation.
class _TypeBadge extends StatelessWidget {
  final String abbreviation;
  final Color primaryColor;
  final Color borderColor;

  const _TypeBadge({
    required this.abbreviation,
    required this.primaryColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          abbreviation,
          style: AppTypography.labelMedium.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
