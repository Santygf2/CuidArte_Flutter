import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/network/admin_api.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import 'admin_module_config.dart';
import 'admin_widgets.dart';

class AdminFormScreen extends StatefulWidget {
  const AdminFormScreen({super.key, required this.config, this.item, this.api});

  final AdminModuleConfig config;
  final Map<String, dynamic>? item;
  final AdminApi? api;

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AdminApi _api;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _dropdownValues = {};
  final Map<String, bool> _booleanValues = {};
  final Map<String, DateTime?> _dateValues = {};
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? AdminApi();
    for (final field in widget.config.fields) {
      final value = _initialValue(field);
      switch (field.type) {
        case AdminFieldType.boolean:
          _booleanValues[field.key] = value == true;
          break;
        case AdminFieldType.dropdown:
          final text = (value ?? '').toString();
          _dropdownValues[field.key] =
              field.options.any((option) => option.value == text) ? text : null;
          break;
        case AdminFieldType.dateTime:
          final parsed = DateTime.tryParse((value ?? '').toString());
          _dateValues[field.key] = parsed;
          _controllers[field.key] = TextEditingController(
            text: parsed == null ? '' : _formatDateTime(parsed),
          );
          break;
        case AdminFieldType.number:
        case AdminFieldType.decimal:
          _controllers[field.key] = TextEditingController(
            text: _plainNumber(value),
          );
          break;
        case AdminFieldType.hidden:
          break;
        case AdminFieldType.text:
        case AdminFieldType.multiline:
          _controllers[field.key] = TextEditingController(
            text: (value ?? '').toString(),
          );
          break;
      }
    }
  }

  Object? _initialValue(AdminFieldConfig field) {
    final raw = widget.item?[field.key];
    if (raw != null) return raw;
    return field.defaultValue;
  }

  String _plainNumber(Object? value) {
    if (value == null) return '';
    if (value is int) return value.toString();
    if (value is num) {
      if (value == value.roundToDouble()) {
        return value.toInt().toString();
      }
      return value.toString();
    }
    return value.toString();
  }

  String _formatDateTime(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'p. m.' : 'a. m.';
    return '${date.day.toString().padLeft(2, '0')} de '
        '${months[date.month - 1]} de ${date.year}, $hour:$minute $suffix';
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDateTime(AdminFieldConfig field) async {
    final current = _dateValues[field.key] ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'Selecciona la fecha',
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
      helpText: 'Selecciona la hora',
    );
    if (time == null) return;
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      _dateValues[field.key] = selected;
      _controllers[field.key]?.text = _formatDateTime(selected);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final payload = <String, dynamic>{};
    for (final field in widget.config.fields) {
      switch (field.type) {
        case AdminFieldType.boolean:
          payload[field.key] = _booleanValues[field.key] ?? false;
          break;
        case AdminFieldType.dropdown:
          final value = _dropdownValues[field.key];
          if (value != null) payload[field.key] = value;
          break;
        case AdminFieldType.hidden:
          payload[field.key] = field.defaultValue;
          break;
        case AdminFieldType.dateTime:
          final value = _dateValues[field.key];
          if (value != null) payload[field.key] = value.toIso8601String();
          break;
        case AdminFieldType.number:
          final text = _controllers[field.key]?.text.trim() ?? '';
          if (text.isNotEmpty) payload[field.key] = int.parse(text);
          break;
        case AdminFieldType.decimal:
          final text = _controllers[field.key]?.text.trim() ?? '';
          if (text.isNotEmpty) payload[field.key] = double.parse(text);
          break;
        case AdminFieldType.text:
        case AdminFieldType.multiline:
          payload[field.key] = _controllers[field.key]?.text.trim() ?? '';
          break;
      }
    }

    try {
      if (_isEditing) {
        await _api.updateRecord(
          widget.config.endpoint,
          widget.config.idOf(widget.item!),
          payload,
        );
      } else {
        await _api.createRecord(widget.config.endpoint, payload);
      }
      if (!mounted) return;
      final action = _isEditing ? 'actualizado' : 'creado';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.config.entitySingular} $action exitosamente.',
          ),
          backgroundColor: AppColors.secondaryDark,
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(
        () => _error = 'No se pudo guardar el registro. Intenta de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final item = widget.item;
    if (item == null) return;
    final question = widget.config.deleteQuestion.isNotEmpty
        ? widget.config.deleteQuestion
        : '¿Eliminar este ${widget.config.entitySingular.toLowerCase()}?';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(question),
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

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _api.deleteRecord(widget.config.endpoint, widget.config.idOf(item));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.config.entitySingular} eliminado.'),
          backgroundColor: AppColors.secondaryDark,
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } catch (_) {
      setState(
        () => _error = 'No se pudo eliminar el registro. Intenta de nuevo.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        '${_isEditing ? 'Editar' : 'Crear'} ${widget.config.entitySingular}';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AdminPageHeader(title: title, subtitle: widget.config.formSubtitle),
            AdminBody(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, size: 17),
                    label: Text('Volver a ${widget.config.backLabel}'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: AdminCard(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_error != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.rejectedContainer,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.rejected.withOpacity(
                                        0.35,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _error!,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF991B1B),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              for (final field in widget.config.fields)
                                if (field.type != AdminFieldType.hidden)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildField(field),
                                  ),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 48,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.brandGradient,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: AppColors.elevatedShadow,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _saving ? null : _save,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: _saving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.3,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'Guardar ${widget.config.entitySingular}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              if (_isEditing && widget.config.canDelete) ...[
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _saving ? null : _delete,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.rejected,
                                  ),
                                  child: const Text('Eliminar registro'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(AdminFieldConfig field) {
    switch (field.type) {
      case AdminFieldType.boolean:
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: SwitchListTile.adaptive(
            value: _booleanValues[field.key] ?? false,
            onChanged: (value) =>
                setState(() => _booleanValues[field.key] = value),
            title: Text(
              field.label,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            activeColor: AppColors.primary,
          ),
        );
      case AdminFieldType.dropdown:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(field.label, field.required),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _dropdownValues[field.key],
              decoration: _decoration(field),
              items: [
                for (final option in field.options)
                  DropdownMenuItem(
                    value: option.value,
                    child: Text(option.label),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _dropdownValues[field.key] = value),
              validator: (value) {
                if (field.required && (value == null || value.isEmpty)) {
                  return 'Selecciona una opción';
                }
                return null;
              },
            ),
          ],
        );
      case AdminFieldType.dateTime:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(field.label, field.required),
            const SizedBox(height: 6),
            TextFormField(
              controller: _controllers[field.key],
              readOnly: true,
              onTap: () => _pickDateTime(field),
              decoration: _decoration(field).copyWith(
                suffixIcon: const Icon(Icons.calendar_month_outlined, size: 20),
              ),
              validator: (value) {
                if (field.required &&
                    (_dateValues[field.key] == null ||
                        (value ?? '').trim().isEmpty)) {
                  return 'Selecciona una fecha y hora';
                }
                return null;
              },
            ),
            if (field.helper != null) ...[
              const SizedBox(height: 5),
              Text(
                field.helper!,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        );
      case AdminFieldType.number:
      case AdminFieldType.decimal:
      case AdminFieldType.multiline:
      case AdminFieldType.text:
      case AdminFieldType.hidden:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(field.label, field.required),
            const SizedBox(height: 6),
            TextFormField(
              controller: _controllers[field.key],
              maxLines: field.type == AdminFieldType.multiline
                  ? field.maxLines
                  : 1,
              keyboardType:
                  field.type == AdminFieldType.number ||
                      field.type == AdminFieldType.decimal
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              decoration: _decoration(field),
              validator: (value) {
                final text = (value ?? '').trim();
                if (field.required && text.isEmpty) {
                  return 'Este campo es obligatorio';
                }
                if (text.isNotEmpty) {
                  if (field.type == AdminFieldType.number &&
                      int.tryParse(text) == null) {
                    return 'Ingresa un número entero';
                  }
                  if (field.type == AdminFieldType.decimal &&
                      double.tryParse(text) == null) {
                    return 'Ingresa un valor numérico';
                  }
                }
                return null;
              },
            ),
            if (field.helper != null) ...[
              const SizedBox(height: 5),
              Text(
                field.helper!,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        );
    }
  }

  Widget _label(String text, bool required) {
    return RichText(
      text: TextSpan(
        text: text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF374151),
        ),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: GoogleFonts.poppins(color: AppColors.rejected),
            ),
        ],
      ),
    );
  }

  InputDecoration _decoration(AdminFieldConfig field) {
    return InputDecoration(
      hintText: field.hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.rejected),
      ),
    );
  }
}
