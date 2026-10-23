import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/document_item.dart';
import '../theme/app_theme.dart';
import 'pdf_document_view.dart';

class PdfModal extends StatelessWidget {
  final DocumentItem doc;
  final VoidCallback onClose;
  final bool isDarkMode;

  const PdfModal({
    super.key,
    required this.doc,
    required this.onClose,
    required this.isDarkMode,
  });

  Future<void> _openPdf(BuildContext context) async {
    final uri = Uri.tryParse(doc.url);
    if (uri == null || !uri.hasScheme) {
      _showError(context, 'Este documento ainda não possui um arquivo PDF válido.');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        _showError(context, 'Não foi possível abrir o PDF.');
      }
    } catch (_) {
      if (context.mounted) _showError(context, 'Não foi possível abrir o PDF.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.indigo700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;
    final size = MediaQuery.of(context).size;
    final hasPdfUrl = doc.url.startsWith('https://') || doc.url.startsWith('http://');

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 1100,
              maxHeight: size.height * 0.9,
              minWidth: 320,
              minHeight: 400,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.stone900 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.stone700 : AppColors.stone200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.stone900 : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? AppColors.stone700 : AppColors.stone200,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.category.toUpperCase(),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                    color: AppColors.stone400,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  doc.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.stone100 : AppColors.stone900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${doc.author} · ${doc.size}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.stone400),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _openPdf(context),
                            icon: const Icon(Icons.open_in_new_rounded),
                            color: isDark ? AppColors.stone400 : AppColors.stone500,
                            tooltip: 'Abrir PDF em nova aba',
                          ),
                          IconButton(
                            onPressed: onClose,
                            icon: const Icon(Icons.close_rounded),
                            color: isDark ? AppColors.stone400 : AppColors.stone500,
                            tooltip: 'Fechar',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: isDark ? AppColors.stone950 : AppColors.stone200,
                        width: double.infinity,
                        child: hasPdfUrl
                            ? PdfDocumentView(
                                url: doc.url,
                              )
                            : const Center(
                                child: Text('Este documento ainda não possui um PDF enviado.'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
