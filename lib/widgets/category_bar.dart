import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryBar extends StatelessWidget {
  final List<String> categories;
  final String activeCategory;
  final ValueChanged<String> onSelectCategory;
  final bool isDarkMode;

  const CategoryBar({
    super.key,
    required this.categories,
    required this.activeCategory,
    required this.onSelectCategory,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.stone900 : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.stone700 : AppColors.stone100,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories.map((cat) {
                final isSelected = activeCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => onSelectCategory(cat),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.indigo700
                            : (isDarkMode ? Colors.transparent : Colors.transparent),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : (isDarkMode ? AppColors.stone400 : AppColors.stone500),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
