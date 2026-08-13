import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';

class WebDropZoneWidget extends StatefulWidget {
  final Function(String url) onImageUploaded;
  final String? currentImageUrl;

  const WebDropZoneWidget({
    super.key,
    required this.onImageUploaded,
    this.currentImageUrl,
  });

  @override
  State<WebDropZoneWidget> createState() => _WebDropZoneWidgetState();
}

class _WebDropZoneWidgetState extends State<WebDropZoneWidget> {
  bool _isDraggingOver = false;
  bool _isUploading = false;
  StreamSubscription<html.MouseEvent>? _dragOverSub;
  StreamSubscription<html.MouseEvent>? _dragLeaveSub;
  StreamSubscription<html.MouseEvent>? _dropSub;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initWebDragAndDrop();
    }
  }

  void _initWebDragAndDrop() {
    _dragOverSub = html.document.onDragOver.listen((event) {
      event.preventDefault();
      event.stopPropagation();
      if (!_isDraggingOver && mounted) {
        setState(() {
          _isDraggingOver = true;
        });
      }
    });

    _dragLeaveSub = html.document.onDragLeave.listen((event) {
      event.preventDefault();
      event.stopPropagation();
      if (_isDraggingOver && mounted) {
        setState(() {
          _isDraggingOver = false;
        });
      }
    });

    _dropSub = html.document.onDrop.listen((event) {
      event.preventDefault();
      event.stopPropagation();
      if (mounted) {
        setState(() {
          _isDraggingOver = false;
        });
      }

      final files = event.dataTransfer.files;
      if (files != null && files.isNotEmpty) {
        _processFile(files[0]);
      }
    });
  }

  void _processFile(html.File file) {
    if (!file.type.startsWith('image/')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, solte apenas arquivos de imagem (PNG, JPG, WEBP).'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoadEnd.listen((e) async {
      final bytes = reader.result as Uint8List;
      final url = await ApiService.uploadImagem(bytes, file.name);

      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        if (url != null) {
          widget.onImageUploaded(url);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📷 Imagem "$url" carregada via Drag & Drop com sucesso!'),
              backgroundColor: AppColors.accent,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao enviar imagem enviada por arrasto.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
  }

  void _handleClickUpload() {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          _processFile(files[0]);
        }
      });
    }
  }

  @override
  void dispose() {
    _dragOverSub?.cancel();
    _dragLeaveSub?.cancel();
    _dropSub?.cancel();
    super.dispose();
  }

  Widget _buildImagePreviewWidget(String path) {
    final fullUrl = path.startsWith('/api/files/')
        ? 'http://localhost:8081$path'
        : (path.startsWith('http') ? path : path);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: path.startsWith('http') || path.startsWith('/api/files/')
                ? Image.network(
                    fullUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded, size: 40, color: AppColors.error),
                  )
                : Image.asset(
                    path,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_rounded, size: 40, color: AppColors.error),
                  ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Arraste ou clique para trocar',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.currentImageUrl != null && widget.currentImageUrl!.trim().isNotEmpty;

    return InkWell(
      onTap: _isUploading ? null : _handleClickUpload,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isDraggingOver
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.bgSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isDraggingOver ? AppColors.primary : AppColors.border,
            width: _isDraggingOver ? 3 : 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isUploading) ...[
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enviando imagem para o servidor...',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
              ),
            ] else if (_isDraggingOver) ...[
              const Icon(Icons.cloud_upload_rounded, size: 48, color: AppColors.primary),
              const SizedBox(height: 8),
              const Text(
                'Solte a nova imagem aqui para substituir!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
              ),
            ] else if (hasImage) ...[
              Expanded(
                child: _buildImagePreviewWidget(widget.currentImageUrl!),
              ),
            ] else ...[
              const Icon(Icons.cloud_upload_outlined, size: 44, color: AppColors.primaryLight),
              const SizedBox(height: 8),
              const Text(
                'Arraste e solte uma imagem aqui',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _handleClickUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text(
                  'Enviar Imagem',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
