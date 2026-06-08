import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'data/storage/local_storage_service.dart';
import 'state/app_state_provider.dart';
import 'presentation/pages/home/home_page.dart';

void main() async {
  // Garante inicialização de canais de plataforma assíncronos (necessário para SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o armazenamento local
  await LocalStorageService.init();

  // Executa o aplicativo
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final provider = AppStateProvider();
        provider.loadInitialState(); // Carrega personagens e configurações do disco
        return provider;
      },
      child: const AlfabetizacaoApp(),
    ),
  );
}

class AlfabetizacaoApp extends StatelessWidget {
  const AlfabetizacaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alfabetiza Libras',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
