import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'theme/app_theme.dart';
import 'utils/hud_manager.dart';
import 'utils/screen_adapter.dart';

class CashPinoyApp extends StatelessWidget {
  const CashPinoyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  static final RouteObserver<PageRoute<dynamic>> routeObserver =
      RouteObserver<PageRoute<dynamic>>();

  @override
  Widget build(BuildContext context) {
    HudManager.init(overlayKey);
    return MaterialApp(
      title: 'Cash Pinoy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      builder: (context, child) {
        ScreenAdapter.init(context);
        return Overlay(
          key: overlayKey,
          initialEntries: [
            OverlayEntry(builder: (_) => child ?? const SizedBox.shrink()),
            OverlayEntry(builder: (_) => HudManager.overlayLayer()),
          ],
        );
      },
      home: const HomeShell(),
    );
  }
}
