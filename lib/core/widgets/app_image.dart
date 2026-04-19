import 'dart:convert';
import 'package:flutter/material.dart';

/// Helper to get an ImageProvider that supports both Base64 inline strings and Network URLs.
ImageProvider getAppImageProvider(String url) {
  if (url.startsWith('data:image')) {
    final base64String = url.split(',').last;
    return MemoryImage(base64Decode(base64String));
  }
  return NetworkImage(url);
}

/// A wrapper widget that supports rendering both Base64 inline strings and Network URLs.
class AppImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit? fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: errorBuilder,
        );
      } catch (e) {
        if (errorBuilder != null) {
          return errorBuilder!(context, e, null);
        }
        return const SizedBox.shrink();
      }
    }
    
    return Image.network(
      imageUrl,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
}
