import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';

class DocumentListTile extends StatefulWidget {
  final DocumentItem doc;
  final VoidCallback onTap;
  final bool isDarkMode;
  final bool isAdmin;
  final ValueChanged<DocumentItem>? onEdit;
  final ValueChanged<int>? onDelete;

  const DocumentListTile({
    super.key,
    required this.doc,
    required this.onTap,
    required this.isDarkMode,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<DocumentListTile> createState() => _DocumentListTileState();
}

class _DocumentListTileState extends State<DocumentListTile> {
  bool _isHovered = false;
  bool _isExpanded = false;

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: widget.isDarkMode ? AppColors.stone900 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Excluir documento',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: widget.isDarkMode ? AppColors.stone100 : AppColors.stone900,
            ),
          ),
          content: Text(
            'Tem certeza que deseja excluir "${widget.doc.title}"? Esta ação não pode ser desfeita.',
            style: TextStyle(
              fontSize: 13,
              color: widget.isDarkMode ? AppColors.stone300 : AppColors.stone600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: widget.isDarkMode ? AppColors.stone400 : AppColors.stone600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                widget.onDelete?.call(widget.doc.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final isDark = widget.isDarkMode;

    final borderColor = _isExpanded
        ? (isDark ? AppColors.indigo500 : AppColors.indigo600)
        : (_isHovered
            ? (isDark ? AppColors.indigo400 : AppColors.indigo400)
            : (isDark ? AppColors.stone700 : AppColors.stone200));

    final cardBg = isDark ? AppColors.stone900 : Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (widget.isAdmin) {
            setState(() => _isExpanded = !_isExpanded);
          } else {
            widget.onTap();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: _isExpanded ? 1.5 : 1,
            ),
            boxShadow: (_isHovered || _isExpanded)
                ? [
                    BoxShadow(
                      color: isDark
                          ? AppColors.indigo950.withValues(alpha: 0.5)
                          : AppColors.indigo500.withValues(alpha: 0.1),
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

              // Info (Title, Category, Author)
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
                        color: (_isHovered || _isExpanded)
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

              const SizedBox(width: 14),

              // Date & Size Info (Slides to the left when expanded in admin mode)
              AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                offset: Offset.zero,
                child: Column(
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
              ),

              const SizedBox(width: 8),

              // Interactive Chevron Arrow that flips when tapped
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _isExpanded ? 0.5 : 0.0,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: _isExpanded
                      ? (isDark ? AppColors.indigo400 : AppColors.indigo600)
                      : (_isHovered
                          ? (isDark ? AppColors.indigo400 : AppColors.indigo600)
                          : (isDark ? AppColors.stone600 : AppColors.stone300)),
                ),
              ),

              // Inline Action Mini-Menu for Admin (Edit and Delete)
              if (widget.isAdmin)
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: _isExpanded
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 12),
                            Container(
                              width: 1,
                              height: 34,
                              color: isDark ? AppColors.stone700 : AppColors.stone200,
                            ),
                            const SizedBox(width: 10),

                            // Edit Button
                            Tooltip(
                              message: 'Editar documento',
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    widget.onEdit?.call(doc);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppColors.indigo700,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.edit_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Editar',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Delete Button
                            Tooltip(
                              message: 'Excluir documento',
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    _showDeleteConfirmation(context);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.redAccent.withValues(alpha: 0.15)
                                          : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDark
                                          ? Colors.redAccent.withValues(alpha: 0.3)
                                          : Colors.red.shade200,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          size: 14,
                                          color: Colors.redAccent,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Excluir',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
