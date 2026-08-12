// help_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../gui_adapter/service_adapter.dart';
import '../app_navigation_bar.dart';
import '../ui_blocs/page_bloc.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {

    List<String> initialLines = [
      'Name: [${ServiceAdapter.instance()?.appName()}]',
      'Version: [${ServiceAdapter.instance()?.appVersion()}]',
      'Build Signature:',
    ];

    List<String> parts = splitStringIntoParts(ServiceAdapter.instance()?.appSignature(), 2);

    final bloc = context.read<PageBloc>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        debugPrint('******* onPopInvoked($didPop) *******');
        if (didPop) {
          return;
        }
        bloc.add(HomeEvent());
      },

      child: Scaffold(
        appBar: const AppNavigationBar(currentPage: PageStates.help),

        body: SingleChildScrollView(//Center(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //...title.map((line) => Text(line, style: const TextStyle(fontSize: 20))),
                const SizedBox(height: 32,),

                Icon(Icons.help_outline, size: 80,),
                SizedBox(height: 16),
                Text('About ${ServiceAdapter.instance()?.platform()} App', style: TextStyle(fontSize: 24)),

                const SizedBox(height: 32,),

                ...initialLines.map((line) => Text(line, style: const TextStyle(fontSize: 16))),
                const SizedBox(height: 8,),
                ...parts.map((part) => Text(part, style: const TextStyle(fontSize: 12))),

              ],
            ),
          ),

        ),
      ),
    );
  }

  List<String> splitStringIntoParts(String? input, int parts) {
    if (input == null || input.isEmpty) {
      return [];
    }
    int partLength = (input.length / parts).ceil();
    List<String> result = [];

    for (int i = 0; i < parts; i++) {
      int start = i * partLength;
      int end = (i + 1) * partLength;
      result.add(input.substring(start, end.clamp(0, input.length)));
    }
    return result;
  }

}
