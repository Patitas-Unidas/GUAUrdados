import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../services/imagenes_cache.dart';
import 'esqueleto.dart';

/// Conserva las imágenes en disco entre sesiones y respeta la caducidad HTTP.
class ImagenRemota extends StatelessWidget {
  const ImagenRemota({
    super.key,
    required this.url,
    required this.error,
    this.cargando,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String url;
  final Widget error;
  final Widget? cargando;
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
        placeholder: (_, _) => cargando ?? const BloqueEsqueleto(radio: 0),
        errorWidget: (_, _, _) => error,
      );
}
