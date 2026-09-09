import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

enum ButtonVariant { primary, secondary, tertiary, destructive }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
  });

  const PrimaryButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  }) : variant = ButtonVariant.secondary;

  const PrimaryButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  }) : variant = ButtonVariant.destructive;

  bool get _isDisabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color background;
    final Color foreground;
    final BoxBorder? border;

    switch (variant) {
      case ButtonVariant.primary:
        background = AppColors.primary;
        foreground = Colors.white;
        border = null;
        break;
      case ButtonVariant.secondary:
        background = Colors.transparent;
        foreground = AppColors.primary;
        border = Border.all(color: AppColors.primary, width: 1.4);
        break;
      case ButtonVariant.tertiary:
        background = Colors.transparent;
        foreground = AppColors.primary;
        border = null;
        break;
      case ButtonVariant.destructive:
        background = AppColors.error;
        foreground = Colors.white;
        border = null;
        break;
    }

    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: AppTypography.button.copyWith(color: foreground)),
            ],
          );

    final button = AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: _isDisabled && variant != ButtonVariant.tertiary && !isLoading ? 0.5 : 1,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _isDisabled ? null : onPressed,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: border,
              boxShadow: variant == ButtonVariant.primary && !isDark
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: content,
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
