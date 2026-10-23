import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'document_item.dart';

const Map<String, IconData> kCompanyIconMap = {
  'business_rounded': Icons.business_rounded,
  'code_rounded': Icons.code_rounded,
  'local_shipping_rounded': Icons.local_shipping_rounded,
  'account_balance_rounded': Icons.account_balance_rounded,
  'medical_services_rounded': Icons.medical_services_rounded,
  'shopping_bag_rounded': Icons.shopping_bag_rounded,
  'factory_rounded': Icons.factory_rounded,
  'lightbulb_rounded': Icons.lightbulb_rounded,
};

String _iconToName(IconData? icon) {
  if (icon == null) return 'business_rounded';
  for (final entry in kCompanyIconMap.entries) {
    if (entry.value == icon) return entry.key;
  }
  return 'business_rounded';
}

Color _hexToColor(String hex) {
  final cleanHex = hex.replaceAll('#', '');
  final val = int.tryParse(cleanHex, radix: 16) ?? 0x4F46E5;
  if (cleanHex.length <= 6) {
    return Color(0xFF000000 | val);
  }
  return Color(val);
}

String _colorToHex(Color? color) {
  if (color == null) return '#FF4F46E5';
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

class CompanyItem {
  final String id;
  final String name;
  final String segment;
  final String description;
  final String iconName;
  final String accentColorHex;
  final String adminEmail;
  final String adminPassword;
  final String adminName;
  final List<DocumentItem> documents;

  CompanyItem({
    required this.id,
    required this.name,
    required this.segment,
    required this.description,
    String? iconName,
    IconData? icon,
    String? accentColorHex,
    Color? accentColor,
    this.adminEmail = '',
    this.adminPassword = '',
    required this.adminName,
    this.documents = const [],
  })  : iconName = iconName ?? (icon != null ? _iconToName(icon) : 'business_rounded'),
        accentColorHex = accentColorHex ?? (accentColor != null ? _colorToHex(accentColor) : '#FF4F46E5');

  IconData get icon => kCompanyIconMap[iconName] ?? Icons.business_rounded;
  Color get accentColor => _hexToColor(accentColorHex);

  factory CompanyItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CompanyItem(
      id: doc.id,
      name: data['name'] as String? ?? '',
      segment: data['segment'] as String? ?? '',
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'business_rounded',
      accentColorHex: data['accentColorHex'] as String? ?? '#FF4F46E5',
      adminEmail: data['adminEmail'] as String? ?? '',
      adminPassword: data['adminPassword'] as String? ?? '',
      adminName: data['adminName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'segment': segment,
      'description': description,
      'iconName': iconName,
      'accentColorHex': accentColorHex,
      'adminEmail': adminEmail,
      'adminName': adminName,
    };
  }

  CompanyItem copyWith({
    String? id,
    String? name,
    String? segment,
    String? description,
    String? iconName,
    IconData? icon,
    String? accentColorHex,
    Color? accentColor,
    String? adminEmail,
    String? adminPassword,
    String? adminName,
    List<DocumentItem>? documents,
  }) {
    return CompanyItem(
      id: id ?? this.id,
      name: name ?? this.name,
      segment: segment ?? this.segment,
      description: description ?? this.description,
      iconName: iconName ?? (icon != null ? _iconToName(icon) : this.iconName),
      accentColorHex: accentColorHex ?? (accentColor != null ? _colorToHex(accentColor) : this.accentColorHex),
      adminEmail: adminEmail ?? this.adminEmail,
      adminPassword: adminPassword ?? this.adminPassword,
      adminName: adminName ?? this.adminName,
      documents: documents ?? this.documents,
    );
  }
}
