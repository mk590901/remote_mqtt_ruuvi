// control_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../ui_blocs/page_bloc.dart';

class ControlPanel extends StatelessWidget {
  final PageStates currentPage;

  const ControlPanel({
    super.key,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PageBloc>();

    final buttons = <Widget>[];

    // Home
    if (currentPage != PageStates.home) {
      buttons.add(_NavButton(
        icon: Icons.keyboard_alt_outlined,
        onPressed: () => bloc.add(HomeEvent()),
      ));
    }

    // Trace
    // if (currentPage != PageStates.trace) {
    //   buttons.add(_NavButton(
    //     icon: Icons.event_note_outlined,
    //     onPressed: () => bloc.add(TraceEvent()),
    //   ));
    // }
    //
    // // DB
    // if (currentPage != PageStates.db) {
    //   buttons.add(_NavButton(
    //     icon: Icons.storage,
    //     onPressed: () => bloc.add(DBEvent()),
    //   ));
    // }

    // Dashboard
    if (currentPage != PageStates.dashboard) {
      buttons.add(_NavButton(
        icon: Icons.bar_chart_sharp,
        onPressed: () => bloc.add(DashboardEvent()),
      ));
    }

    // Help
    if (currentPage != PageStates.help) {
      buttons.add(_NavButton(
        icon: Icons.help_outline,
        onPressed: () => bloc.add(HelpEvent()),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(2.0), //const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end/*spaceEvenly*/,
        children: buttons,
      ),
    );
  }
}

// Navigation button widget
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _NavButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 20.0,
    );

  }
}