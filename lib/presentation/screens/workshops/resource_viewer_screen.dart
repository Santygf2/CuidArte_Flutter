import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/url_opener.dart';
import '../../../models/educational_resource_model.dart';

class ResourceViewerScreen extends StatelessWidget {
  final EducationalResourceModel resource;

  const ResourceViewerScreen({super.key, required this.resource});

  Future<void> _download(BuildContext context) async {
    if (resource.downloadUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta guía se puede leer directamente en la aplicación.',
          ),
        ),
      );
      return;
    }
    final abierto = await openExternalUrl(resource.downloadUrl);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        content: Text(
          abierto
              ? 'Abriendo el PDF de la guía...'
              : 'Enlace de descarga copiado al portapapeles.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final generatedDate = DateFormat(
      'dd/MM/yyyy',
      'es',
    ).format(resource.createdAt ?? DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Recurso y Guía'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => _download(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(generatedDate),
                        const SizedBox(height: 18),
                        _buildTitleBox(),
                        const SizedBox(height: 18),
                        _buildContent(),
                        const SizedBox(height: 18),
                        _buildNotice(),
                        const SizedBox(height: 22),
                        _buildFooter(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDownloadButton(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String generatedDate) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 520;
        final brand = Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          decoration: const BoxDecoration(
            color: Color(0xFF27BEF5),
            border: Border(
              left: BorderSide(color: Color(0xFFFF6B9D), width: 6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CuidArte',
                style: GoogleFonts.poppins(
                  fontSize: 29.3,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'BIBLIOTECA DE RECURSOS Y GUÍAS PROFESIONALES',
                style: GoogleFonts.poppins(
                  fontSize: 11.3,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: const Color(0xFFE6F9FF),
                ),
              ),
            ],
          ),
        );

        final meta = Column(
          crossAxisAlignment: wide
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              color: const Color(0xFF1F2937),
              child: Text(
                'GUÍA DESCARGABLE',
                style: GoogleFonts.poppins(
                  fontSize: 9.3,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generada el $generatedDate',
              style: GoogleFonts.poppins(
                fontSize: 10.7,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        );

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 62, child: brand),
              const SizedBox(width: 16),
              Expanded(flex: 38, child: meta),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [brand, const SizedBox(height: 14), meta],
        );
      },
    );
  }

  Widget _buildTitleBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F9FF),
        border: Border(
          left: BorderSide(color: Color(0xFF27BEF5), width: 6),
          top: BorderSide(color: Color(0xFFBAE6FD), width: 1.5),
          right: BorderSide(color: Color(0xFFBAE6FD), width: 1.5),
          bottom: BorderSide(color: Color(0xFFBAE6FD), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resource.title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            resource.summary,
            style: GoogleFonts.poppins(
              fontSize: 13.3,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            color: const Color(0xFFFF6B9D),
            child: Text(
              resource.category.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 9.3,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final content = resource.content.trim().isNotEmpty
        ? resource.content.trim()
        : resource.summary.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 3),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE0F2FE))),
          ),
          child: Text(
            resource.title,
            style: GoogleFonts.poppins(
              fontSize: 16.7,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0369A1),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.55,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF7ED),
        border: Border(
          left: BorderSide(color: Color(0xFFF59E0B), width: 5),
          top: BorderSide(color: Color(0xFFFED7AA), width: 1),
          right: BorderSide(color: Color(0xFFFED7AA), width: 1),
          bottom: BorderSide(color: Color(0xFFFED7AA), width: 1),
        ),
      ),
      child: Text.rich(
        TextSpan(
          text: 'Importante: este material es informativo y no reemplaza la valoración de un profesional de la salud. Ante cualquier duda o señal de alarma, consulta con un especialista.',
          style: GoogleFonts.poppins(
            fontSize: 11.3,
            height: 1.5,
            color: const Color(0xFF7C2D12),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 9),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF27BEF5), width: 2)),
      ),
      child: Column(
        children: [
          Text.rich(
            const TextSpan(
              text: 'CuidArte',
              children: [
                TextSpan(
                  text:
                      ' · Cuidado profesional y bienestar para adultos mayores',
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Documento generado para uso personal. Comparte esta guía con responsabilidad.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27BEF5), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
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
          onTap: () => _download(context),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Descargar PDF',
                  style: GoogleFonts.poppins(
                    fontSize: 15.68,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
