import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/alert_log_controller.dart';
import '../../models/alert_log_model.dart';

class GraphPage extends StatelessWidget {
  const GraphPage({super.key});

  @override
  Widget build(BuildContext ctx) {
    final ctrl = Get.find<AlertLogController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas de Uso')),
      body: FutureBuilder<List<AlertLogModel>>(
        future: ctrl.fetchAllLocal(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snap.data!;

          final hourCounts = <int, int>{};
          final btnCounts = <String, int>{};

          for (var log in logs) {
            hourCounts[log.timestamp.hour] =
                (hourCounts[log.timestamp.hour] ?? 0) + 1;
            btnCounts[log.buttonId] = (btnCounts[log.buttonId] ?? 0) + 1;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Alertas por Hora',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(height: 200, child: _buildBarChart(hourCounts)),
              const SizedBox(height: 32),
              const Text('Alertas por Botón',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(height: 200, child: _buildPieChart(btnCounts)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBarChart(Map<int, int> data) {
    final barGroups = data.entries
        .map((e) => BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(toY: e.value.toDouble(), color: Colors.blue),
              ],
            ))
        .toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceBetween,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}:00',
                  style: const TextStyle(fontSize: 10)),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildPieChart(Map<String, int> data) {
    final total = data.values.fold<int>(0, (sum, val) => sum + val);
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange];
    int colorIndex = 0;

    final sections = data.entries.map((e) {
      final value = e.value.toDouble();
      final percent = (value / total * 100).toStringAsFixed(1);
      final color = colors[colorIndex++ % colors.length];

      return PieChartSectionData(
        value: value,
        title: '${e.key}\n$percent%',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );
  }
}
