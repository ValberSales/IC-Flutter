import 'package:flutter/material.dart';
import 'package:flutter_client/core/constants/app_colors.dart';
import 'package:flutter_client/data/models/usuario.dart';
import 'package:flutter_client/state/app_state_provider.dart';
import 'package:flutter_client/ui/core/logout_helper.dart';

class UserProfileInfoSectionWidget extends StatefulWidget {
  final Usuario? user;
  final bool isGuest;
  final AppStateProvider state;
  final VoidCallback onEditRequested;

  const UserProfileInfoSectionWidget({
    super.key,
    required this.user,
    required this.isGuest,
    required this.state,
    required this.onEditRequested,
  });

  @override
  State<UserProfileInfoSectionWidget> createState() => _UserProfileInfoSectionWidgetState();
}

class _UserProfileInfoSectionWidgetState extends State<UserProfileInfoSectionWidget> {
  final TextEditingController _pinController = TextEditingController();
  bool _isJoiningTurma = false;
  String? _turmaMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final isGuest = widget.isGuest;
    final state = widget.state;

    final nome = isGuest ? 'Pequeno Aprendiz' : (user?.nome ?? user?.username ?? 'Aluno');
    final username = isGuest ? 'Convidado' : (user?.username ?? '');
    final role = isGuest ? 'VISITANTE' : (user?.role ?? 'USER');

    // Estatísticas de pontuação
    final history = state.getPontuacaoHistoryForCurrentUser();
    int totalAcertos = 0;
    int totalErros = 0;
    for (final p in history) {
      totalAcertos += p.acertos;
      totalErros += p.erros;
    }
    final int totalJogadas = totalAcertos + totalErros;
    final double taxaAcerto = totalJogadas > 0 ? (totalAcertos / totalJogadas) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Nome e Badges
        Center(
          child: Column(
            children: [
              Text(
                nome,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '@$username',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: role == 'ADMIN'
                          ? Colors.purple.withOpacity(0.15)
                          : AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role == 'ADMIN' ? '👑 Professor / Admin' : '⭐ Aluno',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: role == 'ADMIN' ? Colors.purple : AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Card de Estatísticas
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Partidas', '${history.length}', Icons.sports_esports_rounded, AppColors.primary),
              _buildStatItem('Acertos', '$totalAcertos', Icons.check_circle_rounded, AppColors.secondary),
              _buildStatItem('Aproveitamento', '${taxaAcerto.toStringAsFixed(0)}%', Icons.stars_rounded, AppColors.accent),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Card Minha Turma / Vincular Turma
        _buildTurmaCard(context, state),
        const SizedBox(height: 18),

        // Botão para abrir edição de conta
        if (!isGuest) ...[
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: const BorderSide(color: AppColors.secondary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: widget.onEditRequested,
            icon: const Icon(Icons.manage_accounts_rounded),
            label: const Text('Editar Nome, Usuário ou Senha', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
        ],

        // Botão Sair / Logout
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error.withOpacity(0.12),
            foregroundColor: AppColors.error,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            await LogoutHelper.executeLogout(context, state);
          },
          icon: const Icon(Icons.logout_rounded),
          label: Text(
            isGuest ? 'Sair do Modo Convidado' : 'Sair da Conta',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildTurmaCard(BuildContext context, AppStateProvider state) {
    final activeTurma = state.activeTurma;

    if (activeTurma != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Minha Turma',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        activeTurma.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activeTurma.codigo,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  activeTurma.atividadesIds.isNotEmpty
                      ? '🎯 ${activeTurma.atividadesIds.length} tema(s) da turma'
                      : 'Nenhum tema atribuído ainda',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textDark.withOpacity(0.7)),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () async {
                    await state.sairDaTurma();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Você saiu da turma com sucesso.'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    }
                  },
                  child: const Text('Sair da Turma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.vpn_key_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Entrar em uma Turma',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Digite o código PIN fornecido pelo seu professor para acessar as atividades direcionadas:',
            style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.7)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pinController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Ex: LBR-1001',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isJoiningTurma
                    ? null
                    : () async {
                        final pin = _pinController.text.trim();
                        if (pin.isEmpty) return;
                        setState(() => _isJoiningTurma = true);
                        final msg = await state.entrarNaTurma(pin);
                        setState(() {
                          _isJoiningTurma = false;
                          _turmaMessage = msg;
                        });
                        _pinController.clear();
                      },
                child: _isJoiningTurma
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (_turmaMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _turmaMessage!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _turmaMessage!.startsWith('Sucesso') ? AppColors.accent : AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
