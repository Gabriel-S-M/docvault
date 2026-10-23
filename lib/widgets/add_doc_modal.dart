import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/document_item.dart';
import '../services/document_storage_service.dart';
import '../theme/app_theme.dart';

class AddDocModal extends StatefulWidget {
  final ValueChanged<DocumentItem> onSave;
  final VoidCallback onClose;
  final bool isDarkMode;
  final String companyId;

  const AddDocModal({
    super.key,
    required this.onSave,
    required this.onClose,
    required this.isDarkMode,
    required this.companyId,
  });

  @override
  State<AddDocModal> createState() => _AddDocModalState();
}

class _AddDocModalState extends State<AddDocModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  PlatformFile? _pdfFile;
  PlatformFile? _imageFile;

  String _category = kDocumentCategoryOptions.first;
  DateTime _selectedDate = DateTime.now();

  // O tamanho vem do arquivo selecionado; a contagem de páginas ainda não é extraída.
  int _autoPages = 0;
  String _autoSize = '0.0 MB';

  bool _isSaving = false;

  Future<void> _pickFile({required bool image}) async {
    final result = await FilePicker.platform.pickFiles(
      type: image ? FileType.image : FileType.custom,
      allowedExtensions: image ? null : ['pdf'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    setState(() {
      if (image) {
        _imageFile = result.files.single;
      } else {
        _pdfFile = result.files.single;
        _autoSize = '${(_pdfFile!.size / (1024 * 1024)).toStringAsFixed(1)} MB';
        _autoPages = 0;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
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

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();

    if (title.isEmpty) {
      _showError('Por favor, preencha o título do documento.');
      return;
    }
    if (author.isEmpty) {
      _showError('Por favor, preencha o autor do documento.');
      return;
    }
    if (_pdfFile?.bytes == null) {
      _showError('Selecione o arquivo PDF.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final storageId = DateTime.now().microsecondsSinceEpoch.toString();
      final storage = DocumentStorageService();
      final pdfUrl = await storage.upload(
        companyId: widget.companyId,
        documentId: storageId,
        kind: 'document.pdf',
        bytes: _pdfFile!.bytes!,
        contentType: 'application/pdf',
      );
      var thumbnailUrl = '';
      if (_imageFile?.bytes != null) {
        final ext = (_imageFile!.extension ?? 'jpg').toLowerCase();
        thumbnailUrl = await storage.upload(
          companyId: widget.companyId,
          documentId: storageId,
          kind: 'cover.$ext',
          bytes: _imageFile!.bytes!,
          contentType: DocumentStorageService.imageContentType(ext),
        );
      }
      final newDoc = DocumentItem(
        id: '', // Será gerado pelo Firestore
        title: title,
        author: author,
        category: _category,
        date: _selectedDate,
        pages: _autoPages,
        size: _autoSize,
        url: pdfUrl,
        thumbnail: thumbnailUrl,
      );
      widget.onSave(newDoc);
      widget.onClose();
    } catch (e) {
      if (mounted) _showError('Não foi possível enviar os arquivos: $e');
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 640;

    return Stack(
      children: [
        // Backdrop overlay com blur
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

        // Painel lateral direito
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
                            'Adicionar documento',
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

                // Corpo do formulário
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preview da thumbnail
                        _buildThumbnailPreview(isDark),

                        const SizedBox(height: 20),

                        // Título
                        _buildFieldLabel('TÍTULO *'),
                        _buildTextField(
                          controller: _titleController,
                          hintText: 'Título do documento',
                          isDark: isDark,
                        ),

                        const SizedBox(height: 16),

                        // Autor
                        _buildFieldLabel('AUTOR *'),
                        _buildTextField(
                          controller: _authorController,
                          hintText: 'Nome do autor / responsável',
                          isDark: isDark,
                        ),

                        const SizedBox(height: 16),

                        // Categoria
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

                        // Data de publicação
                        _buildFieldLabel('DATA DE PUBLICAÇÃO'),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
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
                                    color: isDark
                                        ? AppColors.stone100
                                        : AppColors.stone900,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.stone400
                                      : AppColors.stone500,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Metadados automáticos
                        _buildAutomaticPdfMetadataCard(isDark),

                        const SizedBox(height: 16),

                        _buildFieldLabel('ARQUIVO PDF *'),
                        _buildFilePickerButton(
                          label: _pdfFile?.name ?? 'Selecionar arquivo PDF',
                          icon: Icons.picture_as_pdf_outlined,
                          onTap: _isSaving ? null : () => _pickFile(image: false),
                          isDark: isDark,
                        ),

                        const SizedBox(height: 16),

                        _buildFieldLabel('IMAGEM DE CAPA'),
                        _buildFilePickerButton(
                          label: _imageFile?.name ?? 'Selecionar imagem',
                          icon: Icons.image_outlined,
                          onTap: _isSaving ? null : () => _pickFile(image: true),
                          isDark: isDark,
                        ),

                        const SizedBox(height: 8),

                        // Nota campos obrigatórios
                        Text(
                          '* Campos obrigatórios',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.stone500 : AppColors.stone400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botões de ação
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
                              color: isDark
                                  ? AppColors.stone600
                                  : AppColors.stone200,
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
                              color: isDark
                                  ? AppColors.stone300
                                  : AppColors.stone700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _handleSave,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.upload_file_rounded, size: 16),
                          label: Text(
                            _isSaving ? 'Salvando...' : 'Adicionar',
                            style: const TextStyle(
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

  Widget _buildFilePickerButton({required String label, required IconData icon, required VoidCallback? onTap, required bool isDark}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        alignment: Alignment.centerLeft,
        foregroundColor: isDark ? AppColors.stone200 : AppColors.stone700,
        side: BorderSide(color: isDark ? AppColors.stone600 : AppColors.stone200),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  Widget _buildThumbnailPreview(bool isDark) {
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
            child: _imageFile?.bytes != null
                ? Image.memory(_imageFile!.bytes!, fit: BoxFit.cover)
                : _buildThumbnailPlaceholder(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailPlaceholder(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 32,
            color: isDark ? AppColors.stone600 : AppColors.stone400,
          ),
          const SizedBox(height: 6),
          Text(
            'Selecione uma imagem de capa abaixo',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.stone500 : AppColors.stone400,
            ),
          ),
        ],
      ),
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
                          Icon(Icons.auto_stories_outlined,
                              size: 13, color: AppColors.stone400),
                          const SizedBox(width: 4),
                          Text(
                            'Páginas',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.stone400),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_autoPages pág.',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.stone100
                              : AppColors.stone900,
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
                          Icon(Icons.data_usage_rounded,
                              size: 13, color: AppColors.stone400),
                          const SizedBox(width: 4),
                          Text(
                            'Tamanho',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.stone400),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _autoSize,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.stone100
                              : AppColors.stone900,
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
            'O tamanho é calculado automaticamente a partir do arquivo selecionado.',
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
