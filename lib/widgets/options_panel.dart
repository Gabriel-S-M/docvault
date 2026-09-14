import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/document_item.dart';
import '../theme/app_theme.dart';

class OptionsPanel extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;
  final SortKey currentSortKey;
  final ValueChanged<SortKey> onSortKeyChanged;
  final ViewMode currentViewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final bool isLoggedIn;
  final VoidCallback onLogin;
  final VoidCallback onLogout;
  final VoidCallback onClose;

  const OptionsPanel({
    super.key,
    required this.isDarkMode,
    required this.onToggleDarkMode,
    required this.currentSortKey,
    required this.onSortKeyChanged,
    required this.currentViewMode,
    required this.onViewModeChanged,
    required this.isLoggedIn,
    required this.onLogin,
    required this.onLogout,
    required this.onClose,
  });

  @override
  State<OptionsPanel> createState() => _OptionsPanelState();
}

class _OptionsPanelState extends State<OptionsPanel> {
  final _emailController = TextEditingController(text: 'teste@teste.com');
  final _passwordController = TextEditingController(text: '12345');
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

    if (email == 'teste@teste.com' && pass == '12345') {
      setState(() => _errorMessage = null);
      widget.onLogin();
      widget.onClose();
    } else if (email.isNotEmpty && pass.isNotEmpty) {
      // In testing mode, also accept or show note
      setState(() => _errorMessage = null);
      widget.onLogin();
      widget.onClose();
    } else {
      setState(() {
        _errorMessage = 'Preencha e-mail e senha (teste@teste.com / 12345)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final cardBg = isDark ? AppColors.stone900 : Colors.white;
    final borderColor = isDark ? AppColors.stone700 : AppColors.stone200;
    final dividerColor = isDark ? AppColors.stone700 : AppColors.stone100;

    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: CONTA / LOGIN ADMIN
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CONTA / ADMIN',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppColors.stone400,
                      ),
                    ),
                    if (!widget.isLoggedIn)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.indigo500.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Teste',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.indigo600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (widget.isLoggedIn)
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.indigo700,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Teste',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.stone100 : AppColors.stone900,
                              ),
                            ),
                            Text(
                              'Administrador',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.stone400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onLogout();
                          widget.onClose();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Sair',
                          style: TextStyle(fontSize: 12, color: Colors.redAccent),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _emailController,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.stone100 : AppColors.stone900,
                          ),
                          decoration: InputDecoration(
                            hintText: 'E-mail (teste@teste.com)',
                            filled: true,
                            fillColor: isDark ? AppColors.stone800 : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.stone600 : AppColors.stone200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.indigo600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.stone100 : AppColors.stone900,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Senha (12345)',
                            filled: true,
                            fillColor: isDark ? AppColors.stone800 : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            isDense: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark ? AppColors.stone600 : AppColors.stone200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.indigo600),
                            ),
                          ),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 10.5, color: Colors.redAccent),
                        ),
                      ],
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 34,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.indigo700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Entrar no Painel Admin',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          Divider(color: dividerColor, height: 1),

          // Section 2: APARÊNCIA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'APARÊNCIA',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.stone400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.dark_mode_outlined,
                          size: 16,
                          color: isDark ? AppColors.stone300 : AppColors.stone500,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Modo escuro',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.stone200 : AppColors.stone800,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: widget.isDarkMode,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.indigo600,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: isDark ? AppColors.stone700 : AppColors.stone300,
                      onChanged: widget.onToggleDarkMode,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(color: dividerColor, height: 1),

          // Section 3: VISUALIZAÇÃO (Sort options)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VISUALIZAÇÃO',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.stone400,
                  ),
                ),
                const SizedBox(height: 6),
                ...SortKey.values.map((sortKey) {
                  final isSelected = widget.currentSortKey == sortKey;
                  return InkWell(
                    onTap: () {
                      widget.onSortKeyChanged(sortKey);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sortKey.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? (isDark ? AppColors.indigo400 : AppColors.indigo700)
                                  : (isDark ? AppColors.stone300 : AppColors.stone700),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: isDark ? AppColors.indigo400 : AppColors.indigo700,
                            )
                          else
                            Text(
                              '→',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.stone400,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          Divider(color: dividerColor, height: 1),

          // Section 4: EXIBIÇÃO (Grid / List)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXIBIÇÃO',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: AppColors.stone400,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildViewModeButton(
                        label: 'Grade',
                        icon: Icons.grid_view_rounded,
                        mode: ViewMode.grid,
                        isSelected: widget.currentViewMode == ViewMode.grid,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildViewModeButton(
                        label: 'Lista',
                        icon: Icons.view_list_rounded,
                        mode: ViewMode.list,
                        isSelected: widget.currentViewMode == ViewMode.list,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton({
    required String label,
    required IconData icon,
    required ViewMode mode,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => widget.onViewModeChanged(mode),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.indigo950 : AppColors.stone100)
              : (isDark ? AppColors.stone800 : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.indigo600
                : (isDark ? AppColors.stone700 : AppColors.stone200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? (isDark ? AppColors.indigo400 : AppColors.indigo700)
                  : (isDark ? AppColors.stone400 : AppColors.stone600),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.indigo400 : AppColors.indigo700)
                    : (isDark ? AppColors.stone400 : AppColors.stone600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
