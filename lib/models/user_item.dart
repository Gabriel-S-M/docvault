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
    required this.password,
    required this.role,
    this.companyId,
  });

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

/// Usuários iniciais mockados do sistema
final List<UserItem> kMockUsers = [
  // Super Admin do DocVault
  const UserItem(
    id: 'user-superadmin-1',
    name: 'Super Admin DocVault',
    email: 'admin@docvault.com',
    password: 'docvault123',
    role: UserRole.superAdmin,
  ),

  // AlphaTech: Super Gerente e Gerente
  const UserItem(
    id: 'user-alpha-super-1',
    name: 'Super Gerente AlphaTech',
    email: 'super@alphatech.com',
    password: 'alpha123',
    role: UserRole.superGerente,
    companyId: 'alphatech',
  ),
  const UserItem(
    id: 'user-alpha-gerente-1',
    name: 'Admin AlphaTech',
    email: 'admin@alphatech.com',
    password: 'alpha123',
    role: UserRole.gerente,
    companyId: 'alphatech',
  ),

  // LogiPrime: Super Gerente e Gerente
  const UserItem(
    id: 'user-logi-super-1',
    name: 'Super Gerente LogiPrime',
    email: 'super@logiprime.com',
    password: 'logi123',
    role: UserRole.superGerente,
    companyId: 'logiprime',
  ),
  const UserItem(
    id: 'user-logi-gerente-1',
    name: 'Admin LogiPrime',
    email: 'admin@logiprime.com',
    password: 'logi123',
    role: UserRole.gerente,
    companyId: 'logiprime',
  ),
];
