import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'data/storage/local_storage_service.dart';
import 'state/app_state_provider.dart';
import 'ui/features/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final provider = AppStateProvider();
        provider.loadInitialState();
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
      home: const HomeView(),
    );
  }
}
