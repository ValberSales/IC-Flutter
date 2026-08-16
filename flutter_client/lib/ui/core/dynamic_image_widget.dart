import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/storage/media_storage_service.dart';

class DynamicImageWidget extends StatefulWidget {
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
  State<DynamicImageWidget> createState() => _DynamicImageWidgetState();
}

class _DynamicImageWidgetState extends State<DynamicImageWidget> {
  File? _localCachedFile;

  @override
  void initState() {
    super.initState();
    _checkLocalCache();
  }

  @override
  void didUpdateWidget(covariant DynamicImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _localCachedFile = null;
      _checkLocalCache();
    }
  }

  Future<void> _checkLocalCache() async {
    final path = widget.imagePath.trim();
    if (kIsWeb || !MediaStorageService.isCacheableUrl(path)) {
      return;
    }

    final local = await MediaStorageService.getLocalMediaFile(path);
    if (mounted && local != null) {
      setState(() {
        _localCachedFile = local;
      });
      return;
    }

    // Se ainda não estiver em cache, efetua o download e atualiza imediatamente para o arquivo local
    final downloaded = await MediaStorageService.downloadAndCacheMedia(path);
    if (mounted && downloaded != null) {
      setState(() {
        _localCachedFile = downloaded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String path = widget.imagePath.trim();

    if (path.isEmpty) {
      return _buildFallback();
    }

    // 1. Asset local empacotado (assets/...)
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
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
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } catch (e) {
        return _buildFallback();
      }
    }

    // 3. Imagem salva em cache local em disco (100% Offline no Smartphone)
    if (!kIsWeb && _localCachedFile != null) {
      return Image.file(
        _localCachedFile!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: (context, error, stackTrace) => _buildNetworkOrFallback(path),
      );
    }

    // 4. URL de Rede com fallback inteligente
    return _buildNetworkOrFallback(path);
  }

  Widget _buildNetworkOrFallback(String path) {
    String fullUrl = MediaStorageService.resolveFullUrl(path);

    return Image.network(
      fullUrl,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
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
      width: widget.width,
      height: widget.height,
      color: AppColors.bgSoft,
      alignment: Alignment.center,
      child: Icon(
        widget.fallbackIcon,
        size: widget.width != null && widget.width! < 60 ? 24 : 48,
        color: widget.fallbackIconColor ?? AppColors.primaryLight,
      ),
    );
  }
}
