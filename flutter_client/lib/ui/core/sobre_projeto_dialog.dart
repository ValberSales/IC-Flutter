import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SobreProjetoDialog extends StatelessWidget {
  const SobreProjetoDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const SobreProjetoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho
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
                        child: const Icon(Icons.info_rounded, color: AppColors.primary, size: 26),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Sobre o Projeto',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 28),

              // Descrição do Projeto
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/senai_libras.png',
                          height: 32,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.school_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Alfabetiza Libras',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Esta aplicação é fruto de um projeto de Iniciação Científica (IC) desenvolvido na UTFPR - Câmpus Pato Branco.\n\n'
                      'O sistema tem como objetivo apoiar a alfabetização bilíngue de crianças surdas, com foco na Língua Brasileira de Sinais (Libras) e no alfabeto datilológico (manual).\n\n'
                      'Trata-se de uma evolução e reescrita completa multiplataforma (utilizando Flutter no cliente e Spring Boot no servidor), concebida como um fork evolutivo a partir do projeto original criado como Trabalho de Conclusão de Curso (TCC).',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Seção de Créditos
              const Text(
                'Créditos e Equipe',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),

              _buildCreditTile(
                icon: Icons.code_rounded,
                role: 'Desenvolvimento (IC Flutter & Spring Boot)',
                name: 'Valber Sales Junior',
                isPrimary: true,
              ),
              const SizedBox(height: 8),

              _buildCreditTile(
                icon: Icons.school_rounded,
                role: 'Orientadora',
                name: 'Profª. Drª. Rúbia Eliza de Oliveira Schultz Ascari',
              ),
              const SizedBox(height: 8),

              _buildCreditTile(
                icon: Icons.group_rounded,
                role: 'Colaboradores',
                name: 'Profª. Me. Mirelia Flausino Vogel\nProfª. Me. Aline Brancalione\nIsacar Floriano de Freitas Junior',
              ),
              const SizedBox(height: 8),

              _buildCreditTile(
                icon: Icons.history_edu_rounded,
                role: 'Projeto Base Original (TCC Angular & Node.js)',
                name: 'Luan Filipe Finatto',
                subInfo: 'Autor do Trabalho de Conclusão de Curso original que originou o fork.',
              ),
              const SizedBox(height: 20),

              // Copyright
              Center(
                child: Text(
                  '© UTFPR - Câmpus Pato Branco.\nTodos os direitos reservados.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark.withOpacity(0.6),
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botão Fechar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditTile({
    required IconData icon,
    required String role,
    required String name,
    String? subInfo,
    bool isPrimary = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primary.withOpacity(0.06) : AppColors.bgSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrimary ? AppColors.primary.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.primary.withOpacity(0.15) : Colors.grey.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isPrimary ? AppColors.primary : AppColors.textDark.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPrimary ? AppColors.primary : AppColors.textDark.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (subInfo != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subInfo,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDark.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
