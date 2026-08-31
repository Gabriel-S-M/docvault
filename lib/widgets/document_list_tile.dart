import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';

class DocumentListTile extends StatefulWidget {
  final DocumentItem doc;
  final VoidCallback onTap;
  final bool isDarkMode;

  const DocumentListTile({
    super.key,
    required this.doc,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  State<DocumentListTile> createState() => _DocumentListTileState();
}

class _DocumentListTileState extends State<DocumentListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final isDark = widget.isDarkMode;

    final borderColor = _isHovered
        ? (isDark ? AppColors.indigo500 : AppColors.indigo400)
        : (isDark ? AppColors.stone700 : AppColors.stone200);

    final cardBg = isDark ? AppColors.stone900 : Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: isDark
                          ? AppColors.indigo950.withValues(alpha: 0.4)
                          : AppColors.indigo500.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 70,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        doc.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark ? AppColors.stone800 : AppColors.stone200,
                            child: Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 28,
                              color: isDark ? AppColors.stone600 : AppColors.stone400,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            'PDF',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.stone700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      doc.category.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: isDark ? AppColors.indigo400 : AppColors.indigo600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doc.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isHovered
                            ? (isDark ? AppColors.indigo400 : AppColors.indigo700)
                            : (isDark ? AppColors.stone100 : AppColors.stone900),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      doc.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.stone400 : AppColors.stone500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Date and Size (Desktop / Tablet)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    doc.formattedShortDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.stone300 : AppColors.stone600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${doc.pages} pág. · ${doc.size}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.stone400 : AppColors.stone400,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: _isHovered
                    ? (isDark ? AppColors.indigo400 : AppColors.indigo600)
                    : (isDark ? AppColors.stone600 : AppColors.stone300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
