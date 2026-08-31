import 'package:intl/intl.dart';

enum SortKey {
  date('Mais recentes'),
  title('Título A–Z'),
  size('Tamanho'),
  pages('Nº de páginas');

  final String label;
  const SortKey(this.label);
}

enum ViewMode {
  grid('Grade'),
  list('Lista');

  final String label;
  const ViewMode(this.label);
}

class DocumentItem {
  final int id;
  final String title;
  final String category;
  final DateTime date;
  final int pages;
  final String size;
  final String author;
  final String thumbnail;
  final String url;

  const DocumentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.pages,
    required this.size,
    required this.author,
    required this.thumbnail,
    required this.url,
  });

  double get sizeInMb {
    final cleaned = size.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  String get formattedDate {
    return DateFormat("dd 'de' MMM. 'de' yyyy", 'pt_BR').format(date);
  }

  String get formattedShortDate {
    return DateFormat("dd/MM/yyyy").format(date);
  }
}

const List<String> kDocumentCategories = [
  'Todos',
  'Relatórios',
  'Manuais',
  'Propostas',
  'Contratos',
  'Atas',
  'Políticas',
];

final List<DocumentItem> kMockDocuments = [
  DocumentItem(
    id: 1,
    title: 'Relatório Anual 2024',
    category: 'Relatórios',
    date: DateTime(2024, 12, 15),
    pages: 48,
    size: '3.2 MB',
    author: 'Ana Beatriz Costa',
    thumbnail: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&h=280&fit=crop&auto=format',
    url: 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF2.pdf',
  ),
  DocumentItem(
    id: 2,
    title: 'Manual de Procedimentos Internos',
    category: 'Manuais',
    date: DateTime(2025, 1, 8),
    pages: 112,
    size: '7.8 MB',
    author: 'Carlos Mendes',
    thumbnail: 'https://images.unsplash.com/photo-1568667256531-f059bac5e5bb?w=400&h=280&fit=crop&auto=format',
    url: 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF3.pdf',
  ),
  DocumentItem(
    id: 3,
    title: 'Proposta Comercial — Q1 2025',
    category: 'Propostas',
    date: DateTime(2025, 2, 20),
    pages: 24,
    size: '1.4 MB',
    author: 'Fernanda Lima',
    thumbnail: 'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=400&h=280&fit=crop&auto=format',
    url: 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF6.pdf',
  ),
  DocumentItem(
    id: 4,
    title: 'Contrato de Prestação de Serviços',
    category: 'Contratos',
    date: DateTime(2025, 3, 5),
    pages: 18,
    size: '0.9 MB',
    author: 'Rafael Souza',
    thumbnail: 'https://images.unsplash.com/photo-1521791136064-7986c2920216?w=400&h=280&fit=crop&auto=format',
    url: 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF9.pdf',
  ),
  DocumentItem(
    id: 5,
    title: 'Ata da Reunião — Fevereiro 2025',
    category: 'Atas',
    date: DateTime(2025, 2, 28),
    pages: 6,
    size: '0.3 MB',
    author: 'Juliana Ramos',
    thumbnail: 'https://images.unsplash.com/photo-1506784365847-bbad939e9335?w=400&h=280&fit=crop&auto=format',
    url: 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF10.pdf',
  ),
  DocumentItem(
    id: 6,
    title: 'Política de Privacidade v3.1',
    category: 'Políticas',
    date: DateTime(2025, 1, 22),
    pages: 31,
    size: '1.1 MB',
    author: 'Pedro Almeida',
    thumbnail: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400&h=280&fit=crop&auto=format',
    url: 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF11.pdf',
  ),
  DocumentItem(
    id: 7,
    title: 'Plano de Marketing Digital 2025',
    category: 'Relatórios',
    date: DateTime(2025, 3, 10),
    pages: 65,
    size: '5.6 MB',
    author: 'Mariana Torres',
    thumbnail: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=400&h=280&fit=crop&auto=format',
    url: 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF12.pdf',
  ),
  DocumentItem(
    id: 8,
    title: 'Manual de Identidade Visual',
    category: 'Manuais',
    date: DateTime(2024, 11, 30),
    pages: 88,
    size: '12.4 MB',
    author: 'Bruno Carvalho',
    thumbnail: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400&h=280&fit=crop&auto=format',
    url: 'https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF15.pdf',
  ),
];
