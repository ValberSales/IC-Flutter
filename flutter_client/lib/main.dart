import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'data/storage/local_storage_service.dart';
import 'state/app_state_provider.dart';
import 'ui/features/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();

  // Configuração inicial de orientação baseada no tamanho físico da tela
  if (!kIsWeb) {
    try {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final size = view.physicalSize / view.devicePixelRatio;
      if (size.shortestSide < 600) {
        // Smartphones: Bloquear em modo retrato (portrait)
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } else {
        // Tablets e telas grandes: Permitir todas as rotações
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
    } catch (_) {}
  }

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

class AlfabetizacaoApp extends StatefulWidget {
  const AlfabetizacaoApp({super.key});

  @override
  State<AlfabetizacaoApp> createState() => _AlfabetizacaoAppState();
}

class _AlfabetizacaoAppState extends State<AlfabetizacaoApp> {
  bool? _wasTablet;

  void _enforceDeviceOrientation(BuildContext context) {
    if (kIsWeb) return;
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final isTablet = shortestSide >= 600;

    if (_wasTablet != isTablet) {
      _wasTablet = isTablet;
      if (isTablet) {
        // Tablets: rotação liberada
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        // Celulares: bloqueado em portrait
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alfabetiza Libras',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        _enforceDeviceOrientation(context);
        return child ?? const SizedBox.shrink();
      },
      home: const HomeView(),
    );
  }
}
