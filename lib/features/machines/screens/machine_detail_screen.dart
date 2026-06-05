import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/resource_services.dart';

class MachineDetailScreen extends StatefulWidget {
  final int machineId;
  const MachineDetailScreen({super.key, required this.machineId});

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen>
    with SingleTickerProviderStateMixin {
  final _machinesService = MachinesService();
  late TabController _tabCtrl;

  MachineModel? _machine;
  List<MachineReadingModel> _readings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _machinesService.show(widget.machineId),
        _machinesService.readings(widget.machineId),
      ]);
      if (mounted) {
        setState(() {
          _machine = results[0] as MachineModel;
          _readings = results[1] as List<MachineReadingModel>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_machine?.name ?? 'Máquina'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: MaintSysColors.primary,
          labelColor: MaintSysColors.primary,
          unselectedLabelColor: MaintSysColors.textSecondary,
          tabs: const [
            Tab(text: 'Visão Geral'),
            Tab(text: 'Sensores'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          size: 48, color: MaintSysColors.statusError),
                      const SizedBox(height: 12),
                      const Text('Falha ao carregar dados'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _machine == null
                  ? const Center(child: Text('Máquina não encontrada'))
                  : TabBarView(
                      controller: _tabCtrl,
                      children: [
                        _OverviewTab(machine: _machine!),
                        _SensorsTab(readings: _readings),
                        _HistoryTab(machineId: widget.machineId),
                      ],
                    ),
    );
  }
}

// =====================================================
//  TAB 1 - Visão Geral
// =====================================================
class _OverviewTab extends StatelessWidget {
  final MachineModel machine;
  const _OverviewTab({required this.machine});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: MaintSysColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing_rounded,
                    color: MaintSysColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(machine.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(
                        machine.model,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                MachineStatusBadge(status: machine.status),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Info grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _InfoCard(label: 'Modelo', value: machine.model),
            _InfoCard(label: 'Serial', value: machine.serialNumber),
            _InfoCard(label: 'Localização', value: machine.location ?? '—'),
            _InfoCard(
              label: 'Instalado em',
              value: machine.installedAt != null
                  ? _formatDate(machine.installedAt!)
                  : '—',
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
//  TAB 2 - Sensores  (EAV: sensor_key / value / unit)
// =====================================================

const _sensorMeta = {
  'temperatura': (
    label: 'Temperatura',
    icon: Icons.thermostat_rounded,
    color: MaintSysColors.statusError,
  ),
  'rpm': (
    label: 'RPM',
    icon: Icons.rotate_right_rounded,
    color: MaintSysColors.primary,
  ),
  'vibracao': (
    label: 'Vibração',
    icon: Icons.waves_rounded,
    color: MaintSysColors.statusWarn,
  ),
  'eficiencia': (
    label: 'Eficiência',
    icon: Icons.speed_rounded,
    color: MaintSysColors.statusOk,
  ),
  'corrente': (
    label: 'Corrente',
    icon: Icons.bolt_rounded,
    color: MaintSysColors.accent,
  ),
  'pressao': (
    label: 'Pressão',
    icon: Icons.compress_rounded,
    color: MaintSysColors.statusMaint,
  ),
};

class _SensorsTab extends StatelessWidget {
  final List<MachineReadingModel> readings;
  const _SensorsTab({required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors_off_rounded,
                size: 48, color: MaintSysColors.textMuted),
            SizedBox(height: 12),
            Text('Nenhuma leitura disponível',
                style: TextStyle(color: MaintSysColors.textMuted)),
            SizedBox(height: 4),
            Text('Aguardando dados via MQTT',
                style: TextStyle(
                    color: MaintSysColors.textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    // Group by sensor_key, keep last 20 per key
    final Map<String, List<MachineReadingModel>> grouped = {};
    for (final r in readings) {
      grouped.putIfAbsent(r.sensorKey, () => []).add(r);
    }
    for (final key in grouped.keys) {
      if (grouped[key]!.length > 20) {
        grouped[key] = grouped[key]!.sublist(grouped[key]!.length - 20);
      }
    }

    final orderedKeys = _sensorMeta.keys
        .where((k) => grouped.containsKey(k))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: orderedKeys.map((key) {
        final meta = _sensorMeta[key]!;
        final rows = grouped[key]!;
        return _SensorChart(
          title: meta.label,
          icon: meta.icon,
          color: meta.color,
          readings: rows,
          unit: rows.first.unit,
        );
      }).toList(),
    );
  }
}

class _SensorChart extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<MachineReadingModel> readings;
  final String unit;

  const _SensorChart({
    required this.title,
    required this.icon,
    required this.color,
    required this.readings,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final spots = readings.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final latest = readings.isNotEmpty ? readings.last.value : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  '${latest.toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: MaintSysColors.border,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
//  TAB 3 - Histórico
// =====================================================
class _HistoryTab extends StatefulWidget {
  final int machineId;
  const _HistoryTab({required this.machineId});

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  final _logsService = MaintenanceLogsService();
  List<MaintenanceLogModel> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _logsService.index(machineId: widget.machineId);
      if (mounted) {
        setState(() {
          _logs = res.data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_logs.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum registro de manutenção',
          style: TextStyle(color: MaintSysColors.textMuted),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final log = _logs[i];
          return ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: MaintSysColors.statusMaint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.build_outlined,
                color: MaintSysColors.statusMaint,
                size: 18,
              ),
            ),
            title: Text(log.action,
                style: Theme.of(context).textTheme.bodyLarge),
            subtitle: log.defectType != null
                ? Text(log.defectType!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis)
                : null,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (log.user != null)
                  Text(
                    log.user!.name,
                    style: const TextStyle(
                        color: MaintSysColors.textSecondary, fontSize: 11),
                  ),
                if (log.createdAt != null)
                  Text(
                    _shortDate(log.createdAt!),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _shortDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
