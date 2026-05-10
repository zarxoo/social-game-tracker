import 'package:flutter/material.dart';
import 'package:social_game_tracker/core/theme/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onSearch;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search Game...',
    this.controller,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTheme.bodyText,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTheme.subtitleText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: false,
              ),
              onSubmitted: (_) {
                if (onSearch != null) onSearch!();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Search', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
