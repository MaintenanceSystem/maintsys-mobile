import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/resource_services.dart';

class ServiceOrdersScreen extends StatefulWidget {
  const ServiceOrdersScreen({super.key});

  @override
  State<ServiceOrdersScreen> createState() => _ServiceOrdersScreenState();
}

class _ServiceOrdersScreenState extends State<ServiceOrdersScreen> {
  final _service = ServiceOrdersService();
  List<ServiceOrderModel> _orders = [];
  bool _loading = true;
  String _statusFilter = 'todos';

  static const _statuses = [
    'todos', 'open', 'in_progress', 'completed', 'cancelled'
  ];

  static const _statusLabels = {
    'todos': 'Todos',
    'open': 'Abertas',
    'in_progress': 'Em Andamento',
    'completed': 'Concluídas',
    'cancelled': 'Canceladas',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _service.index(
        status: _statusFilter == 'todos' ? null : _statusFilter,
      );
      if (mounted) {
        setState(() {
          _orders = res.data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String s) => switch (s) {
        'open' => MaintSysColors.statusWarn,
        'in_progress' => MaintSysColors.primary,
        'completed' => MaintSysColors.statusOk,
        'cancelled' => MaintSysColors.textMuted,
        _ => MaintSysColors.textMuted,
      };

  String _statusLabel(String s) => _statusLabels[s] ?? s;

  String _typeLabel(String t) =>
      t == 'preventive' ? 'Preventiva' : 'Corretiva';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: _statuses.map((s) {
                final selected = s == _statusFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_statusLabels[s] ?? s),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _statusFilter = s);
                      _load();
                    },
                    backgroundColor: MaintSysColors.surfaceVariant,
                    selectedColor: MaintSysColors.primary,
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.white
                          : MaintSysColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _orders.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma ordem encontrada',
                        style: TextStyle(color: MaintSysColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final o = _orders[i];
                        final statusColor = _statusColor(o.status);
                        return Card(
                          child: ListTile(
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.assignment_outlined,
                                  color: statusColor),
                            ),
                            title: Text(
                              'OS #${o.id} — ${_typeLabel(o.type)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              o.technician?.name ?? 'Sem técnico atribuído',
                              style: const TextStyle(
                                  color: MaintSysColors.textSecondary,
                                  fontSize: 12),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _statusLabel(o.status),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Máq #${o.machineId}',
                                  style: const TextStyle(
                                      color: MaintSysColors.textMuted,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                            onTap: () => context.go('/orders/${o.id}'),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
