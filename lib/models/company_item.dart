import 'package:flutter/material.dart';
import 'document_item.dart';

class CompanyItem {
  final String id;
  final String name;
  final String segment;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String adminEmail;
  final String adminPassword;
  final String adminName;
  final List<DocumentItem> documents;

  const CompanyItem({
    required this.id,
    required this.name,
    required this.segment,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.adminEmail,
    required this.adminPassword,
    required this.adminName,
    required this.documents,
  });

  CompanyItem copyWith({
    String? id,
    String? name,
    String? segment,
    String? description,
    IconData? icon,
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
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
      adminEmail: adminEmail ?? this.adminEmail,
      adminPassword: adminPassword ?? this.adminPassword,
      adminName: adminName ?? this.adminName,
      documents: documents ?? this.documents,
    );
  }
}

/// Lista inicial de empresas mockadas com os PDFs distribuídos
final List<CompanyItem> kMockCompanies = [
  CompanyItem(
    id: 'alphatech',
    name: 'AlphaTech Soluções Digitais',
    segment: 'Tecnologia & Software',
    description:
        'Líder em desenvolvimento de plataformas em nuvem, inteligência de dados e segurança da informação.',
    icon: Icons.code_rounded,
    accentColor: const Color(0xFF4F46E5), // Indigo
    adminEmail: 'admin@alphatech.com',
    adminPassword: 'alpha123',
    adminName: 'Admin AlphaTech',
    documents: [
      kMockDocuments[0], // Relatório Anual 2024
      kMockDocuments[2], // Proposta Comercial — Q1 2025
      kMockDocuments[5], // Política de Privacidade v3.1
      kMockDocuments[6], // Plano de Marketing Digital 2025
    ],
  ),
  CompanyItem(
    id: 'logiprime',
    name: 'LogiPrime Logística & Operações',
    segment: 'Logística & Supply Chain',
    description:
        'Especializada em cadeia de suprimentos inteligente, gestão de frotas e operações de distribuição internacional.',
    icon: Icons.local_shipping_rounded,
    accentColor: const Color(0xFF0D9488), // Teal
    adminEmail: 'admin@logiprime.com',
    adminPassword: 'logi123',
    adminName: 'Admin LogiPrime',
    documents: [
      kMockDocuments[1], // Manual de Procedimentos Internos
      kMockDocuments[3], // Contrato de Prestação de Serviços
      kMockDocuments[4], // Ata da Reunião — Fevereiro 2025
      kMockDocuments[7], // Manual de Identidade Visual
    ],
  ),
];
