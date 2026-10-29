import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/caregiver_agenda_provider.dart';
import '../../widgets/cuidarte_logo.dart';
import '../chat/messages_inbox_screen.dart';
import '../profile/edit_profile_screen.dart';
import 'caregiver_agenda_screen.dart';
import 'caregiver_clients_screen.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CaregiverAgendaProvider>().ensureLoaded();
      }
    });
  }

  Future<void> _openAgenda() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CaregiverAgendaScreen()),
    );
  }

  void _openEdit() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final stats = context.watch<CaregiverAgendaProvider>().stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const CuidArteLogo(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
                  child: Column(
                    children: [
                      _buildProfileHero(user),
                      _buildStats(stats),
                      _buildInfoGrid(user),
                      _buildQuickActions(),
                      _buildCompleteness(user),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = (width * 0.026).clamp(24.0, 33.6);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Text(
                  'Mi cuenta profesional',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestiona tu presentación como cuidador para generar confianza en los clientes',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 17.6,
                    color: Colors.white.withOpacity(0.94),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHero(UserModel? user) {
    final wide = MediaQuery.of(context).size.width > 700;
    final avatarSize = wide ? 118.0 : 92.0;
    final username = (user?.username ?? '').isNotEmpty
        ? user!.username
        : (user?.email ?? '').split('@').first;
    final specialty = user?.specialty ?? '';
    final verified = (user?.cedula ?? '').isNotEmpty;

    final avatar = Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        color: const Color(0xFFF3F4F6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
            ? Image.network(
                user.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarFallback(),
              )
            : _avatarFallback(),
      ),
    );

    final info = Column(
      crossAxisAlignment:
          wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          user?.name ?? 'Cuidador',
          textAlign: wide ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: wide ? 25.6 : 21.6,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@$username · ${(user?.email ?? '').isNotEmpty ? user!.email : 'Sin correo'}',
          textAlign: wide ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 15.2,
            color: const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _badge(
              specialty.isNotEmpty ? _truncate(specialty, 36) : 'Datos por completar',
              background: specialty.isNotEmpty
                  ? const Color(0xFFE0F2FE)
                  : const Color(0xFFFEF3C7),
              color: specialty.isNotEmpty
                  ? const Color(0xFF0369A1)
                  : const Color(0xFF92400E),
            ),
            if (verified)
              _badge(
                '✓ Verificado',
                background: const Color(0xFFDCFCE7),
                color: const Color(0xFF166534),
              ),
            if ((user?.city ?? '').isNotEmpty)
              _badge(
                '📍 ${user!.city}',
                background: const Color(0xFFF3F4F6),
                color: const Color(0xFF4B5563),
                weight: FontWeight.w400,
              ),
          ],
        ),
      ],
    );

    final edit = _gradientButton(text: 'Editar datos', onTap: _openEdit);

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: wide
          ? Row(
              children: [
                avatar,
                const SizedBox(width: 24),
                Expanded(child: info),
                const SizedBox(width: 16),
                edit,
              ],
            )
          : Column(
              children: [
                avatar,
                const SizedBox(height: 16),
                info,
                const SizedBox(height: 16),
                edit,
              ],
            ),
    );
  }

  Widget _avatarFallback() {
    return Image.asset(
      'assets/images/user1.png',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.person,
        size: 48,
        color: Color(0xFF9CA3AF),
      ),
    );
  }

  Widget _badge(
    String text, {
    required Color background,
    required Color color,
    FontWeight weight = FontWeight.w700,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12.48,
          fontWeight: weight,
          color: color,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildStats(dynamic stats) {
    final items = [
      ('${stats.solicitudes}', 'Solicitudes'),
      ('${stats.clientes}', 'Clientes'),
      ('${stats.visitas}', 'Visitas'),
      ('${stats.horarios}', 'Horarios'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ((width + 16) / (130 + 16)).floor().clamp(1, 4);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 84,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6EAF0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 30,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.$1,
                    style: GoogleFonts.poppins(
                      fontSize: 27.2,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF27BEF5),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    item.$2,
                    style: GoogleFonts.poppins(
                      fontSize: 13.44,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoGrid(UserModel? user) {
    final wide = MediaQuery.of(context).size.width > 700;
    final personal = _profileCard(
      title: 'Información personal',
      actionText: 'Editar →',
      onAction: _openEdit,
      child: _rows([
        ('Nombre completo', user?.name ?? '—'),
        ('Correo', (user?.email ?? '').isNotEmpty ? user!.email : 'No especificado'),
        ('📞 Teléfono', (user?.phone ?? '').isNotEmpty ? user!.phone : 'No especificado'),
        ('📍 Ciudad', (user?.city ?? '').isNotEmpty ? user!.city : 'No especificado'),
      ]),
    );

    final professional = _profileCard(
      title: 'Información profesional',
      dotColor: const Color(0xFF10B981),
      actionText: 'Editar →',
      onAction: _openEdit,
      child: Column(
        children: [
          _rows([
            ('🎓 Especialidad', (user?.specialty ?? '').isNotEmpty ? user!.specialty! : 'No especificado'),
            ('🆔 Cédula', (user?.cedula ?? '').isNotEmpty ? user!.cedula! : 'No especificado'),
          ]),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📝 Experiencia y descripción',
                  style: GoogleFonts.poppins(
                    fontSize: 14.08,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (user?.experience ?? '').isNotEmpty
                      ? user!.experience!
                      : 'Aún no has agregado una descripción. Cuéntale a los clientes sobre tu experiencia y enfoque de cuidado.',
                  style: GoogleFonts.poppins(
                    fontSize: 14.72,
                    height: 1.6,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: personal),
          const SizedBox(width: 24),
          Expanded(child: professional),
        ],
      );
    }
    return Column(
      children: [
        personal,
        const SizedBox(height: 24),
        professional,
      ],
    );
  }

  Widget _profileCard({
    required String title,
    Color dotColor = const Color(0xFF27BEF5),
    String? actionText,
    VoidCallback? onAction,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16.8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              if (actionText != null)
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0284C7),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionText,
                    style: GoogleFonts.poppins(
                      fontSize: 13.6,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _rows(List<(String, String)> rows) {
    return Column(
      children: rows
          .map(
            (row) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: GoogleFonts.poppins(
                        fontSize: 14.08,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      row.$2,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        fontSize: 14.72,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      ('Mi agenda', _openAgenda),
      ('Solicitudes', _openAgenda),
      (
        'Mis clientes',
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CaregiverClientsScreen(),
            ),
          );
        },
      ),
      (
        'Mensajes',
        () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const MessagesInboxScreen(),
            ),
          );
        },
      ),
      ('Cambiar contraseña', _openEdit),
    ];
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Accesos rápidos',
                style: GoogleFonts.poppins(
                  fontSize: 16.8,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: actions.map((action) {
              return Material(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  onTap: action.$2,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    child: Text(
                      action.$1,
                      style: GoogleFonts.poppins(
                        fontSize: 14.4,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteness(UserModel? user) {
    final completitud = user?.completitud ?? 0;
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFF27BEF5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Perfil completo',
                  style: GoogleFonts.poppins(
                    fontSize: 16.8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              _badge(
                '$completitud%',
                background: completitud >= 100
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEF3C7),
                color: completitud >= 100
                    ? const Color(0xFF166534)
                    : const Color(0xFF92400E),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completitud / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFEEF1F5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF27BEF5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (completitud >= 100)
            Text(
              '¡Excelente! Tu perfil está completo y listo para recibir clientes.',
              style: GoogleFonts.poppins(
                fontSize: 14.4,
                color: const Color(0xFF4B5563),
              ),
            )
          else
            Text.rich(
              TextSpan(
                text:
                    'Unos datos completos aparecen mejor en las búsquedas y generan más confianza. ',
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: _openEdit,
                      child: Text(
                        'Completar ahora →',
                        style: GoogleFonts.poppins(
                          fontSize: 14.4,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              style: GoogleFonts.poppins(
                fontSize: 14.4,
                color: const Color(0xFF4B5563),
              ),
            ),
        ],
      ),
    );
  }

  Widget _gradientButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27BEF5).withOpacity(0.30),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15.68,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE6EAF0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 30,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  String _truncate(String value, int max) {
    if (value.length <= max) return value;
    return '${value.substring(0, max - 1)}…';
  }
}
