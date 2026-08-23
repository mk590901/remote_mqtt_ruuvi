import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ruuvi_page.dart';
import '../ui_blocs/page_bloc.dart';
import 'home_page.dart';
import 'help_page.dart';

class MainAppPage extends StatelessWidget {
  const MainAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PageBloc, PageState>(
      builder: (context, state) {
        switch (state.state) {
          case PageStates.home:
            return const HomePage();
          case PageStates.help:
            return const HelpPage();
          case PageStates.dashboard:
            return const RuuviPage();
        }
      },
    );
  }
}