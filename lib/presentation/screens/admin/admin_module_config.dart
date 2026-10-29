import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';

enum AdminFieldType {
  text,
  multiline,
  number,
  decimal,
  boolean,
  dropdown,
  dateTime,
  hidden,
}

class AdminOption {
  const AdminOption(this.value, this.label);

  final String value;
  final String label;
}

class AdminFieldConfig {
  const AdminFieldConfig({
    required this.key,
    required this.label,
    this.type = AdminFieldType.text,
    this.required = false,
    this.options = const <AdminOption>[],
    this.hint,
    this.helper,
    this.maxLines = 1,
    this.defaultValue,
  });

  final String key;
  final String label;
  final AdminFieldType type;
  final bool required;
  final List<AdminOption> options;
  final String? hint;
  final String? helper;
  final int maxLines;
  final Object? defaultValue;
}

class AdminChipData {
  const AdminChipData(this.text, {this.foreground, this.background});

  final String text;
  final Color? foreground;
  final Color? background;
}

class AdminModuleConfig {
  const AdminModuleConfig({
    required this.title,
    required this.subtitle,
    required this.endpoint,
    required this.icon,
    required this.accent,
    required this.entitySingular,
    required this.addLabel,
    required this.emptyMessage,
    required this.searchHint,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.chipsBuilder,
    required this.fields,
    this.query,
    this.backLabel = 'Panel',
    this.formSubtitle = 'Completa la información solicitada',
    this.canCreate = true,
    this.canEdit = true,
    this.canDelete = true,
    this.canManageSessions = false,
    this.searchKeys = const <String>['titulo', 'descripcion'],
    this.countLabel,
    this.deleteQuestion = '',
  });

  final String title;
  final String subtitle;
  final String endpoint;
  final IconData icon;
  final Color accent;
  final String entitySingular;
  final String addLabel;
  final String emptyMessage;
  final String searchHint;
  final String Function(Map<String, dynamic> item) titleBuilder;
  final String Function(Map<String, dynamic> item) subtitleBuilder;
  final List<AdminChipData> Function(Map<String, dynamic> item) chipsBuilder;
  final List<AdminFieldConfig> fields;
  final String? query;
  final String backLabel;
  final String formSubtitle;
  final bool canCreate;
  final bool canEdit;
  final bool canDelete;
  final bool canManageSessions;
  final List<String> searchKeys;
  final String Function(int count)? countLabel;
  final String deleteQuestion;

  int idOf(Map<String, dynamic> item) => (item['id'] as num?)?.toInt() ?? 0;

  String countText(int count) =>
      countLabel?.call(count) ?? '$count registro(s)';
}

String _money(dynamic value) {
  final amount = value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;
  return Formatters.formatCurrency(amount);
}

String _dateTime(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  return date == null ? '' : Formatters.formatDateTime(date);
}

AdminChipData _activeChip(dynamic value) {
  final active = value == true;
  return AdminChipData(
    active ? 'Activo' : 'Inactivo',
    foreground: active ? const Color(0xFF166534) : const Color(0xFF991B1B),
    background: active ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
  );
}

AdminModuleConfig servicesModule() {
  return AdminModuleConfig(
    title: 'Lista de Servicios',
    subtitle: 'Gestiona los servicios de cuidado ofrecidos en la plataforma',
    endpoint: '/admin/services/',
    icon: Icons.medical_services_outlined,
    accent: const Color(0xFFD97706),
    entitySingular: 'Servicio',
    addLabel: '+ Nuevo Servicio',
    emptyMessage: 'No hay servicios registrados aún. Crea el primero con el botón "+ Nuevo Servicio".',
    searchHint: 'Buscar servicios...',
    backLabel: 'Servicios',
    formSubtitle: 'Completa la información del servicio',
    fields: const [
      AdminFieldConfig(
        key: 'titulo',
        label: 'Título',
        required: true,
        hint: 'Ej. Cuidado nocturno',
      ),
      AdminFieldConfig(
        key: 'descripcion',
        label: 'Descripción',
        type: AdminFieldType.multiline,
        required: true,
        maxLines: 4,
      ),
      AdminFieldConfig(
        key: 'precio',
        label: 'Precio',
        type: AdminFieldType.decimal,
        required: true,
        defaultValue: 0,
      ),
      AdminFieldConfig(key: 'duracion', label: 'Duración', hint: 'Ej. 8 horas'),
      AdminFieldConfig(
        key: 'activo',
        label: 'Activo',
        type: AdminFieldType.boolean,
        defaultValue: true,
      ),
    ],
    titleBuilder: (item) => (item['titulo'] ?? 'Servicio').toString(),
    subtitleBuilder: (item) => (item['descripcion'] ?? '').toString(),
    chipsBuilder: (item) => [
      AdminChipData(_money(item['precio'])),
      if ((item['duracion'] ?? '').toString().isNotEmpty)
        AdminChipData((item['duracion'] ?? '').toString()),
      _activeChip(item['activo']),
    ],
    countLabel: (count) => '$count servicio(s) registrado(s)',
    deleteQuestion: '¿Eliminar este servicio?',
  );
}

AdminModuleConfig productsModule() {
  return AdminModuleConfig(
    title: 'Lista de Productos',
    subtitle: 'Administra el catálogo y el stock de la tienda',
    endpoint: '/admin/products/',
    icon: Icons.storefront_outlined,
    accent: const Color(0xFF7C3AED),
    entitySingular: 'Producto',
    addLabel: '+ Nuevo Producto',
    emptyMessage: 'No hay productos registrados aún. Crea el primero con el botón "+ Nuevo Producto".',
    searchHint: 'Buscar productos...',
    backLabel: 'Productos',
    formSubtitle: 'Completa la información del producto',
    fields: const [
      AdminFieldConfig(
        key: 'titulo',
        label: 'Título',
        required: true,
        hint: 'Ej. Tensiómetro digital',
      ),
      AdminFieldConfig(
        key: 'descripcion',
        label: 'Descripción',
        type: AdminFieldType.multiline,
        required: true,
        maxLines: 4,
      ),
      AdminFieldConfig(
        key: 'precio',
        label: 'Precio',
        type: AdminFieldType.decimal,
        required: true,
        defaultValue: 0,
      ),
      AdminFieldConfig(
        key: 'categoria',
        label: 'Categoría',
        type: AdminFieldType.dropdown,
        required: true,
        defaultValue: 'otros',
        options: [
          AdminOption('biomedicos', 'Dispositivos Biomédicos'),
          AdminOption('suministros', 'Suministros Médicos'),
          AdminOption('movilidad', 'Movilidad y Ortopedia'),
          AdminOption('cuidado', 'Cuidado Personal'),
          AdminOption('otros', 'Otros'),
        ],
      ),
      AdminFieldConfig(
        key: 'stock',
        label: 'Stock',
        type: AdminFieldType.number,
        required: true,
        defaultValue: 0,
      ),
      AdminFieldConfig(
        key: 'activo',
        label: 'Activo',
        type: AdminFieldType.boolean,
        defaultValue: true,
      ),
    ],
    titleBuilder: (item) => (item['titulo'] ?? 'Producto').toString(),
    subtitleBuilder: (item) => (item['descripcion'] ?? '').toString(),
    chipsBuilder: (item) => [
      AdminChipData(
        (item['categoria_display'] ?? item['categoria'] ?? '').toString(),
      ),
      AdminChipData(_money(item['precio'])),
      AdminChipData('Stock: ${item['stock'] ?? 0}'),
      _activeChip(item['activo']),
    ],
    countLabel: (count) => '$count producto(s) en catálogo',
    deleteQuestion: '¿Eliminar este producto?',
  );
}

AdminModuleConfig specialtiesModule() {
  return AdminModuleConfig(
    title: 'Lista de Especialidades',
    subtitle: 'Administra las especialidades mostradas en la página principal',
    endpoint: '/admin/specialties/',
    icon: Icons.auto_awesome_outlined,
    accent: const Color(0xFF0369A1),
    entitySingular: 'Especialidad',
    addLabel: '+ Nueva Especialidad',
    emptyMessage: 'No hay especialidades registradas aún.',
    searchHint: 'Buscar especialidades...',
    backLabel: 'Especialidades',
    formSubtitle: 'Completa la información de la especialidad',
    fields: const [
      AdminFieldConfig(key: 'titulo', label: 'Título', required: true),
      AdminFieldConfig(
        key: 'descripcion',
        label: 'Descripción',
        type: AdminFieldType.multiline,
        required: true,
        maxLines: 4,
      ),
      AdminFieldConfig(
        key: 'activo',
        label: 'Activo',
        type: AdminFieldType.boolean,
        defaultValue: true,
      ),
    ],
    titleBuilder: (item) => (item['titulo'] ?? 'Especialidad').toString(),
    subtitleBuilder: (item) => (item['descripcion'] ?? '').toString(),
    chipsBuilder: (item) => [_activeChip(item['activo'])],
    countLabel: (count) => '$count especialidad(es)',
    deleteQuestion: '¿Eliminar esta especialidad?',
  );
}

AdminModuleConfig workshopsModule() {
  return AdminModuleConfig(
    title: 'Lista de Talleres',
    subtitle:
        'Gestiona el calendario de actividades y talleres de la plataforma',
    endpoint: '/admin/workshops/',
    icon: Icons.event_available_outlined,
    accent: const Color(0xFF9333EA),
    entitySingular: 'Taller',
    addLabel: '+ Nuevo Taller',
    emptyMessage: 'No hay talleres registrados aún. Crea el primero con el botón "+ Nuevo Taller".',
    searchHint: 'Buscar talleres...',
    backLabel: 'Talleres',
    formSubtitle: 'Completa la información del taller',
    canManageSessions: true,
    fields: const [
      AdminFieldConfig(
        key: 'titulo',
        label: 'Título del Taller',
        required: true,
      ),
      AdminFieldConfig(
        key: 'descripcion',
        label: 'Descripción',
        type: AdminFieldType.multiline,
        required: true,
        maxLines: 4,
      ),
      AdminFieldConfig(
        key: 'ubicacion',
        label: 'Ubicación o Modalidad',
        required: true,
        defaultValue: 'Virtual (en línea)',
      ),
      AdminFieldConfig(
        key: 'activo',
        label: 'Activo',
        type: AdminFieldType.boolean,
        defaultValue: true,
      ),
    ],
    titleBuilder: (item) => (item['titulo'] ?? 'Taller').toString(),
    subtitleBuilder: (item) => (item['descripcion'] ?? '').toString(),
    chipsBuilder: (item) => [
      if ((item['ubicacion'] ?? '').toString().isNotEmpty)
        AdminChipData((item['ubicacion'] ?? '').toString()),
      AdminChipData('${item['num_sesiones'] ?? 0} sesión(es)'),
      AdminChipData('${item['num_inscritos'] ?? 0} inscrito(s)'),
      _activeChip(item['activo']),
    ],
    countLabel: (count) => '$count taller(es) registrado(s)',
    deleteQuestion: '¿Eliminar este taller? Se eliminarán también sus fechas e inscripciones.',
  );
}

AdminModuleConfig resourcesModule() {
  return AdminModuleConfig(
    title: 'Lista de Recursos',
    subtitle: 'Gestiona las guías y documentos descargables de la plataforma',
    endpoint: '/admin/resources/',
    icon: Icons.menu_book_outlined,
    accent: const Color(0xFF0284C7),
    entitySingular: 'Recurso',
    addLabel: '+ Nuevo Recurso',
    emptyMessage: 'No hay recursos registrados aún. Crea el primero con el botón "+ Nuevo Recurso".',
    searchHint: 'Buscar recursos...',
    backLabel: 'Recursos',
    formSubtitle: 'Completa la información del recurso',
    fields: const [
      AdminFieldConfig(key: 'titulo', label: 'Título', required: true),
      AdminFieldConfig(
        key: 'descripcion',
        label: 'Descripción corta',
        type: AdminFieldType.multiline,
        required: true,
        maxLines: 3,
      ),
      AdminFieldConfig(
        key: 'contenido',
        label: 'Contenido de la guía (HTML)',
        type: AdminFieldType.multiline,
        maxLines: 8,
        hint: '<p>Contenido de la guía...</p>',
      ),
      AdminFieldConfig(
        key: 'categoria',
        label: 'Categoría',
        type: AdminFieldType.dropdown,
        required: true,
        defaultValue: 'profesional',
        options: [
          AdminOption('profesional', 'Cuidado Profesional'),
          AdminOption('cuerpo', 'Cuerpo del Adulto Mayor'),
          AdminOption('ejercicio', 'Ejercicio y Salud Física'),
          AdminOption('emocional', 'Salud Emocional y Cognitiva'),
          AdminOption('otros', 'Otros Recursos'),
        ],
      ),
    ],
    titleBuilder: (item) => (item['titulo'] ?? 'Recurso').toString(),
    subtitleBuilder: (item) => (item['descripcion'] ?? '').toString(),
    chipsBuilder: (item) => [
      AdminChipData(
        (item['categoria_display'] ?? item['categoria'] ?? '').toString(),
      ),
    ],
    searchKeys: const ['titulo', 'descripcion', 'categoria_display'],
    countLabel: (count) => '$count recurso(s) registrado(s)',
    deleteQuestion: '¿Eliminar este recurso?',
  );
}

AdminModuleConfig sessionsModule({
  required int tallerId,
  required String tallerTitle,
  required String tallerLocation,
}) {
  final location = tallerLocation.trim().isEmpty ? '' : ' · $tallerLocation';
  return AdminModuleConfig(
    title: 'Fechas y horarios',
    subtitle: 'Taller: $tallerTitle$location',
    endpoint: '/admin/workshop-sessions/',
    query: 'taller=$tallerId',
    icon: Icons.calendar_month_outlined,
    accent: const Color(0xFF0284C7),
    entitySingular: 'Sesión',
    addLabel: '+ Agregar Fecha',
    emptyMessage: 'Este taller aún no tiene fechas programadas. Agrégala con el botón "+ Agregar Fecha".',
    searchHint: 'Buscar sesiones...',
    backLabel: 'Talleres',
    formSubtitle:
        'Solo se permiten fechas desde el día y hora actual en adelante.',
    fields: [
      AdminFieldConfig(
        key: 'taller',
        label: 'Taller',
        type: AdminFieldType.hidden,
        defaultValue: tallerId,
      ),
      const AdminFieldConfig(
        key: 'fecha',
        label: 'Fecha y hora de la sesión',
        type: AdminFieldType.dateTime,
        required: true,
      ),
      const AdminFieldConfig(
        key: 'cupos',
        label: 'Cupos de la sesión',
        type: AdminFieldType.number,
        required: true,
        defaultValue: 20,
      ),
    ],
    titleBuilder: (item) => _dateTime(item['fecha']),
    subtitleBuilder: (item) =>
        '${item['ocupados'] ?? 0}/${item['cupos'] ?? 0} inscritos',
    chipsBuilder: (item) => [
      AdminChipData('${item['ocupados'] ?? 0}/${item['cupos'] ?? 0} inscritos'),
    ],
    searchKeys: const ['fecha'],
    countLabel: (count) => '$count sesión(es) programada(s)',
    deleteQuestion:
        '¿Eliminar esta fecha? Se eliminarán también sus inscripciones.',
  );
}

AdminChipData orderStatusChip(String status) {
  switch (status) {
    case 'confirmado':
      return const AdminChipData(
        'Confirmado',
        foreground: Color(0xFF075985),
        background: Color(0xFFE0F2FE),
      );
    case 'enviado':
      return const AdminChipData(
        'Enviado',
        foreground: Color(0xFF92400E),
        background: Color(0xFFFEF3C7),
      );
    case 'entregado':
      return const AdminChipData(
        'Entregado',
        foreground: Color(0xFF166534),
        background: Color(0xFFDCFCE7),
      );
    default:
      return const AdminChipData(
        'Pendiente',
        foreground: Color(0xFF991B1B),
        background: Color(0xFFFEE2E2),
      );
  }
}
