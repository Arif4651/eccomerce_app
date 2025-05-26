import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the image is a local asset
    if (imageUrl.startsWith('asset/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder:
            (context, error, stackTrace) =>
                errorWidget ??
                const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    // For network images, use CachedNetworkImage
    int? memCacheWidth;
    int? memCacheHeight;

    if (width != null && width!.isFinite) {
      memCacheWidth = width!.toInt();
    }
    if (height != null && height!.isFinite) {
      memCacheHeight = height!.toInt();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder:
          (context, url) =>
              placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget:
          (context, url, error) =>
              errorWidget ?? const Icon(Icons.broken_image, color: Colors.grey),
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
    );
  }
}
