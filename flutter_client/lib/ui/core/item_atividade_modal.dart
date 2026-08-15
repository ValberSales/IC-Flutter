import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/atividade.dart';
import '../../data/services/api_service.dart';
import '../../data/sources/local_data_source.dart';
import 'web_drop_zone_widget.dart';

class ItemAtividadeModalWidget extends StatefulWidget {
  final ItemAtividade? initialItem;
  final String tipoJogo; // 'JOGO_ADIVINHACAO' | 'JOGO_PALAVRAS'

  const ItemAtividadeModalWidget({
    super.key,
    this.initialItem,
    required this.tipoJogo,
  });

  @override
  State<ItemAtividadeModalWidget> createState() => _ItemAtividadeModalWidgetState();
}

class _ItemAtividadeModalWidgetState extends State<ItemAtividadeModalWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  late TextEditingController _imagemController;
  late TextEditingController _opc1Controller;
  late TextEditingController _opc2Controller;
  late TextEditingController _opc3Controller;
  late TextEditingController _opc4Controller;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(text: widget.initialItem?.descricao ?? '');
    _imagemController = TextEditingController(text: widget.initialItem?.imagem ?? '');

    final existingDistractors = widget.initialItem != null
        ? widget.initialItem!.opcoes.where((o) => o != widget.initialItem!.descricao).toList()
        : <String>[];

    _opc1Controller = TextEditingController(text: existingDistractors.length > 0 ? existingDistractors[0] : '');
    _opc2Controller = TextEditingController(text: existingDistractors.length > 1 ? existingDistractors[1] : '');
    _opc3Controller = TextEditingController(text: existingDistractors.length > 2 ? existingDistractors[2] : '');
    _opc4Controller = TextEditingController(text: existingDistractors.length > 3 ? existingDistractors[3] : '');
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _imagemController.dispose();
    _opc1Controller.dispose();
    _opc2Controller.dispose();
    _opc3Controller.dispose();
    _opc4Controller.dispose();
    super.dispose();
  }

  void _pickAndUploadImage() {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((e) async {
            final bytes = reader.result as Uint8List;
            setState(() {
              _isUploadingImage = true;
            });

            final url = await ApiService.uploadImagem(bytes, file.name);

            if (mounted) {
              setState(() {
                _isUploadingImage = false;
                if (url != null) {
                  _imagemController.text = url;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📷 Imagem enviada com sucesso: $url'),
                      backgroundColor: AppColors.accent,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao enviar imagem.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              });
            }
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O upload via navegador está disponível no Flutter Web.'),
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    final path = _imagemController.text.trim();
    if (path.isEmpty) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.bgSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_search_rounded, size: 40, color: AppColors.primaryLight),
              SizedBox(height: 6),
              Text(
                'Nenhuma imagem selecionada',
                style: TextStyle(color: AppColors.textDark, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final fullUrl = path.startsWith('/api/files/')
        ? 'http://localhost:8081$path'
        : (path.startsWith('http') ? path : path);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        width: double.infinity,
        color: AppColors.bgSoft,
        child: Stack(
          alignment: Alignment.center,
          children: [
            path.startsWith('http') || path.startsWith('/api/files/')
                ? Image.network(
                    fullUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_rounded, size: 36, color: AppColors.error),
                        SizedBox(height: 4),
                        Text('Erro ao carregar imagem', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                : Image.asset(
                    path,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_rounded, size: 36, color: AppColors.error),
                        SizedBox(height: 4),
                        Text('Imagem não encontrada', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final desc = _descricaoController.text.trim();
      final img = _imagemController.text.trim();

      if (img.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, carregue uma imagem arrastando ou enviando o arquivo.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      List<String> distractors = [
        _opc1Controller.text.trim(),
        _opc2Controller.text.trim(),
        _opc3Controller.text.trim(),
        _opc4Controller.text.trim(),
      ].where((s) => s.isNotEmpty).toList();

      List<String> opcoesList = [desc, ...distractors];

      final item = ItemAtividade(
        descricao: desc,
        imagem: img,
        opcoes: opcoesList,
      );

      Navigator.of(context).pop(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;
    final isPalavras = widget.tipoJogo == 'JOGO_PALAVRAS';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho Modal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isEditing ? Icons.edit_note_rounded : Icons.post_add_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEditing ? 'Editar Item do Jogo' : 'Adicionar Novo Item',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Fredoka',
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Campo Palavra / Descrição
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Palavra Correta / Resposta (ex: Maçã, Mãe, Gato)',
                    prefixIcon: Icon(Icons.check_circle_outline_rounded, color: AppColors.accent),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor, digite a palavra correta.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Zone Unificada de Upload e Preview Dinâmico de Imagem (Drag & Drop)
                WebDropZoneWidget(
                  currentImageUrl: _imagemController.text,
                  onImageUploaded: (url) {
                    setState(() {
                      _imagemController.text = url;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Campos para 4 Palavras Distratoras (Incorretas) no Jogo de Palavras
                if (isPalavras) ...[
                  const Text(
                    'Opções Incorretas (4 Palavras Distratoras):',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _opc1Controller,
                          decoration: const InputDecoration(
                            labelText: 'Opção Incorreta 1',
                            prefixIcon: Icon(Icons.cancel_outlined, color: AppColors.error),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _opc2Controller,
                          decoration: const InputDecoration(
                            labelText: 'Opção Incorreta 2',
                            prefixIcon: Icon(Icons.cancel_outlined, color: AppColors.error),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _opc3Controller,
                          decoration: const InputDecoration(
                            labelText: 'Opção Incorreta 3',
                            prefixIcon: Icon(Icons.cancel_outlined, color: AppColors.error),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _opc4Controller,
                          decoration: const InputDecoration(
                            labelText: 'Opção Incorreta 4',
                            prefixIcon: Icon(Icons.cancel_outlined, color: AppColors.error),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '💡 Estas 4 palavras serão exibidas como alternativas incorretas junto com a resposta certa.',
                    style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 16),
                ],

                // Botões do Modal
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          isEditing ? 'Salvar Alterações' : 'Adicionar Item',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
