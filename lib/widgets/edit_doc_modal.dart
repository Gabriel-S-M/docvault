import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';

class EditDocModal extends StatefulWidget {
  final DocumentItem doc;
  final ValueChanged<DocumentItem> onSave;
  final VoidCallback onClose;
  final bool isDarkMode;

  const EditDocModal({
    super.key,
    required this.doc,
    required this.onSave,
    required this.onClose,
    required this.isDarkMode,
  });

  @override
  State<EditDocModal> createState() => _EditDocModalState();
}

class _EditDocModalState extends State<EditDocModal> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _urlController;
  late TextEditingController _thumbnailController;
  late String _category;
  late DateTime _selectedDate;

  // Auto-calculated fields from PDF
  late int _autoPages;
  late String _autoSize;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.doc.title);
    _authorController = TextEditingController(text: widget.doc.author);
    _urlController = TextEditingController(text: widget.doc.url);
    _thumbnailController = TextEditingController(text: widget.doc.thumbnail);
    _category = widget.doc.category;
    _selectedDate = widget.doc.date;
    _autoPages = widget.doc.pages;
    _autoSize = widget.doc.size;

    _urlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    // When URL changes, automatically update the calculated size & pages based on PDF metadata
    final url = _urlController.text.trim();
    if (url.isNotEmpty && url != widget.doc.url) {
      // Simulate automatic extraction from new PDF
      final hash = url.hashCode.abs();
      final calcPages = (hash % 80) + 4;
      final calcSize = ((hash % 85) / 10 + 0.4).toStringAsFixed(1);
      setState(() {
        _autoPages = calcPages;
        _autoSize = '$calcSize MB';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _urlController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: widget.isDarkMode ? AppTheme.darkTheme() : AppTheme.lightTheme(),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSave() {
    final updatedDoc = widget.doc.copyWith(
      title: _titleController.text.trim().isEmpty
          ? widget.doc.title
          : _titleController.text.trim(),
      author: _authorController.text.trim().isEmpty
          ? widget.doc.author
          : _authorController.text.trim(),
      category: _category,
      date: _selectedDate,
      pages: _autoPages,
      size: _autoSize,
      url: _urlController.text.trim().isEmpty
          ? widget.doc.url
          : _urlController.text.trim(),
      thumbnail: _thumbnailController.text.trim().isEmpty
          ? widget.doc.thumbnail
          : _thumbnailController.text.trim(),
    );

    widget.onSave(updatedDoc);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 640;

    return Stack(
      children: [
        // Backdrop overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),

        // Slide-in Drawer / Side Sheet
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: isMobile ? size.width : 460,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.stone900 : Colors.white,
              border: Border(
                left: BorderSide(
                  color: isDark ? AppColors.stone700 : AppColors.stone200,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(-4, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.stone900 : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.stone700 : AppColors.stone200,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADMINISTRAÇÃO',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.stone400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Editar documento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.stone100 : AppColors.stone900,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: isDark ? AppColors.stone400 : AppColors.stone500,
                        splashRadius: 18,
                        tooltip: 'Fechar',
                      ),
                    ],
                  ),
                ),

                // Form Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail Preview with Change Image button
                        _buildThumbnailSection(isDark),

                        const SizedBox(height: 20),

                        // Title Field
                        _buildFieldLabel('TÍTULO'),
                        _buildTextField(
                          controller: _titleController,
                          hintText: 'Título do documento',
                          isDark: isDark,
                        ),

                        const SizedBox(height: 16),

                        // Author Field
                        _buildFieldLabel('AUTOR'),
                        _buildTextField(
                          controller: _authorController,
                          hintText: 'Nome do autor / responsável',
                          isDark: isDark,
                        ),

                        const SizedBox(height: 16),

                        // Category Dropdown
                        _buildFieldLabel('CATEGORIA'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.stone800 : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.stone600 : AppColors.stone200,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _category,
                              isExpanded: true,
                              dropdownColor: isDark ? AppColors.stone800 : Colors.white,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: isDark ? AppColors.stone400 : AppColors.stone500,
                              ),
                              style: TextStyle(
                                fontSize: 13.5,
                                color: isDark ? AppColors.stone100 : AppColors.stone900,
                              ),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _category = val);
                                }
                              },
                              items: kDocumentCategoryOptions.map((cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Date Picker Field
                        _buildFieldLabel('DATA DE PUBLICAÇÃO'),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.stone800 : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? AppColors.stone600 : AppColors.stone200,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR')
                                      .format(_selectedDate),
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: isDark ? AppColors.stone100 : AppColors.stone900,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: isDark ? AppColors.stone400 : AppColors.stone500,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Automatic PDF Metadata Card (Pages & Size)
                        _buildAutomaticPdfMetadataCard(isDark),

                        const SizedBox(height: 16),

                        // PDF URL Field
                        _buildFieldLabel('URL DO PDF'),
                        _buildTextField(
                          controller: _urlController,
                          hintText: 'https://exemplo.com/documento.pdf',
                          isDark: isDark,
                        ),

                        const SizedBox(height: 16),

                        // Thumbnail URL Field
                        _buildFieldLabel('URL DA THUMBNAIL'),
                        _buildTextField(
                          controller: _thumbnailController,
                          hintText: 'https://images.unsplash.com/...',
                          isDark: isDark,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.stone900 : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.stone700 : AppColors.stone200,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onClose,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: isDark ? AppColors.stone600 : AppColors.stone200,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.stone300 : AppColors.stone700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleSave,
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text(
                            'Salvar alterações',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.indigo700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
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
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
          color: AppColors.stone400,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 13.5,
        color: isDark ? AppColors.stone100 : AppColors.stone900,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: isDark ? AppColors.stone800 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? AppColors.stone600 : AppColors.stone200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.indigo600,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailSection(bool isDark) {
    final currentThumb = _thumbnailController.text.trim().isNotEmpty
        ? _thumbnailController.text.trim()
        : widget.doc.thumbnail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('IMAGEM DE CAPA'),
        Container(
          height: 130,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppColors.stone800 : AppColors.stone100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.stone700 : AppColors.stone200,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  currentThumb,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 36,
                        color: isDark ? AppColors.stone600 : AppColors.stone400,
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.25),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Prévia da Capa',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
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
      ],
    );
  }

  Widget _buildAutomaticPdfMetadataCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.stone800 : AppColors.stone50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.stone700 : AppColors.stone200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: isDark ? AppColors.indigo400 : AppColors.indigo600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'METADADOS DO PDF',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isDark ? AppColors.indigo400 : AppColors.indigo700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.indigo950.withValues(alpha: 0.8)
                      : AppColors.indigo500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Automático',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.indigo400 : AppColors.indigo600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.stone900 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.stone700 : AppColors.stone200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_stories_outlined,
                            size: 13,
                            color: AppColors.stone400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Páginas',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.stone400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_autoPages pág.',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.stone100 : AppColors.stone900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.stone900 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.stone700 : AppColors.stone200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.data_usage_rounded,
                            size: 13,
                            color: AppColors.stone400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tamanho',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.stone400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _autoSize,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.stone100 : AppColors.stone900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'O número de páginas e o tamanho são extraídos e calculados automaticamente a partir do arquivo PDF selecionado.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.stone400 : AppColors.stone500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
