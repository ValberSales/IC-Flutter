import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

class DynamicImageWidget extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final IconData fallbackIcon;
  final Color? fallbackIconColor;

  const DynamicImageWidget({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.fallbackIcon = Icons.image_rounded,
    this.fallbackIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final String path = imagePath.trim();

    if (path.isEmpty) {
      return _buildFallback();
    }

    // 1. Asset local (assets/...)
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // 2. Imagem em formato Data Base64 (data:image/png;base64,...)
    if (path.startsWith('data:image')) {
      try {
        final commaIndex = path.indexOf(',');
        final base64Str = commaIndex != -1 ? path.substring(commaIndex + 1) : path;
        final Uint8List bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } catch (e) {
        return _buildFallback();
      }
    }

    // 3. URL de Rede ou Rota Relativa do Servidor (/api/files/...)
    String fullUrl = path;
    if (path.startsWith('/')) {
      fullUrl = '${ApiService.baseUrl.replaceAll('/api', '')}$path';
    } else if (!path.startsWith('http://') && !path.startsWith('https://')) {
      fullUrl = '${ApiService.baseUrl}/files/$path';
    }

    return Image.network(
      fullUrl,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.bgSoft,
      alignment: Alignment.center,
      child: Icon(
        fallbackIcon,
        size: width != null && width! < 60 ? 24 : 48,
        color: fallbackIconColor ?? AppColors.primaryLight,
      ),
    );
  }
}
