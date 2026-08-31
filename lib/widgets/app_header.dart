import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final int totalCount;
  final bool isPanelOpen;
  final VoidCallback onTogglePanel;
  final bool isDarkMode;

  const AppHeader({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.totalCount,
    required this.isPanelOpen,
    required this.onTogglePanel,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.stone900 : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.stone700 : AppColors.stone200,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            children: [
              // Logo
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.indigo600,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'DocVault',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Search Bar
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        onChanged: onSearchChanged,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? AppColors.stone100 : AppColors.stone900,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Buscar documentos, autores…',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: isDarkMode ? AppColors.stone400 : AppColors.stone400,
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 16),
                                  splashRadius: 14,
                                  onPressed: () => onSearchChanged(''),
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          filled: true,
                          fillColor: isDarkMode ? AppColors.stone800 : AppColors.stone50,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkMode ? AppColors.stone600 : AppColors.stone200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDarkMode ? AppColors.indigo500 : AppColors.indigo600,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Doc Counter Badge
              if (isDesktop) ...[
                Text(
                  '$totalCount docs',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: AppColors.stone400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Options Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTogglePanel,
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isPanelOpen
                          ? AppColors.indigo700
                          : (isDarkMode ? AppColors.stone800 : Colors.white),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPanelOpen
                            ? AppColors.indigo700
                            : (isDarkMode ? AppColors.stone600 : AppColors.stone200),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 15,
                          color: isPanelOpen
                              ? Colors.white
                              : (isDarkMode ? AppColors.stone200 : AppColors.stone700),
                        ),
                        if (isDesktop) ...[
                          const SizedBox(width: 6),
                          Text(
                            'Opções',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isPanelOpen
                                  ? Colors.white
                                  : (isDarkMode ? AppColors.stone200 : AppColors.stone700),
                            ),
                          ),
                        ],
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: isPanelOpen ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: isPanelOpen
                                ? Colors.white
                                : (isDarkMode ? AppColors.stone400 : AppColors.stone500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
