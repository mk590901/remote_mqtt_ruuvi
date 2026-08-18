import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/ruuvi_bloc/ruuvi_bloc.dart';
import '../services/ruuvi_bloc/ruuvi_event.dart';
import '../services/ruuvi_bloc/ruuvi_state.dart';
import '../models/ruuvi_analysis.dart';
import '../models/ruuvi_data.dart';

class RuuviPage extends StatelessWidget {
  const RuuviPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RuuviTag'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<RuuviBloc>().add(const ClearHistory());
            },
          ),
        ],
      ),
      body: BlocBuilder<RuuviBloc, RuuviState>(
        builder: (context, state) {
          final tags = state.sortedTags;

          return Column(
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
                    style: Theme.of(context).textTheme.titleMedium,
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
          );
        },
      ),
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
              Text('$title: ${t.current.toStringAsFixed(2)} $unit'),
              if (t.slopePerHour != null) ...[
                const SizedBox(width: 8),
                Text(
                  '(${t.slopePerHour! >= 0 ? '+' : ''}${t.slopePerHour!.toStringAsFixed(2)}/h)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data.mac,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
            Text(
              'Temperature: ${data.temperature?.toStringAsFixed(2) ?? '—'} °C',
            ),
            Text(
              'Humidity:    ${data.humidity?.toStringAsFixed(2) ?? '—'} %',
            ),
            Text(
              'Pressure:    ${data.pressure?.toStringAsFixed(1) ?? '—'} hPa',
            ),
            Text(
              'Battery:     ${data.batteryVoltage?.toStringAsFixed(3) ?? '—'} V'
                  '${data.txPower != null ? '  ·  TX ${data.txPower} dBm' : ''}',
            ),
            Text(
              'Accel:       '
                  'X=${data.accelX?.toStringAsFixed(3) ?? '—'}  '
                  'Y=${data.accelY?.toStringAsFixed(3) ?? '—'}  '
                  'Z=${data.accelZ?.toStringAsFixed(3) ?? '—'} g',
            ),
            Text(
              'Movement:    ${data.movementCounter ?? '—'}'
                  '  ·  Seq: ${data.sequence ?? '—'}'
                  '  ·  RSSI: ${data.rssi} dBm',
            ),
          ],
        ),
      ),
    );
  }
}
