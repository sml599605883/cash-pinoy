import 'package:flutter/material.dart';

import '../utils/app_info_manager.dart';
import '../utils/nav_helper.dart';
import '../widgets/app_tab_bar.dart';
import 'home/home_screen.dart';
import 'mine/mine_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    HomeShell.tabIndex.value = _index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [HomeScreen(key: _homeKey), const MineScreen()],
      ),
      bottomNavigationBar: AppTabBar(
        currentIndex: _index,
        onTap: (value) async {
          final previous = _index;
          if (value != previous && !AppInfoManager.isLoggedIn()) {
            await NavHelper.toLogin();
            return;
          }
          setState(() => _index = value);
          HomeShell.tabIndex.value = value;
          if (value == 0 && previous != 0) {
            _homeKey.currentState?.refresh();
          }
        },
      ),
    );
  }
}
