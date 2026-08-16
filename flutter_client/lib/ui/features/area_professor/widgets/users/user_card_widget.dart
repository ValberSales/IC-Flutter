import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/usuario.dart';

class UserCardWidget extends StatelessWidget {
  final Usuario user;
  final bool isMe;
  final VoidCallback onEdit;
  final VoidCallback onResetPassword;
  final VoidCallback onDelete;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.isMe,
    required this.onEdit,
    required this.onResetPassword,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.isAdmin;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isAdmin ? Colors.purple.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage(user.avatar ?? 'assets/avatar/avatar_1.jpg'),
            ),
            const SizedBox(width: 14),

            // Informações do Usuário
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.nome ?? user.username ?? 'Sem Nome',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Você', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username ?? ''}',
                    style: TextStyle(fontSize: 12, color: AppColors.textDark.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.purple.withValues(alpha: 0.12) : AppColors.secondary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isAdmin ? '👑 Professor / Admin' : '⭐ Aluno',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isAdmin ? Colors.purple : AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Ações: Reset Senha, Editar e Excluir
            IconButton(
              icon: const Icon(Icons.lock_reset_rounded, color: AppColors.accent),
              tooltip: 'Resetar Senha',
              onPressed: onResetPassword,
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
              tooltip: 'Editar Permissões',
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: isMe ? Colors.grey : AppColors.error),
              tooltip: isMe ? 'Não é possível excluir sua própria conta' : 'Excluir Usuário',
              onPressed: isMe ? null : onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
