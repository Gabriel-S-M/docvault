import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  superAdmin('Super Admin DocVault'),
  superGerente('Super Gerente'),
  gerente('Gerente');

  final String label;
  const UserRole(this.label);
}

class UserItem {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? companyId;

  const UserItem({
    required this.id,
    required this.name,
    required this.email,
    this.password = '',
    required this.role,
    this.companyId,
  });

  factory UserItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final roleStr = data['role'] as String? ?? '';
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.gerente,
    );
    return UserItem(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: role,
      companyId: data['companyId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      if (companyId != null) 'companyId': companyId,
    };
  }

  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isSuperGerente => role == UserRole.superGerente;
  bool get isGerente => role == UserRole.gerente;

  UserItem copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? companyId,
  }) {
    return UserItem(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
    );
  }
}
