import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/ruuvi_bloc/ruuvi_bloc.dart';
import '../services/ruuvi_bloc/ruuvi_state.dart';
import '../models/ruuvi_analysis.dart';
import '../models/ruuvi_data.dart';
import '../app_navigation_bar.dart';
import '../ui_blocs/page_bloc.dart';

class RuuviPage extends StatelessWidget {
  const RuuviPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PageBloc>();
    return BlocBuilder<RuuviBloc, RuuviState>(
      builder: (context, state) {
        final tags = state.sortedTags;
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

            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Analysis panel
                if (state.analysis != null)
                  _AnalysisPanel(analysis: state.analysis!),

                // Tags list
                Expanded(
                  child: tags.isEmpty
                      ? Center(
                    child: Text(
                      'No data',
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium,
                    ),
                  )
                      : ListView.builder(
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      return _RuuviCard(data: tags[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

// ─────────────────────────────────────────────────────────────
// Analysis panel
// ─────────────────────────────────────────────────────────────

class _AnalysisPanel extends StatelessWidget {
  final RuuviAnalysis analysis;

  const _AnalysisPanel({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis (${analysis.sampleCount} samples)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            _metricRow('Temperature', analysis.temperature, '°C'),
            _metricRow('Humidity', analysis.humidity, '%'),
            _metricRow('Pressure', analysis.pressure, 'hPa'),
            _metricRow('Battery', analysis.battery, 'V'),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(String title, MetricTrend t, String unit) {
    final color = switch (t.anomaly) {
      AnomalyLevel.strong => Colors.red,
      AnomalyLevel.mild => Colors.orange,
      AnomalyLevel.none => Colors.green,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: color),
              const SizedBox(width: 6),
              // Name — left
              Expanded(
                child: Text(title),
              ),
              // Value + unit (+ slope) — right
              Text(
                '${t.current.toStringAsFixed(2)} $unit'
                    '${t.slopePerHour != null ? '  (${t.slopePerHour! >= 0 ? '+' : ''}${t.slopePerHour!.toStringAsFixed(2)}/h)' : ''}',
                textAlign: TextAlign.right,
              ),
            ],
          ),
          if (t.anomalyReason != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 2),
              child: Text(
                t.anomalyReason!,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ),
          if (t.avg1h != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 2),
              child: Text(
                'avg 1h: ${t.avg1h!.toStringAsFixed(2)}'
                    '  ·  6h: ${t.avg6h?.toStringAsFixed(2) ?? '—'}'
                    '  ·  24h: ${t.avg24h?.toStringAsFixed(2) ?? '—'}',
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

}

// ─────────────────────────────────────────────────────────────
// Tag card
// ─────────────────────────────────────────────────────────────

class _RuuviCard extends StatelessWidget {
  final RuuviData data;

  const _RuuviCard({required this.data});

  // "Ruuvi 4D1B"

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Ruuvi 4D1B',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 8),

            // MAC + orientation
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.mac,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  data.orientation.icon,
                  size: 18,
                  color: Colors.teal,
                ),
                const SizedBox(width: 6),
                Text(
                  data.orientation.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _param('Temperature', data.temperature, '°C', digits: 2),
            _param('Humidity', data.humidity, '%', digits: 2),
            _param('Pressure', data.pressure, 'hPa', digits: 1),
            _param(
              'Battery Voltage/TX Power',
              data.batteryVoltage,
              'V',
              digits: 3,
              trailing: data.txPower != null ? ' / ${data.txPower} dBm' : null,
            ),
            _paramRow(
              'Acceleration X/Y/Z',
              '${data.accelX?.toStringAsFixed(3) ?? '—'} / '
                    '${data.accelY?.toStringAsFixed(3) ?? '—'} / '
                    '${data.accelZ?.toStringAsFixed(3) ?? '—'} g',
            ),
            _paramRow(
              'Movement Counter',
              '${data.movementCounter ?? '—'}'
            ),
            _paramRow(
              'Sequence',
              '${data.sequence ?? '—'}',
            ),
            _paramRow(
              'RSSI',
                  '${data.rssi} dBm',
            ),
            _paramRow(
              'Last Update Time',
              '${data.lastSeen}',
            ),

          ],
        ),
      ),
    );
  }

  Widget _param(
      String title,
      double? value,
      String unit, {
        int digits = 2,
        String? trailing,
      }) {
    final text = value != null
        ? '${value.toStringAsFixed(digits)} $unit${trailing ?? ''}'
        : '—';
    return _paramRow(title, text);
  }

  Widget _paramRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(value, textAlign: TextAlign.right),
        ],
      ),
    );
  }
}
