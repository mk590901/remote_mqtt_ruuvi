// app_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ui_blocs/page_bloc.dart';
import 'pages/mqtt_panel.dart';
import 'pages/control_panel.dart';
import 'ui_blocs/theme_cubit.dart';

class AppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final PageStates currentPage;

  const AppNavigationBar({super.key, required this.currentPage});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    return AppBar(
      title: Text(_getTitle(currentPage),
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.normal),),
      leading: IconButton(
        icon: const Icon(Icons.brightness_6),
        tooltip: 'Switch theme',
        onPressed: () => themeCubit.toggleTheme(),),
        actions: [ControlPanel(currentPage: currentPage), MQTTPanel()],
    );
  }

  String _getTitle(PageStates state) {
    switch (state) {
      case PageStates.home:
        return 'Control Panel';
      // case PageStates.trace:
      //   return 'Trace';
      // case PageStates.db:
      //   return 'Database';
      case PageStates.help:
        return 'About';
      case PageStates.dashboard:
        return 'Dashboard';
    }
  }
}

