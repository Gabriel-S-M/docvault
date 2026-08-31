import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';

class DocumentCard extends StatefulWidget {
  final DocumentItem doc;
  final VoidCallback onTap;
  final bool isDarkMode;

  const DocumentCard({
    super.key,
    required this.doc,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {
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
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: isDark
                          ? AppColors.indigo950.withValues(alpha: 0.5)
                          : AppColors.indigo500.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thumbnail area
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background & Image
                      Container(
                        color: isDark ? AppColors.stone800 : AppColors.stone100,
                        child: Image.network(
                          doc.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDark ? AppColors.stone800 : AppColors.stone200,
                              child: Center(
                                child: Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 40,
                                  color: isDark ? AppColors.stone600 : AppColors.stone400,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: isDark ? AppColors.stone800 : AppColors.stone100,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.35),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // "PDF" tag at bottom right
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PDF',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.stone700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),

                      // Hover Play/Preview Circle
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: _isHovered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.indigo600.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.visibility_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category
                    Text(
                      doc.category.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: isDark ? AppColors.indigo400 : AppColors.indigo600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Title
                    SizedBox(
                      height: 36,
                      child: Text(
                        doc.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: _isHovered
                              ? (isDark ? AppColors.indigo400 : AppColors.indigo700)
                              : (isDark ? AppColors.stone100 : AppColors.stone900),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Author
                    Text(
                      doc.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.stone400 : AppColors.stone500,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Divider
                    Divider(
                      color: isDark ? AppColors.stone700 : AppColors.stone100,
                      height: 1,
                    ),

                    const SizedBox(height: 8),

                    // Footer: Date and Pages / Size
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            doc.formattedDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? AppColors.stone400 : AppColors.stone400,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${doc.pages} pág.',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? AppColors.stone400 : AppColors.stone400,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Text(
                                '·',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark ? AppColors.stone600 : AppColors.stone300,
                                ),
                              ),
                            ),
                            Text(
                              doc.size,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? AppColors.stone400 : AppColors.stone400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
