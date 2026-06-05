import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_router.dart';
import 'core/network/api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Quando a API retorna 401 (token expirado), redireciona para /login.
  // Callback definido aqui para evitar dependência circular entre api_client ↔ router.
  ApiClient.onUnauthorized = () => appRouter.go('/login');

  // Barra de status transparente (estilo imersivo)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Orientação: portrait apenas no mobile
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MaintSysApp());
}

class MaintSysApp extends StatelessWidget {
  const MaintSysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MaintSys',
      debugShowCheckedModeBanner: false,
      theme: MaintSysTheme.dark,
      routerConfig: appRouter,
    );
  }
}
