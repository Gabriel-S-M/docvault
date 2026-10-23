import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String id;
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

  factory DocumentItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DocumentItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      category: data['category'] as String? ?? '',
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      pages: (data['pages'] as num?)?.toInt() ?? 0,
      size: data['size'] as String? ?? '',
      author: data['author'] as String? ?? '',
      thumbnail: data['thumbnail'] as String? ?? '',
      url: data['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'date': Timestamp.fromDate(date),
      'pages': pages,
      'size': size,
      'author': author,
      'thumbnail': thumbnail,
      'url': url,
    };
  }

  DocumentItem copyWith({
    String? id,
    String? title,
    String? category,
    DateTime? date,
    int? pages,
    String? size,
    String? author,
    String? thumbnail,
    String? url,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      pages: pages ?? this.pages,
      size: size ?? this.size,
      author: author ?? this.author,
      thumbnail: thumbnail ?? this.thumbnail,
      url: url ?? this.url,
    );
  }

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

  String get isoDateString {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}

const List<String> kDocumentCategoryOptions = [
  'Relatórios',
  'Manuais',
  'Propostas',
  'Contratos',
  'Atas',
  'Políticas',
];

const List<String> kDocumentCategories = [
  'Todos',
  ...kDocumentCategoryOptions,
];
