import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';

class AdminCard extends StatefulWidget {
  final DocumentItem doc;
  final ValueChanged<DocumentItem> onEdit;
  final ValueChanged<String> onDelete;
  final bool isDarkMode;

  const AdminCard({
    super.key,
    required this.doc,
    required this.onEdit,
    required this.onDelete,
    required this.isDarkMode,
  });

  @override
  State<AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<AdminCard> {
  bool _isHovered = false;
  bool _isPopoverOpen = false;

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
                widget.onDelete(widget.doc.id);
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

    final borderColor = _isHovered
        ? (isDark ? AppColors.indigo500 : AppColors.indigo400)
        : (isDark ? AppColors.stone700 : AppColors.stone200);

    final cardBg = isDark ? AppColors.stone900 : Colors.white;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Card
          AnimatedContainer(
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
                        // Background Image
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

                        // Pencil Edit Button on Top Right
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() => _isPopoverOpen = !_isPopoverOpen);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: _isPopoverOpen
                                      ? AppColors.indigo600
                                      : Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 15,
                                  color: _isPopoverOpen
                                      ? Colors.white
                                      : AppColors.stone700,
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
                            color: isDark ? AppColors.stone100 : AppColors.stone900,
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

          // Floating Popover Menu
          if (_isPopoverOpen)
            Positioned(
              top: 38,
              right: 8,
              child: Container(
                width: 260,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.stone900 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.stone700 : AppColors.stone200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Popover Header with mini preview
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: SizedBox(
                                  width: 40,
                                  height: 48,
                                  child: Image.network(
                                    doc.thumbnail,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => Container(
                                      color: isDark ? AppColors.stone800 : AppColors.stone200,
                                      child: const Icon(Icons.description, size: 20),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.category.toUpperCase(),
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.indigo400 : AppColors.indigo600,
                                      ),
                                    ),
                                    Text(
                                      doc.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.stone100 : AppColors.stone900,
                                      ),
                                    ),
                                    Text(
                                      doc.author,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.stone400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Metric pills
                          Row(
                            children: [
                              _buildMetricBox('${doc.pages}', 'páginas', isDark),
                              const SizedBox(width: 6),
                              _buildMetricBox(doc.size, 'tamanho', isDark),
                              const SizedBox(width: 6),
                              _buildMetricBox(
                                '${doc.date.year}',
                                '${doc.date.day}/${doc.date.month}',
                                isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      color: isDark ? AppColors.stone700 : AppColors.stone100,
                      height: 1,
                    ),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          // Edit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() => _isPopoverOpen = false);
                                widget.onEdit(doc);
                              },
                              icon: const Icon(Icons.edit_rounded, size: 14),
                              label: const Text('Editar documento'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.indigo700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                                textStyle: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Delete Button
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() => _isPopoverOpen = false);
                                _showDeleteConfirmation(context);
                              },
                              icon: const Icon(Icons.delete_outline_rounded, size: 14),
                              label: const Text('Excluir documento'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String topText, String bottomText, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.stone800 : AppColors.stone50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              topText,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.stone200 : AppColors.stone700,
              ),
            ),
            Text(
              bottomText,
              style: TextStyle(
                fontSize: 9.5,
                color: AppColors.stone400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
