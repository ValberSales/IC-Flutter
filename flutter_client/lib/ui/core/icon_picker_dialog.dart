import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppIconData {
  final String key;
  final String label;
  final IconData icon;

  const AppIconData({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class IconPickerDialogWidget extends StatefulWidget {
  final String? initialIconKey;

  const IconPickerDialogWidget({
    super.key,
    this.initialIconKey,
  });

  static const List<AppIconData> availableIcons = [
    AppIconData(key: 'pets', label: 'Animais', icon: Icons.pets_rounded),
    AppIconData(key: 'diversity_3', label: 'Família / Pessoas', icon: Icons.diversity_3_rounded),
    AppIconData(key: 'school', label: 'Escola / Estudo', icon: Icons.school_rounded),
    AppIconData(key: 'menu_book', label: 'Livro / Leitura', icon: Icons.menu_book_rounded),
    AppIconData(key: 'nature_people', label: 'Natureza', icon: Icons.nature_people_rounded),
    AppIconData(key: 'stars', label: 'Estrelas / Conquista', icon: Icons.stars_rounded),
    AppIconData(key: 'sports_esports', label: 'Jogos / Games', icon: Icons.sports_esports_rounded),
    AppIconData(key: 'favorite', label: 'Coração / Afeto', icon: Icons.favorite_rounded),
    AppIconData(key: 'palette', label: 'Artes / Cores', icon: Icons.palette_rounded),
    AppIconData(key: 'music_note', label: 'Música / Sons', icon: Icons.music_note_rounded),
    AppIconData(key: 'lightbulb', label: 'Ideias / Ciência', icon: Icons.lightbulb_rounded),
    AppIconData(key: 'directions_car', label: 'Veículos / Transporte', icon: Icons.directions_car_rounded),
    AppIconData(key: 'restaurant', label: 'Alimentos / Comida', icon: Icons.restaurant_rounded),
    AppIconData(key: 'science', label: 'Experimentos', icon: Icons.science_rounded),
    AppIconData(key: 'fitness_center', label: 'Esportes / Saúde', icon: Icons.fitness_center_rounded),
    AppIconData(key: 'flight', label: 'Viagem / Aviação', icon: Icons.flight_rounded),
    AppIconData(key: 'child_care', label: 'Crianças / Brinquedos', icon: Icons.child_care_rounded),
    AppIconData(key: 'emoji_events', label: 'Troféu / Prêmio', icon: Icons.emoji_events_rounded),
    AppIconData(key: 'extension', label: 'Quebra-cabeça', icon: Icons.extension_rounded),
    AppIconData(key: 'explore', label: 'Bússola / Aventura', icon: Icons.explore_rounded),
    AppIconData(key: 'brush', label: 'Pintura', icon: Icons.brush_rounded),
    AppIconData(key: 'local_florist', label: 'Flores / Plantas', icon: Icons.local_florist_rounded),
    AppIconData(key: 'category', label: 'Geral', icon: Icons.category_rounded),
  ];

  static IconData getIconData(String? key, {IconData fallback = Icons.category_rounded}) {
    if (key == null || key.isEmpty) return fallback;
    final found = availableIcons.firstWhere(
      (item) => item.key == key,
      orElse: () => AppIconData(key: 'fallback', label: 'Geral', icon: fallback),
    );
    return found.icon;
  }

  @override
  State<IconPickerDialogWidget> createState() => _IconPickerDialogWidgetState();
}

class _IconPickerDialogWidgetState extends State<IconPickerDialogWidget> {
  String _searchQuery = '';
  late String _selectedKey;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.initialIconKey ?? 'pets';
  }

  @override
  Widget build(BuildContext context) {
    final filteredIcons = IconPickerDialogWidget.availableIcons.where((item) {
      final q = _searchQuery.toLowerCase().trim();
      if (q.isEmpty) return true;
      return item.label.toLowerCase().contains(q) || item.key.toLowerCase().contains(q);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.palette_rounded, color: AppColors.primary, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Escolha o Ícone do Tema',
                        style: TextStyle(
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
                    icon: const Icon(Icons.close_rounded, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campo de Busca
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar ícone (ex: Animais, Livro, Escola)...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.bgSoft,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Grid de Ícones
              Expanded(
                child: filteredIcons.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum ícone encontrado',
                          style: TextStyle(color: AppColors.textDark, fontSize: 14),
                        ),
                      )
                    : GridView.builder(
                        itemCount: filteredIcons.length,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 110,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 100,
                        ),
                        itemBuilder: (context, index) {
                          final item = filteredIcons[index];
                          final isSelected = item.key == _selectedKey;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedKey = item.key;
                              });
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.bgSoft,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 32,
                                    color: isSelected ? AppColors.primary : AppColors.textDark.withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.label,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? AppColors.primary : AppColors.textDark.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              // Botões de Ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_selectedKey),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirmar Ícone',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
