// home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../app_navigation_bar.dart';
import 'blink_Icon.dart';
import '../ui_blocs/page_bloc.dart';
import '../ui_blocs/list_bloc.dart';
import '../ui_blocs/app_bloc.dart';
import '../ui_blocs/remote_ble_bloc.dart';
import '../../utils.dart';

class HomePage extends StatelessWidget {

  static bool _firstTime = true;

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListBloc(),
      child: PopScope(
        canPop: false, // Disable the default behavior of the "back" button
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return; // If pop has already been executed, do nothing
          // Show the dialog box
          final result = await showAppExitDialog(context);

          // Processing user selection
          await reaction(result, context);
          // For 'ignore' we do nothing, the dialog just closes
        },

        child: Scaffold(
          appBar: const AppNavigationBar(currentPage: PageStates.home),
          body: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              //
              //   child: BlocBuilder<ListBloc, ListState>(
              //     builder: (context, state) {
              //
              //       if (_firstTime) {
              //         WidgetsBinding.instance.addPostFrameCallback((_){
              //           context.read<ListBloc>().add(SelectOptionEvent(ListBloc.items[0]),);
              //         });
              //         _firstTime = false;
              //       }
              //
              //       return Card(
              //         elevation: 4,
              //         color: Theme.of(
              //           context,
              //         ).cardColor, // ← automatically adjusts
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //
              //         child: Padding(
              //           padding: const EdgeInsets.all(12),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               const Text(
              //                 'Select BLE device:',
              //                 style: TextStyle(fontWeight: FontWeight.bold),
              //               ),
              //               const SizedBox(height: 8),
              //               BlocBuilder<ListBloc, ListState>(
              //                 builder: (context, state) {
              //                   return DropdownButtonFormField<String>(
              //                     initialValue: state.selectedOption,
              //                     isExpanded: true,
              //                     items: ListBloc.items.map((String value) {
              //                       return DropdownMenuItem<String>(
              //                         value: value,
              //                         child: Text(
              //                           value,
              //                           overflow: TextOverflow.ellipsis,
              //                           style: TextStyle(fontSize: 12),
              //                         ),
              //                       );
              //                     }).toList(),
              //                     onChanged: (newValue) {
              //                       if (newValue != null) {
              //                         context.read<ListBloc>().add(SelectOptionEvent(newValue),);
              //                       }
              //                     },
              //                   );
              //                 },
              //               ),
              //             ],
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),

              Expanded(

                child: BlocListener<RemoteBleBloc, RemoteBleState>(
                  listenWhen: (previous, current) =>
                  previous.error != current.error && current.error == true,

                  listener: (context, state) {
                    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error_outline_sharp, color: Theme.of(context).colorScheme.onPrimary,),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(state.errorMessage?? "?",),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          duration: const Duration(seconds: 5),
                          margin: const EdgeInsets.fromLTRB(8, 0, 8, 16), // left, top, right, bottom
                          // Additions
                          elevation: 8,
                          dismissDirection: DismissDirection.horizontal,
                        ),
                      );
                      // Reset error
                      context.read<RemoteBleBloc>().add(ClearError());
                    }
                  },

                  child: BlocBuilder<RemoteBleBloc, RemoteBleState>(
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                        ),
                        child: Card(
                          color: Theme.of(
                            context,
                          ).cardColor, // automatically adjusts
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,

                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [

                                    Icon(
                                      Icons.commit_sharp,
                                      color: state.isOnline ? Colors.blue : Colors.white12, size: 28,),

                                    const SizedBox(width: 1),

                                    BlinkingColorIcon(
                                      //  bar_chart_sharp
//                                        icon: getIcon(state.measureType??'')??Icons.hourglass_empty,
                                        icon: state.isScanning ? Icons.gps_fixed_sharp : Icons.gps_not_fixed_sharp,
                                        blinking: state.isScanning ? true : false, //getBlinking(state.state??'')/*true*/,
                                        size: 24),

                                    const SizedBox(width: 8),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            state.deviceName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(state.macAddress),
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          // Text(
                                          //   getName(state.measureType??'')??'',
                                          //   style: const TextStyle(
                                          //     fontSize: 14,
                                          //     fontWeight: FontWeight.bold,
                                          //   ),
                                          // ),
                                          //Text("114/86 mmHg"),
                                          Text(
                                            state.value??'',// "114/86 mmHg",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // if (state.isOnline)
                                    // Icon(
                                    //   Icons.commit_sharp,
                                    //   color: state.isOnline ? Colors.blue : Colors.grey, size: 28,),
                                  ],
                                ),

                                const Divider(height: 24),

                                _infoRow('RSSI', state.rssi == 0 ? "-" : '${state.rssi} dBm'),
                                _infoRow(
                                  'Transmitter type',
                                  state.transmitterName,
                                ),
                                _infoRow('Transmitter MAC', state.transmitterMAC),
                                _infoRow(
                                  'Time',
                                  discoveryTime(state.discoveryTime),
                                ),

                                const SizedBox(height: 24),

                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [

                                    // _actionButton(
                                    //     Icons.play_arrow, 'Start Session', colorStartSession(state),
                                    //         () => context.read<RemoteBleBloc>().add(StartSession())),

                                    _actionButton(
                                        Icons.sync_sharp, 'Sync', colorCheckSink(state),
                                            () => context.read<RemoteBleBloc>().add(Sync())),

                                    _actionButton(
                                        Icons.search, 'Start Scan', colorStartScan(state),
                                            () => context.read<RemoteBleBloc>().add(StartScan())),

                                    _actionButton(
                                        Icons.stop, 'Final Scan', colorFinalScan(state),
                                            () => context.read<RemoteBleBloc>().add(FinalScan())),

                                    _actionButton(
                                        Icons.stop_circle, 'Stop ESP32-S3', colorFinalSession(state),
                                            () => context.read<RemoteBleBloc>().add(FinalSession())),

                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),



        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _actionButton(
      IconData icon,
      String label,
      Color color,
      VoidCallback onPressed,
      ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<String?> showAppExitDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Application exit',
          style: TextStyle(fontSize: 16, color: Colors.blueAccent),
        ),
        content: Text(
          'Choose one of app exit option:\n\n\t - Ignore: stay in application\n\t - Exit: stop connection and exit',
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
        actions: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'ignore'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(40, 36),
                      textStyle: TextStyle(fontSize: 10),
                    ),
                    child: Text('Ignore'),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, 'exit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(20, 36),
                      textStyle: TextStyle(fontSize: 10),
                    ),
                    child: Text('Exit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> reaction(String? result, BuildContext context) async {
    if (!context.mounted) {
      return;
    }
    if (result == 'close') {
      await SystemNavigator.pop();
    } else if (result == 'exit') {
      if (context.mounted) {
        //context.read<TraceDbBloc>().add(StopPolling());
        print("context.read<AppBloc>().add(StopService())");
        context.read<AppBloc>().add(StopService());
      } else {
        print("No mounted");
      }
      await SystemNavigator.pop();
    }
  }

  int index(RemoteBleState state) {
    int idx = 4/*4*/;
    if  (!state.isOnline) {
      return idx;
    }
    // if (/*!state.isSessionStarted &&*/ !state.isScanning) {
    //   idx = 0;
    // }
    // else
    // if (/*!state.isSessionStarted &&*/  state.isScanning) {
    //   idx = 1;
    // }
    else
    if ( /*state.isSessionStarted &&*/ !state.isScanning) {
      idx = 2;
    }
    else
    if ( /*state.isSessionStarted &&*/  state.isScanning) {
      idx = 3;
    }
    return idx;
  }

  Color colorCheckSink(RemoteBleState state) {
    List<Color> list = [Colors.teal, Colors.teal, Colors.teal, Colors.teal, Colors.teal];
    return list[index(state)];
  }

  Color colorStartSession(RemoteBleState state) {
    List<Color> list = [Colors.green, Colors.grey, Colors.green.shade100, Colors.green.shade100, Colors.green.shade100];
    return list[index(state)];
  }

  Color colorStartScan(RemoteBleState state) {
    List<Color> list = [Colors.blue.shade100, Colors.grey, Colors.blue, Colors.blue.shade100, Colors.blue.shade100];
    return list[index(state)];
  }

  Color colorFinalScan(RemoteBleState state) {
    List<Color> list = [Colors.orange.shade100, Colors.grey, Colors.orange.shade100, Colors.orange, Colors.orange.shade100,];
    return list[index(state)];
  }

  Color colorFinalSession(RemoteBleState state) {
    List<Color> list = [Colors.red.shade100, Colors.grey, Colors.red, Colors.red, Colors.red.shade100,];
    return list[index(state)];
  }

}

