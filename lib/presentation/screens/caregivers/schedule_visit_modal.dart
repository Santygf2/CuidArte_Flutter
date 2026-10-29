import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:cuidarte_app/core/network/api_client.dart';
import 'package:cuidarte_app/core/theme/app_colors.dart';
import 'package:cuidarte_app/models/availability_model.dart';
import 'package:cuidarte_app/models/caregiver_model.dart';
import 'package:cuidarte_app/providers/client_dashboard_provider.dart';
import 'package:cuidarte_app/providers/visit_provider.dart';
import 'package:cuidarte_app/presentation/screens/profile/my_visits_screen.dart';

class ScheduleVisitModal extends StatefulWidget {
  final CaregiverModel caregiver;

  const ScheduleVisitModal({super.key, required this.caregiver});

  @override
  State<ScheduleVisitModal> createState() => _ScheduleVisitModalState();
}

class _ScheduleVisitModalState extends State<ScheduleVisitModal> {
  final _notesController = TextEditingController();
  AvailabilityModel? _availability;
  DateTime? _selectedDate;
  VisitSlot? _selectedSlot;
  bool _isLoadingAvailability = true;
  bool _isSubmitting = false;
  String? _availabilityError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadAvailability();
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailability({DateTime? date}) async {
    setState(() {
      _isLoadingAvailability = true;
      _availabilityError = null;
    });
    try {
      final data = await context
          .read<VisitProvider>()
          .fetchAvailability(widget.caregiver.id, date: date);
      if (!mounted) return;
      setState(() {
        _availability = data;
        _selectedDate = data.selectedDate ??
            (data.dates.isNotEmpty ? data.dates.first : null);
        _selectedSlot = data.slots.isNotEmpty ? data.slots.first : null;
        _isLoadingAvailability = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _availabilityError = error.message;
        _isLoadingAvailability = false;
      });
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _pickDate() async {
    final dates = _availability?.dates ?? const <DateTime>[];
    if (dates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este cuidador aún no tiene fechas disponibles.'),
        ),
      );
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? dates.first,
      firstDate: dates.first,
      lastDate: dates.last,
      selectableDayPredicate: (day) =>
          dates.any((available) => _sameDay(available, day)),
      helpText: 'Elige otra fecha',
      cancelText: 'Cancelar',
      confirmText: 'Consultar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF27BEF5),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      await _loadAvailability(date: picked);
    }
  }

  Future<void> _confirmVisit() async {
    final date = _selectedDate;
    final slot = _selectedSlot;
    if (date == null || slot == null) return;

    setState(() => _isSubmitting = true);
    try {
      await context.read<VisitProvider>().scheduleVisit(
            caregiverId: widget.caregiver.id,
            date: date,
            time: slot.start,
            notes: _notesController.text.trim(),
          );
      if (!mounted) return;
      context.read<ClientDashboardProvider>().load();
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text(
            '¡Solicitud de visita enviada! Te avisaremos cuando el cuidador responda.',
          ),
        ),
      );
      navigator.push(
        MaterialPageRoute(builder: (_) => const MyVisitsScreen()),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.rejected,
          content: Text(
            error.fieldError('time') ??
                error.fieldError('date') ??
                error.fieldError('caregiver') ??
                error.message,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = _availability?.dates ?? const <DateTime>[];
    final slots = _availability?.slots ?? const <VisitSlot>[];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 16),
              _buildCalendarCard(dates),
              if (_selectedDate != null) ...[
                const SizedBox(height: 18),
                _buildHoursCard(slots),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final avatar = widget.caregiver.avatarUrl;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFE0F2FE),
          backgroundImage:
              avatar.isNotEmpty ? NetworkImage(avatar) : null,
          child: avatar.isEmpty
              ? const Icon(Icons.person, color: Color(0xFF27BEF5))
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agendar visita gratis',
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                'Elige un día y una hora disponible de ${widget.caregiver.name}',
                style: GoogleFonts.poppins(
                  fontSize: 13.6,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(List<DateTime> dates) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 Calendario disponible',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Estos son los próximos días en los que ${widget.caregiver.name.split(' ').first} trabaja. Toca uno para ver sus horas libres.',
            style: GoogleFonts.poppins(
              fontSize: 14.08,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          if (_isLoadingAvailability)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_availabilityError != null)
            _messageBox(
              text: _availabilityError!,
              background: const Color(0xFFFEE2E2),
              border: const Color(0xFFFECACA),
              color: const Color(0xFF991B1B),
            )
          else if (dates.isEmpty)
            _messageBox(
              text:
                  'Este cuidador aún no ha publicado horarios disponibles. Vuelve a intentarlo más tarde o contáctalo por chat.',
              background: const Color(0xFFFEF3C7),
              border: const Color(0xFFFDE68A),
              color: const Color(0xFF92400E),
            )
          else ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: dates.map((date) {
                final selected =
                    _selectedDate != null && _sameDay(date, _selectedDate!);
                return _dateChip(date, selected);
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _pickDate,
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: Color(0xFF0369A1),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              label: Text(
                'O elige otra fecha',
                style: GoogleFonts.poppins(
                  fontSize: 13.6,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0369A1),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateChip(DateTime date, bool selected) {
    final dateLabel = DateFormat('d MMM', 'es').format(date);
    final weekday = DateFormat('EEEE', 'es').format(date);
    final weekdayCapitalized = weekday.isEmpty
        ? weekday
        : '${weekday[0].toUpperCase()}${weekday.substring(1)}';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: selected ? null : const Color(0xFFF0F9FF),
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFE0F2FE),
          ),
        ),
        child: InkWell(
          onTap: () => _loadAvailability(date: date),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minWidth: 86),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            child: Column(
              children: [
                Text(
                  dateLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 15.2,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : const Color(0xFF0369A1),
                  ),
                ),
                Text(
                  weekdayCapitalized,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: selected
                        ? Colors.white.withOpacity(0.85)
                        : const Color(0xFF0369A1).withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoursCard(List<VisitSlot> slots) {
    final date = _selectedDate!;
    final weekday = DateFormat('EEEE', 'es').format(date);
    final weekdayCapitalized = weekday.isEmpty
        ? weekday
        : '${weekday[0].toUpperCase()}${weekday.substring(1)}';
    final dateLabel =
        '$weekdayCapitalized ${DateFormat('d', 'es').format(date)} de ${DateFormat('MMMM', 'es').format(date)} de ${DateFormat('y', 'es').format(date)}';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horas disponibles — $dateLabel',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cada visita dura 1 hora.',
            style: GoogleFonts.poppins(
              fontSize: 14.08,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          if (_isLoadingAvailability)
            const Center(child: CircularProgressIndicator())
          else if (slots.isEmpty)
            _messageBox(
              text:
                  'No hay horas disponibles este día (están todas ocupadas o bloqueadas). Prueba con otra fecha.',
              background: const Color(0xFFFEE2E2),
              border: const Color(0xFFFECACA),
              color: const Color(0xFF991B1B),
            )
          else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = (constraints.maxWidth / 130).floor().clamp(1, 4);
                final itemWidth =
                    (constraints.maxWidth - (columns - 1) * 10) / columns;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: slots.map((slot) {
                    final selected =
                        _selectedSlot?.start == slot.start;
                    return SizedBox(
                      width: itemWidth,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFE0F2FE),
                              width: 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: () =>
                                setState(() => _selectedSlot = slot),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 10,
                              ),
                              child: Text(
                                slot.label,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.4,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? const Color(0xFF065F46)
                                      : const Color(0xFF0369A1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Mensaje para el cuidador (opcional)',
              style: GoogleFonts.poppins(
                fontSize: 14.4,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              maxLength: 300,
              style: GoogleFonts.poppins(fontSize: 14.72),
              decoration: InputDecoration(
                hintText: 'Cuéntale brevemente qué necesitas...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14.72,
                  color: const Color(0xFF9CA3AF),
                ),
                filled: true,
                fillColor: Colors.white,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF27BEF5)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _isSubmitting || _selectedSlot == null
                      ? null
                      : _confirmVisit,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Solicitar visita gratis',
                              style: GoogleFonts.poppins(
                                fontSize: 15.2,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'El cuidador recibirá una notificación y podrá aceptar o rechazar tu solicitud.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.12,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _messageBox({
    required String text,
    required Color background,
    required Color border,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 13.6, color: color),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
