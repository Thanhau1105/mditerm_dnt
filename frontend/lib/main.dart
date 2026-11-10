import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'widgets/app_theme.dart';

void main() => runApp(const VkuApp());

class VkuApp extends StatefulWidget {
  const VkuApp({super.key, this.auth});
  final AuthService? auth;

  @override
  State<VkuApp> createState() => _VkuAppState();
}

class _VkuAppState extends State<VkuApp> {
  late final AuthService _auth = widget.auth ?? AuthService(ApiService());

  @override
  void dispose() {
    if (widget.auth == null) _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'VKU Student Management',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    locale: const Locale('vi'),
    supportedLocales: const [Locale('vi'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: AnimatedBuilder(
      animation: _auth,
      builder: (context, _) => _auth.isAuthenticated
          ? DashboardScreen(key: ValueKey(_auth.currentUser!.id), auth: _auth)
          : LoginScreen(auth: _auth),
    ),
  );
}
