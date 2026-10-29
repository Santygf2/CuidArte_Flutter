import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/cuidarte_header.dart';
import '../auth/login_screen.dart';
import 'public_home_screen.dart';
import 'contactanos_screen.dart';
import 'sobre_nosotros_screen.dart';
import 'servicios_screen.dart';
import 'tienda_public_screen.dart';

class PublicMainWrapper extends StatefulWidget {
  final int initialTab;

  const PublicMainWrapper({super.key, this.initialTab = 0});

  @override
  State<PublicMainWrapper> createState() => _PublicMainWrapperState();
}

class _PublicMainWrapperState extends State<PublicMainWrapper> {
  late int _activeTabIndex;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() => _activeTabIndex = index);
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      PublicHomeScreen(
        onNavigateTab: _onTabSelected,
        onLoginPressed: _navigateToLogin,
      ),
      ContactanosScreen(
        onNavigateTab: _onTabSelected,
      ),
      SobreNosotrosScreen(
        onNavigateTab: _onTabSelected,
      ),
      ServiciosScreen(
        onNavigateTab: _onTabSelected,
        onLoginPressed: _navigateToLogin,
      ),
      TiendaPublicScreen(
        onNavigateTab: _onTabSelected,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: CuidArteHeader(
        activeIndex: _activeTabIndex,
        onTabSelected: _onTabSelected,
        onLoginPressed: _navigateToLogin,
      ),
      endDrawer: _buildMobileDrawer(),
      body: IndexedStack(
        index: _activeTabIndex,
        children: screens,
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                    width: 40,
                    errorBuilder: (_, __, ___) => const Icon(Icons.favorite, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 12),
                  ShaderMask(
                    shaderCallback: (bounds) => AppColors.brandGradient.createShader(bounds),
                    child: Text(
                      'CuidArte',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Drawer Items
            _buildDrawerTile('Inicio', 0, Icons.home_outlined),
            _buildDrawerTile('Contáctanos', 1, Icons.contact_support_outlined),
            _buildDrawerTile('Sobre Nosotros', 2, Icons.info_outline_rounded),
            _buildDrawerTile('Servicios', 3, Icons.medical_services_outlined),
            _buildDrawerTile('Tienda', 4, Icons.storefront_outlined),

            const Spacer(),
            const Divider(height: 1),

            // Login Button in Drawer
            Padding(
              padding: const EdgeInsets.all(24),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _navigateToLogin();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Ingresar',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(String label, int index, IconData icon) {
    final bool isSelected = _activeTabIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : const Color(0xFF1F2937),
        ),
      ),
      trailing: isSelected
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: () {
        Navigator.of(context).pop();
        _onTabSelected(index);
      },
    );
  }
}
