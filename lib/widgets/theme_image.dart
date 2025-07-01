import 'package:flutter/material.dart';

class ThemeImage extends StatelessWidget {
  final String lightImagePath;
  final String? darkImagePath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const ThemeImage({
    super.key,
    required this.lightImagePath,
    this.darkImagePath,
    this.width,
    this.height,
    this.fit,
    this.errorBuilder,
  });

  String get _darkImagePath {
    if (darkImagePath != null) return darkImagePath!;
    
    // Auto-generate dark image path by adding 'white' before the extension
    final lastDot = lightImagePath.lastIndexOf('.');
    if (lastDot == -1) return lightImagePath;
    
    final pathWithoutExtension = lightImagePath.substring(0, lastDot);
    final extension = lightImagePath.substring(lastDot);
    
    // Handle both tutti.png -> tuttiwhite.png and tuttiicon.png -> tuttiiconwhite.png
    if (pathWithoutExtension.endsWith('tutti')) {
      return '${pathWithoutExtension}white$extension';
    } else if (pathWithoutExtension.endsWith('tuttiicon')) {
      return '${pathWithoutExtension}white$extension';
    }
    
    return '${pathWithoutExtension}white$extension';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final imagePath = isDarkTheme ? _darkImagePath : lightImagePath;
    
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder ?? (context, error, stackTrace) {
        // Fallback to light image if dark image fails to load
        if (isDarkTheme && imagePath != lightImagePath) {
          return Image.asset(
            lightImagePath,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image_not_supported,
                size: width ?? height ?? 24,
                color: Colors.grey,
              );
            },
          );
        }
        return Icon(
          Icons.image_not_supported,
          size: width ?? height ?? 24,
          color: Colors.grey,
        );
      },
    );
  }
} 