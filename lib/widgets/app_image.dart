import 'package:first_project/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.restaurant_rounded,
    this.placeholderIconSize = 40,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData placeholderIcon;
  final double placeholderIconSize;

  bool get isAsset => imageUrl.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (isAsset) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
      );
    }

    return FadeInImage(
      placeholder: MemoryImage(kTransparentImage),
      image: NetworkImage(imageUrl),
      width: width,
      height: height,
      fit: fit,
      imageErrorBuilder: (ctx, err, stack) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          placeholderIcon,
          size: placeholderIconSize,
          color: AppColors.textDisabled,
        ),
      ),
    );
  }
}
