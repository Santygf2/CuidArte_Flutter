import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../models/visit_model.dart';
import '../../../providers/caregiver_agenda_provider.dart';
import '../../widgets/cuidarte_logo.dart';
import '../../widgets/error_retry.dart';

class CaregiverClientsScreen extends StatefulWidget {
  const CaregiverClientsScreen({super.key});

  @override
  State<CaregiverClientsScreen> createState() => _CaregiverClientsScreenState();
}

class _CaregiverClientsScreenState extends State<CaregiverClientsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CaregiverAgendaProvider>().ensureLoaded();
      }
    });
  }

  List<VisitModel> _clients(CaregiverAgendaProvider provider) {
    final agenda = provider.agenda;
    if (agenda == null) return const [];
    final seen = <String>{};
    final clients = <VisitModel>[];
    for (final visit in [...agenda.upcoming, ...agenda.history]) {
      if (!visit.status.toLowerCase().contains('aceptad')) continue;
      if (seen.add(visit.clientId)) {
        clients.add(visit);
      }
    }
    clients.sort((a, b) => a.clientName.compareTo(b.clientName));
    return clients;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CaregiverAgendaProvider>();
    final clients = _clients(provider);
    final agenda = provider.agenda;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const CuidArteLogo()),
      body: RefreshIndicator(
        onRefresh: provider.load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHero(context),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 60,
                    ),
                    child: provider.isLoading && agenda == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : provider.errorMessage != null && agenda == null
                        ? ErrorRetry(
                            message: provider.errorMessage!,
                            onRetry: provider.load,
                          )
                        : clients.isEmpty
                        ? _buildEmpty()
                        : _buildList(clients),
                  ),
                ),
              ),
            ],
          ),
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
                  'Clientes',
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
                  'Estos son los clientes a los que has aceptado cuidar.',
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

  Widget _buildList(List<VisitModel> clients) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ((width + 20) / (280 + 20)).floor().clamp(1, 4);
        final itemWidth = (width - (columns - 1) * 20) / columns;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${clients.length} cliente${clients.length == 1 ? '' : 's'}',
              style: GoogleFonts.poppins(
                fontSize: 14.4,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: clients.map((client) {
                return SizedBox(width: itemWidth, child: _clientCard(client));
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _clientCard(VisitModel client) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(client),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  client.clientName,
                  style: GoogleFonts.poppins(
                    fontSize: 16.8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _info(
            'Edad',
            client.clientAge != null
                ? '${client.clientAge} años'
                : 'No especificada',
          ),
          _info(
            'Correo',
            client.clientEmail.isNotEmpty ? client.clientEmail : '—',
          ),
          _info(
            'Teléfono',
            client.clientPhone.isNotEmpty
                ? client.clientPhone
                : 'No especificado',
          ),
          _info(
            'Ciudad',
            client.clientAddress.isNotEmpty
                ? client.clientAddress
                : 'No especificado',
          ),
        ],
      ),
    );
  }

  Widget _avatar(VisitModel client) {
    if (client.clientAvatar.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          client.clientAvatar,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _avatarFallback(client.clientName),
        ),
      );
    }
    return _avatarFallback(client.clientName);
  }

  Widget _avatarFallback(String name) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'C',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text.rich(
        TextSpan(
          text: '$label: ',
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        style: GoogleFonts.poppins(
          fontSize: 14.4,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2937),
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Aún no tienes clientes',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los clientes aparecerán aquí cuando aceptes cuidarlos desde tu apartado de solicitudes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.4,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
