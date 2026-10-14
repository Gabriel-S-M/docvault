import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_item.dart';
import '../theme/app_theme.dart';

class DocVaultLoginModal extends StatefulWidget {
  final List<UserItem> users;
  final ValueChanged<UserItem> onLoginSuccess;
  final VoidCallback onClose;
  final bool isDarkMode;

  const DocVaultLoginModal({
    super.key,
    required this.users,
    required this.onLoginSuccess,
    required this.onClose,
    required this.isDarkMode,
  });

  @override
  State<DocVaultLoginModal> createState() => _DocVaultLoginModalState();
}

class _DocVaultLoginModalState extends State<DocVaultLoginModal> {
  final _emailController = TextEditingController(text: 'admin@docvault.com');
  final _passwordController = TextEditingController(text: 'docvault123');
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha o e-mail e a senha.';
      });
      return;
    }

    final matchedUser = widget.users.cast<UserItem?>().firstWhere(
          (u) =>
              u != null &&
              u.email.toLowerCase() == email.toLowerCase() &&
              u.password == pass &&
              u.isSuperAdmin,
          orElse: () => null,
        );

    if (matchedUser != null) {
      setState(() => _errorMessage = null);
      widget.onLoginSuccess(matchedUser);
    } else {
      setState(() {
        _errorMessage =
            'Credenciais inválidas ou usuário não possui acesso Super Admin.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? AppColors.stone900 : Colors.white;
    final borderColor = isDark ? AppColors.stone700 : AppColors.stone200;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.18),
                blurRadius: 32,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.indigo600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Acesso DocVault Admin',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.stone100 : AppColors.stone900,
                                    ),
                                  ),
                                  Text(
                                    'Gestão global de empresas e equipe',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isDark ? AppColors.stone400 : AppColors.stone500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close_rounded, size: 20),
                        splashRadius: 18,
                        color: isDark ? AppColors.stone400 : AppColors.stone600,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Demo credentials badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.indigo950.withValues(alpha: 0.6)
                          : AppColors.indigo500.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? AppColors.indigo800.withValues(alpha: 0.6)
                            : AppColors.indigo500.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: isDark ? AppColors.indigo400 : AppColors.indigo700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dica de teste: admin@docvault.com / docvault123',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              color: isDark ? AppColors.indigo400 : AppColors.indigo700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email
                  Text(
                    'E-mail institucional',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.stone300 : AppColors.stone700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? AppColors.stone100 : AppColors.stone900,
                    ),
                    decoration: InputDecoration(
                      hintText: 'admin@docvault.com',
                      prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18),
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Password
                  Text(
                    'Senha de acesso',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.stone300 : AppColors.stone700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? AppColors.stone100 : AppColors.stone900,
                    ),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                        ),
                        splashRadius: 16,
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onClose,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: isDark ? AppColors.stone700 : AppColors.stone300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.stone300 : AppColors.stone700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.indigo600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Entrar no Admin',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
