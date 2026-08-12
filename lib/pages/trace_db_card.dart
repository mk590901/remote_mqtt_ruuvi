import 'package:flutter/material.dart';
import '../models/trace.dart';
import '../utils.dart';

class TraceDbCard extends StatelessWidget {
  final Trace trace;

  final bool isLast;
  final bool isOnline;

  const TraceDbCard({
    required this.trace,
    required this.isOnline,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
      return Card(
        margin: EdgeInsets.only(bottom: isLast ? 80 : 12),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    getIcon(trace.parameter('measure')?.value??''),
                    //Icons.bluetooth,
                    size: 32, color: isOnline ? Colors.blue : Colors.grey,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      trace.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              ...trace.parameters.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('${p.name}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(p.value)),
                  ],
                ),
              )),
            ],
          ),
        ),
      );
    //);
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Icon(Icons.delete, color: Colors.white, size: 32),
    );
  }
}
