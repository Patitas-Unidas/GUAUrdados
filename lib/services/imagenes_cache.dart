import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Caché compartida por fotos, carnets y avatares. La URL completa identifica
/// cada imagen: cambiar la URL en Firestore descarga la nueva versión.
class ImagenesCache extends CacheManager {
  static final instance = ImagenesCache();

  ImagenesCache({Config? config})
      : super(config ?? Config(
          'guaurdados_imagenes_v1',
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 200,
        ));

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    return super.getFileStream(
      url,
      key: key,
      headers: headers,
      withProgress: withProgress,
    ).map((response) {
      if (kDebugMode && response is FileInfo) {
        // Solo el nombre del archivo, nunca la URL ni su token de descarga.
        final uri = Uri.tryParse(url);
        final path = uri == null ? '' : Uri.decodeComponent(uri.path);
        final filename = path.split('/').last;
        final image = filename.isEmpty ? 'imagen' : filename;
        final origin = response.source == FileSource.Cache
            ? 'CACHÉ DEL DISPOSITIVO'
            : response.statusCode == 304
                ? 'REVALIDACIÓN HTTP 304: sin cambios, reutiliza archivo local'
                : 'RED: archivo recibido (HTTP ${response.statusCode})';
        debugPrint('[Imágenes] $origin | $image');
      }
      return response;
    });
  }
}
