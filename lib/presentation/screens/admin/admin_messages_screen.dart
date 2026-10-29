import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/network/admin_api.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/admin_models.dart';
import '../../widgets/error_retry.dart';
import 'admin_widgets.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key, this.api});

  final AdminApi? api;

  @override
  State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  late final AdminApi _api;
  List<AdminMessageItem> _messages = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? AdminApi();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final messages = await _api.messages();
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los mensajes. Intenta de nuevo.';
        _loading = false;
      });
    }
  }

  Future<void> _markRead(AdminMessageItem message) async {
    try {
      await _api.markMessageRead(message.id);
      if (!mounted) return;
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.rejected,
        ),
      );
    }
  }

  Future<void> _delete(AdminMessageItem message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Eliminar este mensaje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.rejected),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.deleteMessage(message.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mensaje eliminado.'),
          backgroundColor: AppColors.secondaryDark,
        ),
      );
      await _load();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.rejected,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mensajes de Contacto',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const AdminPageHeader(
                title: 'Mensajes de Contacto',
                subtitle:
                    'Mensajes enviados desde el formulario de Contáctanos',
              ),
              AdminBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_messages.length} mensaje(s) recibido(s)',
                      style: GoogleFonts.poppins(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 70),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_error != null)
                      ErrorRetry(message: _error!, onRetry: _load)
                    else if (_messages.isEmpty)
                      const AdminEmptyState(
                        message: 'No hay mensajes de contacto recibidos aún.',
                        icon: Icons.mail_outline_rounded,
                      )
                    else
                      for (final message in _messages)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMessage(message),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(AdminMessageItem message) {
    final date = DateFormat('dd/MM/yyyy hh:mm a').format(message.fecha);
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  message.fullName.isEmpty
                      ? '?'
                      : message.fullName[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: AppColors.info,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.fullName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        AdminBadge(
                          text: message.leido ? 'Leído' : 'No leído',
                          foreground: message.leido
                              ? const Color(0xFF166534)
                              : const Color(0xFF991B1B),
                          background: message.leido
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _info(Icons.mail_outline_rounded, message.correo),
                        if (message.telefono.isNotEmpty)
                          _info(Icons.phone_outlined, message.telefono),
                        if (message.ciudad.isNotEmpty)
                          _info(Icons.location_on_outlined, message.ciudad),
                        AdminBadge(
                          text: message.asuntoDisplay,
                          foreground: const Color(0xFF0369A1),
                          background: const Color(0xFFE0F2FE),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message.mensaje,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                if (!message.leido)
                  AdminActionChipButton(
                    label: 'Marcar leído',
                    icon: Icons.mark_email_read_outlined,
                    foreground: const Color(0xFF059669),
                    background: const Color(0xFFECFDF5),
                    onPressed: () => _markRead(message),
                  ),
                AdminActionChipButton(
                  label: 'Eliminar',
                  icon: Icons.delete_outline_rounded,
                  foreground: AppColors.rejected,
                  background: AppColors.rejectedContainer,
                  onPressed: () => _delete(message),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
