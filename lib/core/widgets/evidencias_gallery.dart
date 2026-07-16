import 'package:flutter/material.dart';

import '../services/evidencia_storage_service.dart';

class EvidenciasGallery extends StatelessWidget {
  final String incidenteId;
  final String? fotoLegada;
  final bool compacta;

  const EvidenciasGallery({
    super.key,
    required this.incidenteId,
    this.fotoLegada,
    this.compacta = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: EvidenciaStorageService().obtenerUrlsFotos(
        incidenteId: incidenteId,
        fotoLegada: fotoLegada,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final urls = snapshot.data ?? const <String>[];
        if (urls.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.photo_library_outlined),
                    SizedBox(width: 8),
                    Text(
                      'Evidencias fotograficas',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: compacta ? 92 : 164,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: urls.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) =>
                        _EvidenceImage(url: urls[index], compacta: compacta),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EvidenceImage extends StatelessWidget {
  final String url;
  final bool compacta;

  const _EvidenceImage({required this.url, required this.compacta});

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: compacta ? 120 : 210,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: Color(0xFFF0F3F6),
          child: SizedBox(width: 120, child: Icon(Icons.broken_image_outlined)),
        ),
      ),
    );

    return InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          child: InteractiveViewer(
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      child: image,
    );
  }
}
