import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../services/imagenes_cache.dart';

/// Conserva las imágenes en disco entre sesiones y respeta la caducidad HTTP.
class ImagenRemota extends StatelessWidget {
  const ImagenRemota({
    super.key,
    required this.url,
    required this.error,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String url;
  final Widget error;
  final double? width, height;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: url,
        cacheManager: ImagenesCache.instance,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, _) => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, _, _) => error,
      );
}
