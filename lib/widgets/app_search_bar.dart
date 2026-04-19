import 'package:flutter/material.dart';
import '../style/constants/app_colors.dart';
import '../style/constants/app_dimens.dart';

/// Barre de recherche réutilisable
class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double? width;
  final ValueChanged<String>? onSubmitted;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hint = 'Chercher produit...',
    this.width,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: AppDimens.searchHeight,
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: AppDimens.fontSearch,
            color: AppColors.textHint,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 16,
            color: AppColors.textMuted,
          ),
          filled: true,
          fillColor: AppColors.searchFieldBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.searchRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.searchRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.searchRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          isDense: true,
        ),
        style: const TextStyle(fontSize: AppDimens.fontSearch),
      ),
    );
  }
}