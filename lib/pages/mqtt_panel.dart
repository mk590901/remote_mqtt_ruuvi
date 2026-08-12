import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../ui_blocs/mqtt_bloc.dart';
import '../../ui_blocs/app_bloc.dart';

// MQTTPanel StatelessWidget
class MQTTPanel extends StatelessWidget {
  const MQTTPanel({super.key});

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<AppBloc>().state.isRunning) {
        context.read<AppBloc>().add(StartService());
      }
    });

    return BlocBuilder<MqttBloc, MqttState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.circle_sharp, // Placeholder for connected icon
              color: state.isConnected ? Colors.green : Colors.red, size: 16,
            ),
            const SizedBox(width: 1),
            SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(strokeWidth: 1,
                color: state.inProgress ? Colors.blue : Colors.transparent,
              ),
            ),
            const SizedBox(width: 1),
            Icon(
              Icons.circle_sharp, // Placeholder for subscribed icon
              color: state.isSubscribed ? Colors.green : Colors.red, size: 16,
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }
}
