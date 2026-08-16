import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/turma.dart';
import '../../../../../state/app_state_provider.dart';

class TurmaFormDialog extends StatefulWidget {
  final Turma? turma;
  final AppStateProvider state;

  const TurmaFormDialog({
    super.key,
    this.turma,
    required this.state,
  });

  static Future<void> show(BuildContext context, AppStateProvider state, {Turma? turma}) {
    return showDialog(
      context: context,
      builder: (_) => TurmaFormDialog(turma: turma, state: state),
    );
  }

  @override
  State<TurmaFormDialog> createState() => _TurmaFormDialogState();
}

class _TurmaFormDialogState extends State<TurmaFormDialog> {
  late TextEditingController _nomeCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _codigoCtrl;
  bool _isSaving = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.turma?.nome ?? '');
    _descCtrl = TextEditingController(text: widget.turma?.descricao ?? '');
    _codigoCtrl = TextEditingController(text: widget.turma?.codigo ?? '');
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descCtrl.dispose();
    _codigoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final codigo = _codigoCtrl.text.trim().toUpperCase();

    if (nome.isEmpty) {
      setState(() => _errorMsg = 'O nome da turma é obrigatório.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    try {
      if (widget.turma == null) {
        final res = await widget.state.createTurma(
          nome: nome,
          descricao: desc,
          codigo: codigo.isNotEmpty ? codigo : null,
        );
        if (res == null) throw Exception('Falha ao cadastrar turma no servidor.');
      } else {
        final res = await widget.state.updateTurma(
          widget.turma!.id!,
          nome: nome,
          descricao: desc,
          codigo: codigo.isNotEmpty ? codigo : null,
        );
        if (res == null) throw Exception('Falha ao atualizar turma no servidor.');
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.turma == null ? 'Turma criada com sucesso!' : 'Turma atualizada com sucesso!'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMsg = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.turma != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(isEdit ? Icons.edit_note_rounded : Icons.add_home_work_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            isEdit ? 'Editar Turma' : 'Nova Turma',
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Fredoka'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_errorMsg!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ),
                const SizedBox(height: 14),
              ],
              TextField(
                controller: _nomeCtrl,
                decoration: InputDecoration(
                  labelText: 'Nome da Turma *',
                  hintText: 'Ex: 2º Ano A - Matutino',
                  filled: true,
                  fillColor: AppColors.bgSoft,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: 'Descrição / Ano Escolar',
                  hintText: 'Ex: Turma de alfabetização em Libras',
                  filled: true,
                  fillColor: AppColors.bgSoft,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _codigoCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Código / PIN da Turma (Opcional)',
                  hintText: 'Deixe em branco para gerar automaticamente (Ex: LBR-4029)',
                  filled: true,
                  fillColor: AppColors.bgSoft,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.textDark)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _isSaving ? null : _salvar,
          child: _isSaving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(isEdit ? 'Salvar Alterações' : 'Criar Turma', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
