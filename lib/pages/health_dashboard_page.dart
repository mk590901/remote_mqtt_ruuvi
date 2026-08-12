
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../gui_adapter/service_adapter.dart';
import '../health_dashboard/health_ai_model.dart';
import '../health_dashboard/bloc/health_bloc.dart';
import '../health_dashboard/bloc/health_state.dart';
import '../health_dashboard/bloc/health_event.dart';
import '../app_navigation_bar.dart';
import '../ui_blocs/page_bloc.dart';
import '../models/trace_db.dart';

int count = -1;

class HealthDashboardPage extends StatelessWidget {
  const HealthDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PageBloc>();
    return BlocBuilder<HealthBloc, HealthState>(
      builder: (context, state) {
        final recent = state.model.aggregatedData.isNotEmpty ? state.model.aggregatedData.last : null;
        final alerts = state.analysis['alerts'] as List<dynamic>? ?? [];
        final anomaly = state.analysis['anomaly'] as Map<String, dynamic>?;

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
              appBar: const AppNavigationBar(currentPage: PageStates.dashboard),

          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center/*start*/,
              children: [
                // 1. Health Score Card
                Card(
                  elevation: 4,
                  //color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text('Overall Health Score', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: 8),
                        Text(
                          '${state.analysis['healthScore'] ?? 0}',
                          style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, /*color: Colors.blue*/),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Current State
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.health_and_safety, color: Colors.green, size: 50),
                    title: const Text('Current State', style: TextStyle(fontSize: 18)),
                    subtitle: Text(
                      state.analysis['currentState'] ?? 'No data available',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Alerts
                if (alerts.isNotEmpty)
                  Card(
                    //color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('⚠️ Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ...alerts.map((alert) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('• $alert', style: const TextStyle(fontSize: 16)),
                          )),
                        ],
                      ),
                    ),
                  ),

                if (anomaly != null && anomaly['isAnomaly'] == true)
                  Card(
                    //color: Colors.orange.shade50,
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 40),
                      title: const Text('Anomaly Detected'),
                      subtitle: Text(anomaly['message'] ?? ''),
                      trailing: Text(
                        'Score: ${anomaly['score']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // 4. Metrics
                const Text('Latest Metrics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _metricCard('Heart Rate',       recent?.hr, 'bpm'),
                _metricCard('SpO₂',             recent?.spo2, '%'),
                _metricCard('HRV',              recent?.hrv, 'ms'),
                _metricCard('Stress',           recent?.stress, ''),
                _metricCard('Blood Sugar',      recent?.bloodSugar, 'mmol/L'),
                _metricCard('Temperature',      recent?.temp, '°C'),
                _metricCard('Blood Pressure',   _formatBP(recent), 'mmHg'),
                const SizedBox(height: 32),

                // 5. Trends & Correlations
                const SizedBox(height: 32),

// Trends & Insights
                const Text('Trends & Insights', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                _metricCard('HR', state.analysis['trends']?['hrTrend'], ''),
                _metricCard('HRV', state.analysis['trends']?['hrvTrend'], ''),
                _metricCard('Stress', state.analysis['trends']?['stressTrend'], ''),
                _metricCard('Blood Sugar', state.analysis['trends']?['bloodSugarTrend'], ''),
                //_metricCard('HR-HRV Correlation', state.analysis['correlations']?['hr_hrv'], ''),

                _metricCard(
                  'HR-HRV Correlation',
                  state.analysis['correlations']?['hr_hrv_text'],
                  '',
                ),
                _metricCard(
                  'Stress-HRV Correlation',
                  state.analysis['correlations']?['stress_hrv_text'],
                  '',
                ),
                _metricCard(
                  'Data Completeness',
                  (state.analysis['completeness'] as num?) != null
                      ? (state.analysis['completeness'] as num) * 100
                      : null,
                  '%',
                ),
              ],
            ),
          ),

            // floatingActionButton: FloatingActionButton(
            //   child: const Icon(Icons.add),
            //   onPressed: () => addData(context),
            // ),

          ),
        );
      },
    );
  }

  void addData(BuildContext context) {
    print ('******* add data *******');

    List<TraceDb> records = ServiceAdapter.instance()?.getAllData()??[];
    if (records.isEmpty) {
      return;
    }

    count++;
    if (count >= records.length) {
      count = 0;
    }
    TraceDb record = records[count];
    ServiceAdapter.instance()?.updateIncomingData(record);
    context.read<HealthBloc>().add(AddRawRecord());
  }

  Widget _metricCard(String label, dynamic value, String unit) {
    final display = _formatDouble(value, value is int ? 0 : 1);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(label),
        trailing: Text('$display $unit', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  String _formatBP(HealthDataPoint? p) {
    if (p == null) return '—';
    if (p.bpSyst != null && p.bpDiast != null) {
      return '${p.bpSyst!.toStringAsFixed(0)}/${p.bpDiast!.toStringAsFixed(0)}';
    }
    return '—';
  }

  String _formatDouble(dynamic value, [int fractionDigits = 2]) {
    if (value is String) {
      return value;
    }
    if (value == null) return '—';
    final numValue = value as num?;
    if (numValue == null) return '—';
    return numValue.toStringAsFixed(fractionDigits);
  }

}
