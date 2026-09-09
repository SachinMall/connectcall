import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class SearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap;
  final String hintText;

  const SearchField({
    super.key,
    required this.onChanged,
    this.onTap,
    this.hintText = 'Search people...',
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() => _hasText = value.isNotEmpty);
    widget.onChanged(value);
  }

  void _handleClear() {
    _controller.clear();
    _handleChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor),
    );

    return TextField(
      controller: _controller,
      onChanged: _handleChanged,
      onTap: widget.onTap,
      style: AppTypography.body,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: fillColor,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: _handleClear,
              )
            : null,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.primary, width: 1.6)),
      ),
    );
  }
}
