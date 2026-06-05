import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/resource_services.dart';

class MaintenanceLogsScreen extends StatefulWidget {
  const MaintenanceLogsScreen({super.key});

  @override
  State<MaintenanceLogsScreen> createState() => _MaintenanceLogsScreenState();
}

class _MaintenanceLogsScreenState extends State<MaintenanceLogsScreen> {
  final _service = MaintenanceLogsService();
  List<MaintenanceLogModel> _logs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _service.index();
      if (mounted) {
        setState(() {
          _logs = res.data;
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

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs de Manutenção'),
        actions: [
          if (!_loading && _logs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_logs.length} registros',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
        ],
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
                      const Text('Falha ao carregar logs'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _load,
                          child: const Text('Tentar novamente')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _logs.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_rounded,
                                  size: 56,
                                  color: MaintSysColors.textMuted),
                              SizedBox(height: 12),
                              Text(
                                'Nenhum log registrado',
                                style: TextStyle(
                                    color: MaintSysColors.textMuted,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _logs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final log = _logs[i];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: MaintSysColors.statusMaint
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.build_outlined,
                                        color: MaintSysColors.statusMaint,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            log.action,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                          ),
                                          if (log.defectType != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              log.defectType!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.precision_manufacturing_rounded,
                                                size: 12,
                                                color:
                                                    MaintSysColors.textMuted,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Máquina #${log.machineId}',
                                                style: const TextStyle(
                                                  color:
                                                      MaintSysColors.textMuted,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              if (log.user != null) ...[
                                                const SizedBox(width: 12),
                                                const Icon(
                                                  Icons.person_outline_rounded,
                                                  size: 12,
                                                  color:
                                                      MaintSysColors.textMuted,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  log.user!.name,
                                                  style: const TextStyle(
                                                    color: MaintSysColors
                                                        .textMuted,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (log.createdAt != null)
                                      Text(
                                        _formatDate(log.createdAt!),
                                        style: const TextStyle(
                                          color: MaintSysColors.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
