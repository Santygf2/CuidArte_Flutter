import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/caregiver_agenda_model.dart';
import '../../../models/visit_model.dart';
import '../../../providers/caregiver_agenda_provider.dart';
import '../../../providers/visit_provider.dart';
import '../../widgets/cuidarte_logo.dart';
import '../../widgets/error_retry.dart';

class CaregiverAgendaScreen extends StatefulWidget {
  const CaregiverAgendaScreen({super.key});

  @override
  State<CaregiverAgendaScreen> createState() => _CaregiverAgendaScreenState();
}

class _CaregiverAgendaScreenState extends State<CaregiverAgendaScreen> {
  DateTime? _scheduleDate;
  TimeOfDay? _scheduleStart;
  TimeOfDay? _scheduleEnd;
  DateTime? _blockDate;
  TimeOfDay? _blockTime;
  bool _savingSchedule = false;
  bool _savingBlock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CaregiverAgendaProvider>().ensureLoaded();
      }
    });
  }

  Future<void> _reload() async {
    await context.read<CaregiverAgendaProvider>().load();
  }

  Future<void> _pickDate({required bool block}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: block ? (_blockDate ?? now) : (_scheduleDate ?? now),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      helpText: block ? 'Fecha a bloquear' : 'Fecha de trabajo',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() {
        if (block) {
          _blockDate = picked;
        } else {
          _scheduleDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime({required bool block, bool end = false}) async {
    final initial = block
        ? (_blockTime ?? const TimeOfDay(hour: 9, minute: 0))
        : end
            ? (_scheduleEnd ?? const TimeOfDay(hour: 17, minute: 0))
            : (_scheduleStart ?? const TimeOfDay(hour: 8, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: block
          ? 'Hora a bloquear'
          : end
              ? 'Hora de fin'
              : 'Hora de inicio',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      setState(() {
        if (block) {
          _blockTime = picked;
        } else if (end) {
          _scheduleEnd = picked;
        } else {
          _scheduleStart = picked;
        }
      });
    }
  }

  Future<void> _addSchedule() async {
    if (_scheduleDate == null ||
        _scheduleStart == null ||
        _scheduleEnd == null) {
      _snack('Selecciona la fecha, la hora de inicio y la hora de fin.');
      return;
    }
    final start = _formatTime(_scheduleStart!);
    final end = _formatTime(_scheduleEnd!);
    if (start.compareTo(end) >= 0) {
      _snack('La hora de inicio debe ser menor a la hora de fin.');
      return;
    }
    setState(() => _savingSchedule = true);
    try {
      await context.read<CaregiverAgendaProvider>().addSchedule(
            date: _scheduleDate!,
            start: start,
            end: end,
          );
      if (!mounted) return;
      setState(() {
        _scheduleDate = null;
        _scheduleStart = null;
        _scheduleEnd = null;
      });
      _snack('Horario agregado correctamente.', success: true);
    } on ApiException catch (error) {
      _snack(error.message, error: true);
    } finally {
      if (mounted) setState(() => _savingSchedule = false);
    }
  }

  Future<void> _addBlock() async {
    if (_blockDate == null || _blockTime == null) {
      _snack('Selecciona la fecha y la hora que deseas bloquear.');
      return;
    }
    setState(() => _savingBlock = true);
    try {
      final block = await context.read<CaregiverAgendaProvider>().addBlock(
            date: _blockDate!,
            hour: _formatTime(_blockTime!),
          );
      if (!mounted) return;
      setState(() {
        _blockDate = null;
        _blockTime = null;
      });
      _snack(
        block.isAppointment
            ? 'Esa hora ya está ocupada por una cita aceptada.'
            : 'Hora bloqueada correctamente.',
        success: !block.isAppointment,
      );
    } on ApiException catch (error) {
      _snack(error.message, error: true);
    } finally {
      if (mounted) setState(() => _savingBlock = false);
    }
  }

  Future<void> _deleteSchedule(CaregiverScheduleModel schedule) async {
    try {
      await context
          .read<CaregiverAgendaProvider>()
          .deleteSchedule(schedule.id);
      _snack('Horario eliminado.', success: true);
    } on ApiException catch (error) {
      _snack(error.message, error: true);
    }
  }

  Future<void> _deleteBlock(CaregiverBlockModel block) async {
    try {
      await context.read<CaregiverAgendaProvider>().deleteBlock(block.id);
      _snack('Hora desbloqueada.', success: true);
    } on ApiException catch (error) {
      _snack(error.message, error: true);
    }
  }

  Future<void> _acceptVisit(VisitModel visit) async {
    final visits = context.read<VisitProvider>();
    final agenda = context.read<CaregiverAgendaProvider>();
    try {
      await visits.acceptVisit(visit.id);
      await agenda.load();
      await visits.loadMyVisits();
      _snack('Visita aceptada. La hora quedó bloqueada.', success: true);
    } on ApiException catch (error) {
      _snack(error.message, error: true);
    }
  }

  Future<void> _rejectVisit(VisitModel visit, String reason) async {
    if (reason.trim().length < 5) {
      _snack('El motivo debe tener al menos 5 caracteres.', error: true);
      return;
    }
    final visits = context.read<VisitProvider>();
    final agenda = context.read<CaregiverAgendaProvider>();
    try {
      await visits.rejectVisit(visit.id, reason.trim());
      await agenda.load();
      await visits.loadMyVisits();
      _snack('Solicitud rechazada y cliente notificado.', success: true);
    } on ApiException catch (error) {
      _snack(error.message, error: true);
    }
  }

  void _snack(String message, {bool success = false, bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error
            ? AppColors.rejected
            : success
                ? AppColors.secondary
                : null,
        content: Text(message),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CaregiverAgendaProvider>();
    final agenda = provider.agenda;
    final stats = provider.stats;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const CuidArteLogo(),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
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
                    child: Column(
                      children: [
                        if (provider.errorMessage != null &&
                            agenda == null)
                          ErrorRetry(
                            message: provider.errorMessage!,
                            onRetry: provider.load,
                          )
                        else ...[
                          _buildStats(stats),
                          if (agenda?.nextVisit != null)
                            _buildNextVisit(agenda!.nextVisit!),
                          _buildPendingPanel(agenda),
                          _buildForms(context, provider, agenda),
                          _buildUpcomingAndHistory(agenda),
                        ],
                      ],
                    ),
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
                  'AGENDA DEL CUIDADOR',
                  style: GoogleFonts.poppins(
                    fontSize: 11.52,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.38,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mi agenda',
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
                  'Organiza tus horarios, bloquea horas y responde solicitudes de visita.',
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

  Widget _buildStats(CaregiverAgendaStats stats) {
    final items = [
      ('Solicitudes pendientes', '${stats.pendientes}', 'Requieren tu respuesta'),
      ('Próximas visitas', '${stats.proximas}', 'Confirmadas en tu agenda'),
      ('Horarios definidos', '${stats.horarios}', 'Días con disponibilidad'),
      ('Horas bloqueadas', '${stats.bloqueos}', 'Manuales y por visitas'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ((width + 14) / (180 + 14)).floor().clamp(1, 4);
        final itemWidth = (width - (columns - 1) * 14) / columns;
        return Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            children: items.map((item) {
              return SizedBox(
                width: itemWidth,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: GoogleFonts.poppins(
                          fontSize: 12.16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        item.$2,
                        style: GoogleFonts.poppins(
                          fontSize: 31.2,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                      Text(
                        item.$3,
                        style: GoogleFonts.poppins(
                          fontSize: 11.84,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildNextVisit(VisitModel visit) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECFDF5), Colors.white],
          stops: [0, 0.7],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _avatar(visit.clientName, size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRÓXIMA VISITA',
                  style: GoogleFonts.poppins(
                    fontSize: 10.88,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: const Color(0xFF047857),
                  ),
                ),
                Text(
                  visit.clientName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${DateFormat("EEEE, d 'de' MMMM", 'es').format(visit.date)} · ${visit.timeSlot}',
                  style: GoogleFonts.poppins(
                    fontSize: 13.12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _badge('Confirmada', success: true),
        ],
      ),
    );
  }

  Widget _buildPendingPanel(CaregiverAgendaModel? agenda) {
    final pending = agenda?.pending ?? const <VisitModel>[];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(24),
      decoration: _panelDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Solicitudes de visita',
                  style: GoogleFonts.poppins(
                    fontSize: 16.8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${pending.length} pendiente${pending.length == 1 ? '' : 's'}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Al aceptar una solicitud, la hora se bloquea automáticamente en tu agenda.',
              style: GoogleFonts.poppins(
                fontSize: 13.6,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (pending.isEmpty)
            _agendaEmpty(
              icon: Icons.check_circle_outline_rounded,
              title: 'Sin solicitudes pendientes',
              text:
                  'Cuando un cliente solicite una visita, aparecerá aquí para que la confirmes.',
            )
          else
            ...pending.map(
              (visit) => _PendingVisitCard(
                visit: visit,
                onAccept: () => _acceptVisit(visit),
                onReject: (reason) => _rejectVisit(visit, reason),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForms(
    BuildContext context,
    CaregiverAgendaProvider provider,
    CaregiverAgendaModel? agenda,
  ) {
    final schedules = agenda?.schedules ?? const <CaregiverScheduleModel>[];
    final blocks = agenda?.blocks ?? const <CaregiverBlockModel>[];

    final schedulesPanel = Container(
      padding: const EdgeInsets.all(24),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelTitle('Mis horarios de trabajo'),
          const SizedBox(height: 8),
          Text(
            'Define de qué hora a qué hora trabajas cada día.',
            style: GoogleFonts.poppins(
              fontSize: 13.6,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          _dateField(
            label: 'Fecha',
            date: _scheduleDate,
            onTap: () => _pickDate(block: false),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _timeField(
                  label: 'Desde',
                  time: _scheduleStart,
                  onTap: () => _pickTime(block: false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _timeField(
                  label: 'Hasta',
                  time: _scheduleEnd,
                  onTap: () => _pickTime(block: false, end: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _fullGradientButton(
            text: 'Agregar horario',
            loading: _savingSchedule,
            onTap: _savingSchedule ? null : _addSchedule,
          ),
          const SizedBox(height: 16),
          if (schedules.isEmpty)
            Text(
              'Aún no has definido horarios.',
              style: GoogleFonts.poppins(
                fontSize: 13.6,
                color: const Color(0xFF94A3B8),
              ),
            )
          else
            ...schedules.map((schedule) => _scheduleRow(schedule)),
        ],
      ),
    );

    final blocksPanel = Container(
      padding: const EdgeInsets.all(24),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Horas bloqueadas',
                  style: GoogleFonts.poppins(
                    fontSize: 16.8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Bloquea horas que no puedes atender. Las citas aceptadas se bloquean solas.',
            style: GoogleFonts.poppins(
              fontSize: 13.6,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _dateField(
                  label: 'Fecha',
                  date: _blockDate,
                  onTap: () => _pickDate(block: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _timeField(
                  label: 'Hora',
                  time: _blockTime,
                  onTap: () => _pickTime(block: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _fullGradientButton(
            text: 'Bloquear hora',
            loading: _savingBlock,
            onTap: _savingBlock ? null : _addBlock,
            colors: const [Color(0xFFEF4444), Color(0xFFF87171)],
          ),
          const SizedBox(height: 16),
          if (blocks.isEmpty)
            Text(
              'No tienes horas bloqueadas.',
              style: GoogleFonts.poppins(
                fontSize: 13.6,
                color: const Color(0xFF94A3B8),
              ),
            )
          else
            ...blocks.map((block) => _blockRow(block)),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 820) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: schedulesPanel),
                const SizedBox(width: 24),
                Expanded(child: blocksPanel),
              ],
            );
          }
          return Column(
            children: [
              schedulesPanel,
              const SizedBox(height: 24),
              blocksPanel,
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpcomingAndHistory(CaregiverAgendaModel? agenda) {
    final upcoming = agenda?.upcoming ?? const <VisitModel>[];
    final history = agenda?.history ?? const <VisitModel>[];

    final upcomingPanel = Container(
      padding: const EdgeInsets.all(24),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelTitle(
            'Próximas visitas',
            color: const Color(0xFF10B981),
            trailing:
                '${upcoming.length} confirmada${upcoming.length == 1 ? '' : 's'}',
          ),
          const SizedBox(height: 8),
          Text(
            'Estas horas ya están ocupadas automáticamente.',
            style: GoogleFonts.poppins(
              fontSize: 13.6,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          if (upcoming.isEmpty)
            _agendaEmpty(
              title: 'No tienes visitas agendadas',
              text: 'Las visitas que aceptes aparecerán en esta sección.',
            )
          else
            ...upcoming.map((visit) => _visitRow(visit, success: true)),
        ],
      ),
    );

    final historyPanel = Container(
      padding: const EdgeInsets.all(24),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelTitle(
            'Historial de solicitudes',
            color: const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 14),
          if (history.isEmpty)
            _agendaEmpty(
              title: 'Sin historial todavía',
              text: 'Aquí verás las solicitudes que ya respondiste.',
            )
          else
            ...history.map((visit) => _visitRow(visit)),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 820) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: upcomingPanel),
              const SizedBox(width: 24),
              Expanded(child: historyPanel),
            ],
          );
        }
        return Column(
          children: [
            upcomingPanel,
            const SizedBox(height: 24),
            historyPanel,
          ],
        );
      },
    );
  }

  Widget _panelTitle(
    String title, {
    Color color = const Color(0xFF27BEF5),
    String? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailing,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
      ],
    );
  }

  Widget _scheduleRow(CaregiverScheduleModel schedule) {
    final month = DateFormat('MMM', 'es').format(schedule.date);
    final weekday = DateFormat('EEEE', 'es').format(schedule.date);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Row(
        children: [
          _dateBox(schedule.date, month),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule.start} — ${schedule.end}',
                  style: GoogleFonts.poppins(
                    fontSize: 14.08,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  weekday,
                  style: GoogleFonts.poppins(
                    fontSize: 12.48,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _dangerMiniButton(
            text: 'Eliminar',
            onTap: () => _deleteSchedule(schedule),
          ),
        ],
      ),
    );
  }

  Widget _blockRow(CaregiverBlockModel block) {
    final month = DateFormat('MMM', 'es').format(block.date);
    final isAppointment = block.isAppointment;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isAppointment
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAppointment
              ? const Color(0xFFFDE68A)
              : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        children: [
          _dateBox(block.date, month),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.hour,
                  style: GoogleFonts.poppins(
                    fontSize: 14.08,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  isAppointment
                      ? 'Ocupado por cita aceptada'
                      : 'Bloqueada por ti',
                  style: GoogleFonts.poppins(
                    fontSize: 12.48,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (isAppointment)
            _badge('Cita', warning: true)
          else
            _dangerMiniButton(
              text: 'Desbloquear',
              onTap: () => _deleteBlock(block),
            ),
        ],
      ),
    );
  }

  Widget _visitRow(VisitModel visit, {bool success = false}) {
    final rejected = visit.status.toLowerCase().contains('rechazada');
    final label = rejected ? 'Rechazada' : 'Confirmada';
    final meta = visit.rejectionReason.isNotEmpty
        ? '${DateFormat('dd/MM/yyyy', 'es').format(visit.date)} · ${visit.timeSlot} · ${visit.rejectionReason}'
        : '${DateFormat('dd/MM/yyyy', 'es').format(visit.date)} · ${visit.timeSlot}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: success && !rejected
            ? const Color(0xFFF0FDF4)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: success && !rejected
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFE6EAF0),
        ),
      ),
      child: Row(
        children: [
          _avatar(visit.clientName, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.clientName,
                  style: GoogleFonts.poppins(
                    fontSize: 14.08,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  meta,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.48,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _badge(
            label,
            success: !rejected,
            danger: rejected,
          ),
        ],
      ),
    );
  }

  Widget _dateBox(DateTime date, String month) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('d', 'es').format(date),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0369A1),
              height: 1,
            ),
          ),
          Text(
            month.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 9.6,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0369A1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String name, {double size = 44}) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'C';
    return Container(
      width: size,
      height: size,
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
        initial,
        style: GoogleFonts.poppins(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _badge(
    String text, {
    bool success = false,
    bool danger = false,
    bool warning = false,
  }) {
    final background = success
        ? const Color(0xFFDCFCE7)
        : danger
            ? const Color(0xFFFEE2E2)
            : warning
                ? const Color(0xFFFEF3C7)
                : const Color(0xFFF1F5F9);
    final color = success
        ? const Color(0xFF166534)
        : danger
            ? const Color(0xFF991B1B)
            : warning
                ? const Color(0xFF92400E)
                : const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12.48,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.6,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('dd/MM/yyyy', 'es').format(date)
                        : 'Seleccionar fecha',
                    style: GoogleFonts.poppins(
                      fontSize: 14.72,
                      color: date != null
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.6,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    time != null ? _formatTime(time) : 'Seleccionar',
                    style: GoogleFonts.poppins(
                      fontSize: 14.72,
                      color: time != null
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _fullGradientButton({
    required String text,
    required bool loading,
    VoidCallback? onTap,
    List<Color> colors = const [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            alignment: Alignment.center,
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 14.08,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _dangerMiniButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12.16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFDC2626),
            ),
          ),
        ),
      ),
    );
  }

  Widget _agendaEmpty({
    IconData? icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF059669), size: 24),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14.72,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _panelDecoration() {
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
}

class _PendingVisitCard extends StatefulWidget {
  final VisitModel visit;
  final Future<void> Function() onAccept;
  final Future<void> Function(String reason) onReject;

  const _PendingVisitCard({
    required this.visit,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<_PendingVisitCard> createState() => _PendingVisitCardState();
}

class _PendingVisitCardState extends State<_PendingVisitCard> {
  final _reason = TextEditingController();
  bool _accepting = false;
  bool _rejecting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    setState(() => _accepting = true);
    try {
      await widget.onAccept();
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _rejecting = true);
    try {
      await widget.onReject(_reason.text.trim());
    } finally {
      if (mounted) setState(() => _rejecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visit = widget.visit;
    final weekday = DateFormat('EEE, d MMM y', 'es').format(visit.date);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Colors.white],
          stops: [0, 0.75],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFFDE68A)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFE0F2FE),
                child: Text(
                  visit.clientName.isNotEmpty
                      ? visit.clientName[0].toUpperCase()
                      : 'C',
                  style: GoogleFonts.poppins(
                    fontSize: 15.2,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0369A1),
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.clientName,
                      style: GoogleFonts.poppins(
                        fontSize: 15.04,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Solicitud de visita',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
              _badge('Pendiente', warning: true),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFEF3C7)),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 4,
              children: [
                Text(
                  weekday,
                  style: GoogleFonts.poppins(
                    fontSize: 13.12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF92400E),
                  ),
                ),
                Text(
                  visit.timeSlot,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF92400E),
                  ),
                ),
                Text(
                  '1 hora',
                  style: GoogleFonts.poppins(
                    fontSize: 13.12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
          if (visit.message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF3F4F6)),
              ),
              child: Text(
                visit.message,
                style: GoogleFonts.poppins(
                  fontSize: 13.92,
                  height: 1.5,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 520;
              final acceptButton = Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _accepting ? null : _accept,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Center(
                        child: _accepting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Aceptar visita',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.08,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );
              final rejectForm = Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _reason,
                      style: GoogleFonts.poppins(fontSize: 13.12),
                      decoration: InputDecoration(
                        hintText: 'Motivo del rechazo',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13.12,
                          color: const Color(0xFF9CA3AF),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(
                            color: Color(0xFFFECACA),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(
                            color: Color(0xFFFECACA),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(
                            color: Color(0xFFF87171),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: _rejecting ? null : _reject,
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        child: _rejecting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFB91C1C),
                                ),
                              )
                            : Text(
                                'Rechazar',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB91C1C),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              );
              if (wide) {
                return Row(
                  children: [
                    acceptButton,
                    const SizedBox(width: 10),
                    Expanded(child: rejectForm),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  acceptButton,
                  const SizedBox(height: 10),
                  rejectForm,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, {bool success = false, bool warning = false}) {
    final background = success
        ? const Color(0xFFDCFCE7)
        : warning
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFF1F5F9);
    final color = success
        ? const Color(0xFF166534)
        : warning
            ? const Color(0xFF92400E)
            : const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12.48,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
