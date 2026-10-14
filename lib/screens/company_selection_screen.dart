import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/company_item.dart';
import '../models/user_item.dart';
import '../theme/app_theme.dart';
import '../widgets/doc_vault_login_modal.dart';

class CompanySelectionScreen extends StatefulWidget {
  final List<CompanyItem> companies;
  final ValueChanged<CompanyItem> onSelectCompany;
  final List<UserItem>? users;
  final ValueChanged<UserItem>? onSuperAdminLogin;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleDarkMode;

  const CompanySelectionScreen({
    super.key,
    required this.companies,
    required this.onSelectCompany,
    this.users,
    this.onSuperAdminLogin,
    required this.isDarkMode,
    required this.onToggleDarkMode,
  });

  @override
  State<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
  String _searchQuery = '';
  bool _isSuperAdminLoginOpen = false;

  List<CompanyItem> get _filteredCompanies {
    final query = _searchQuery.toLowerCase().trim();
    if (query.isEmpty) return widget.companies;
    return widget.companies.where((company) {
      return company.name.toLowerCase().contains(query) ||
          company.segment.toLowerCase().contains(query) ||
          company.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final filtered = _filteredCompanies;

    return Scaffold(
      backgroundColor: isDark ? AppColors.stone950 : AppColors.stone50,
      body: Stack(
        children: [
          Column(
            children: [
              // Top Navigation Header
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.stone900 : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.stone700 : AppColors.stone200,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // DocVault Brand
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.indigo600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'DocVault',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: isDark ? AppColors.stone100 : AppColors.stone900,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.indigo950
                                    : AppColors.indigo500.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'PORTAL PÚBLICO',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.indigo400 : AppColors.indigo700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Right actions: Theme Toggle + Discreet Super Admin Login Trigger
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Theme Toggle Button
                            InkWell(
                              onTap: () => widget.onToggleDarkMode(!isDark),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.stone800 : AppColors.stone100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark ? AppColors.stone700 : AppColors.stone200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                      size: 16,
                                      color: isDark ? AppColors.stone300 : AppColors.stone700,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isDark ? 'Tema Claro' : 'Tema Escuro',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? AppColors.stone300 : AppColors.stone700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Discreet Super Admin Login trigger
                            const SizedBox(width: 8),
                            Tooltip(
                              message: 'Administração DocVault',
                              child: InkWell(
                                onTap: () => setState(() => _isSuperAdminLoginOpen = true),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.shield_outlined,
                                    size: 16,
                                    color: isDark ? AppColors.stone600 : AppColors.stone400,
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

          // Main Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      // Badge / Category
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.stone800
                              : AppColors.stone200.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.business_rounded,
                              size: 14,
                              color: isDark ? AppColors.stone300 : AppColors.stone600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SELEÇÃO DE EMPRESA',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                                color: isDark ? AppColors.stone300 : AppColors.stone600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Main Title
                      Text(
                        'Qual empresa você deseja consultar?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: isDark ? AppColors.stone100 : AppColors.stone900,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Text(
                          'Selecione uma das empresas abaixo para acessar livremente seu acervo de documentos, relatórios, atas e contratos públicos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.4,
                            color: isDark ? AppColors.stone400 : AppColors.stone600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Search bar for companies
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: SizedBox(
                          height: 42,
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            style: TextStyle(
                              fontSize: 13.5,
                              color: isDark ? AppColors.stone100 : AppColors.stone900,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Filtrar empresas por nome ou setor…',
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: isDark ? AppColors.stone400 : AppColors.stone400,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 16),
                                      splashRadius: 14,
                                      onPressed: () => setState(() => _searchQuery = ''),
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                              isDense: true,
                              filled: true,
                              fillColor: isDark ? AppColors.stone900 : Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.stone700 : AppColors.stone200,
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
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Company Cards List / Grid
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Column(
                            children: [
                              Icon(
                                Icons.domain_disabled_rounded,
                                size: 48,
                                color: isDark ? AppColors.stone700 : AppColors.stone400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhuma empresa encontrada',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.stone300 : AppColors.stone700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tente outro termo de busca.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? AppColors.stone500 : AppColors.stone400,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 720;
                            return Wrap(
                              spacing: 24,
                              runSpacing: 24,
                              alignment: WrapAlignment.center,
                              children: filtered.map((company) {
                                final cardWidth = isWide
                                    ? (constraints.maxWidth - 24) / 2
                                    : constraints.maxWidth;
                                return SizedBox(
                                  width: cardWidth.clamp(320.0, 520.0),
                                  child: _CompanyCard(
                                    company: company,
                                    isDarkMode: isDark,
                                    onTap: () => widget.onSelectCompany(company),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),

                      const SizedBox(height: 48),

                      // Helpful information footer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.stone900 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.stone800 : AppColors.stone200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: isDark ? AppColors.stone400 : AppColors.stone500,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Documentos públicos sem necessidade de cadastro. Administradores podem acessar o painel de edição após selecionar a empresa.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark ? AppColors.stone400 : AppColors.stone600,
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
            ),
          ),
        ],
      ),
      if (_isSuperAdminLoginOpen) ...[
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _isSuperAdminLoginOpen = false),
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ),
        Center(
          child: DocVaultLoginModal(
            users: widget.users ?? kMockUsers,
            onLoginSuccess: (user) {
              setState(() => _isSuperAdminLoginOpen = false);
              widget.onSuperAdminLogin?.call(user);
            },
            onClose: () => setState(() => _isSuperAdminLoginOpen = false),
            isDarkMode: isDark,
          ),
        ),
      ],
    ],
  ),
);
  }
}

class _CompanyCard extends StatefulWidget {
  final CompanyItem company;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _CompanyCard({
    required this.company,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  State<_CompanyCard> createState() => _CompanyCardState();
}

class _CompanyCardState extends State<_CompanyCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final company = widget.company;
    final isDark = widget.isDarkMode;

    final cardBg = isDark ? AppColors.stone900 : Colors.white;
    final borderColor = _isHovered
        ? company.accentColor
        : (isDark ? AppColors.stone700 : AppColors.stone200);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: _isHovered ? 1.8 : 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: company.accentColor.withValues(alpha: isDark ? 0.25 : 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Company Icon & Segment Tag
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: company.accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: company.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      company.icon,
                      color: company.accentColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.stone800 : AppColors.stone100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            company.segment.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: isDark ? AppColors.stone300 : AppColors.stone600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          company.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: _isHovered
                                ? company.accentColor
                                : (isDark ? AppColors.stone100 : AppColors.stone900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Description
              Text(
                company.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? AppColors.stone400 : AppColors.stone600,
                ),
              ),

              const SizedBox(height: 18),

              Divider(
                color: isDark ? AppColors.stone800 : AppColors.stone100,
                height: 1,
              ),

              const SizedBox(height: 16),

              // Bottom Row: Stats & Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Documents counter pill
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: isDark ? AppColors.stone400 : AppColors.stone500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${company.documents.length} documentos',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.stone300 : AppColors.stone700,
                        ),
                      ),
                    ],
                  ),

                  // Enter Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? company.accentColor
                          : (isDark ? AppColors.stone800 : AppColors.stone100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver documentos',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _isHovered
                                ? Colors.white
                                : (isDark ? AppColors.stone200 : AppColors.stone800),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: _isHovered
                              ? Colors.white
                              : (isDark ? AppColors.stone200 : AppColors.stone800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
