import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';

class PdfModal extends StatefulWidget {
  final DocumentItem doc;
  final VoidCallback onClose;
  final bool isDarkMode;

  const PdfModal({
    super.key,
    required this.doc,
    required this.onClose,
    required this.isDarkMode,
  });

  @override
  State<PdfModal> createState() => _PdfModalState();
}

class _PdfModalState extends State<PdfModal> {
  int _currentPage = 1;
  double _zoomScale = 1.0;
  bool _showFallbackView = false;

  Future<void> _handleDownload() async {
    final uri = Uri.parse(widget.doc.url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Baixando: ${widget.doc.title} (${widget.doc.size})'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.indigo700,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download iniciado para: ${widget.doc.title}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.indigo700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final isDark = widget.isDarkMode;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Backdrop overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),

        // Centered Modal Dialog
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 900,
              maxHeight: size.height * 0.88,
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
                    // Modal Header
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
                                  '${doc.author} · ${doc.pages} páginas · ${doc.size}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.stone400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Close button
                          IconButton(
                            onPressed: widget.onClose,
                            icon: const Icon(Icons.close_rounded),
                            color: isDark ? AppColors.stone400 : AppColors.stone500,
                            splashRadius: 20,
                            tooltip: 'Fechar',
                          ),
                        ],
                      ),
                    ),

                    // Modal Body: PDF Viewer
                    Expanded(
                      child: Container(
                        color: isDark ? AppColors.stone950 : AppColors.stone200,
                        child: Stack(
                          children: [
                            // Viewer Canvas
                            _showFallbackView
                                ? _buildFallbackView(isDark)
                                : _buildInteractivePdfCanvas(doc, isDark),

                            // Top PDF toolbar (Zoom, page nav, toggle view)
                            Positioned(
                              top: 12,
                              left: 16,
                              right: 16,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Page Navigation
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isDark ? AppColors.stone900 : Colors.white)
                                          .withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.chevron_left_rounded, size: 18),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                          splashRadius: 14,
                                          onPressed: _currentPage > 1
                                              ? () => setState(() => _currentPage--)
                                              : null,
                                        ),
                                        Text(
                                          'Pág. $_currentPage de ${doc.pages}',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? AppColors.stone200 : AppColors.stone700,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chevron_right_rounded, size: 18),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                          splashRadius: 14,
                                          onPressed: _currentPage < doc.pages
                                              ? () => setState(() => _currentPage++)
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Zoom and Mode tools
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isDark ? AppColors.stone900 : Colors.white)
                                          .withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.zoom_out_rounded, size: 16),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                          splashRadius: 14,
                                          onPressed: () {
                                            if (_zoomScale > 0.6) {
                                              setState(() => _zoomScale -= 0.15);
                                            }
                                          },
                                        ),
                                        Text(
                                          '${(_zoomScale * 100).toInt()}%',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 11,
                                            color: isDark ? AppColors.stone300 : AppColors.stone600,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.zoom_in_rounded, size: 16),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                          splashRadius: 14,
                                          onPressed: () {
                                            if (_zoomScale < 1.6) {
                                              setState(() => _zoomScale += 0.15);
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: Icon(
                                            _showFallbackView
                                                ? Icons.auto_stories_outlined
                                                : Icons.info_outline_rounded,
                                            size: 16,
                                          ),
                                          tooltip: _showFallbackView
                                              ? 'Ver Leitor PDF'
                                              : 'Ver Info do Navegador',
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                          splashRadius: 14,
                                          onPressed: () {
                                            setState(() => _showFallbackView = !_showFallbackView);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Floating Download Balloon at bottom center
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C1917).withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.file_present_rounded,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 180),
                                        child: Text(
                                          doc.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton(
                                        onPressed: _handleDownload,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.indigo500,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          minimumSize: Size.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          'Baixar PDF',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 48,
              color: isDark ? AppColors.stone600 : AppColors.stone400,
            ),
            const SizedBox(height: 16),
            Text(
              'Visualização rápida do documento inline.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.stone200 : AppColors.stone700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Use o botão abaixo para baixar ou abrir externamente o arquivo PDF completo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.stone400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractivePdfCanvas(DocumentItem doc, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 80),
      child: Center(
        child: Transform.scale(
          scale: _zoomScale,
          child: Container(
            width: 580,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header in document
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.indigo600,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.description_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DocVault • Documento Oficial',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.stone800,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Ref: #${doc.id.toString().padLeft(4, '0')}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: AppColors.stone500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: AppColors.stone200, height: 1),
                const SizedBox(height: 24),

                // Doc Title
                Text(
                  doc.title,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.stone900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Categoria: ${doc.category}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.indigo700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '•   Autor: ${doc.author}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.stone600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '•   Data: ${doc.formattedDate}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.stone600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Simulated Content Page
                Text(
                  '1. Introdução e Visão Geral Executiva',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.stone900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Este documento apresenta as diretrizes e os resultados consolidados referentes ao projeto ${doc.title}. Todos os dados e análises descritos nesta documentação foram elaborados em conformidade com as melhores práticas de governança corporativa e conformidade regulatória.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.6,
                    color: AppColors.stone700,
                  ),
                ),

                const SizedBox(height: 16),

                // Simulated chart/data box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.stone50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.stone200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumo dos Indicadores Principais',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.stone800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildIndicatorRow('Volume Total Processado', '100% Concluído', 1.0),
                      const SizedBox(height: 8),
                      _buildIndicatorRow('Índice de Conformidade', '98.4%', 0.98),
                      const SizedBox(height: 8),
                      _buildIndicatorRow('Aderência aos Prazos', '94.2%', 0.94),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  '2. Metodologia e Escopo',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.stone900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'As seções subsequentes detalham as rotinas operacionais, relatórios de auditoria e pareceres técnicos expedidos por ${doc.author}. Para acessar o anexo integral com todas as ${_currentPage == 1 ? doc.pages : doc.pages} páginas e tabelas de apuração, utilize a opção de download.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.6,
                    color: AppColors.stone700,
                  ),
                ),

                const SizedBox(height: 36),

                // Footer of Document
                Divider(color: AppColors.stone200, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Confidencial — Uso Interno',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.stone400,
                      ),
                    ),
                    Text(
                      'Página $_currentPage de ${doc.pages}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.stone500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorRow(String title, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.stone600),
            ),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.indigo700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.stone200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.indigo600),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
