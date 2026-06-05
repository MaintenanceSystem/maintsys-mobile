import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/resource_services.dart';

class ServiceOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const ServiceOrderDetailScreen({super.key, required this.orderId});

  @override
  State<ServiceOrderDetailScreen> createState() =>
      _ServiceOrderDetailScreenState();
}

class _ServiceOrderDetailScreenState extends State<ServiceOrderDetailScreen> {
  final _service = ServiceOrdersService();
  ServiceOrderModel? _order;
  bool _loading = true;
  bool _updating = false;
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
      final order = await _service.show(widget.orderId);
      if (mounted) setState(() { _order = order; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _advanceStatus() async {
    final order = _order;
    if (order == null) return;

    final nextStatus = switch (order.status) {
      'open' => 'in_progress',
      'in_progress' => 'completed',
      _ => null,
    };
    if (nextStatus == null) return;

    setState(() => _updating = true);
    try {
      final updated = await _service.update(order.id, {'status': nextStatus});
      if (mounted) setState(() { _order = updated; _updating = false; });
    } catch (_) {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_order != null ? 'OS #${_order!.id}' : 'Ordem'),
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
                      const Text('Falha ao carregar ordem'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _load,
                          child: const Text('Tentar novamente')),
                    ],
                  ),
                )
              : _order == null
                  ? const Center(child: Text('Ordem não encontrada'))
                  : _buildBody(),
    );
  }

  Widget _buildBody() {
    final o = _order!;
    final statusColor = _statusColor(o.status);
    final canAdvance = o.status == 'open' || o.status == 'in_progress';

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.assignment_rounded,
                            color: statusColor, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OS #${o.id} — ${_typeLabel(o.type)}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Máquina #${o.machineId}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _StatusBadge(status: o.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(label: 'Tipo', value: _typeLabel(o.type)),
                  const Divider(height: 24),
                  _DetailRow(label: 'Status', value: _statusLabel(o.status)),
                  if (o.startedAt != null) ...[
                    const Divider(height: 24),
                    _DetailRow(
                        label: 'Iniciada em',
                        value: _formatDate(o.startedAt!)),
                  ],
                  if (o.completedAt != null) ...[
                    const Divider(height: 24),
                    _DetailRow(
                        label: 'Concluída em',
                        value: _formatDate(o.completedAt!)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Technician card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Técnico Responsável',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  if (o.technician != null)
                    _UserRow(user: o.technician!)
                  else
                    const Text('Sem técnico atribuído',
                        style: TextStyle(color: MaintSysColors.textMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Creator card
          if (o.creator != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Criada por',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _UserRow(user: o.creator!),
                  ],
                ),
              ),
            ),

          if (canAdvance) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _updating ? null : _advanceStatus,
              icon: _updating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
              label: Text(_nextStatusLabel(o.status)),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _statusColor(String s) => switch (s) {
        'open' => MaintSysColors.statusWarn,
        'in_progress' => MaintSysColors.primary,
        'completed' => MaintSysColors.statusOk,
        'cancelled' => MaintSysColors.textMuted,
        _ => MaintSysColors.textMuted,
      };

  String _statusLabel(String s) => switch (s) {
        'open' => 'Aberta',
        'in_progress' => 'Em Andamento',
        'completed' => 'Concluída',
        'cancelled' => 'Cancelada',
        _ => s,
      };

  String _typeLabel(String t) =>
      t == 'preventive' ? 'Preventiva' : 'Corretiva';

  String _nextStatusLabel(String current) => switch (current) {
        'open' => 'Iniciar Atendimento',
        'in_progress' => 'Marcar como Concluída',
        _ => '',
      };

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color => switch (status) {
        'open' => MaintSysColors.statusWarn,
        'in_progress' => MaintSysColors.primary,
        'completed' => MaintSysColors.statusOk,
        _ => MaintSysColors.textMuted,
      };

  String get _label => switch (status) {
        'open' => 'Aberta',
        'in_progress' => 'Em Andamento',
        'completed' => 'Concluída',
        'cancelled' => 'Cancelada',
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(_label,
              style: TextStyle(
                  color: _color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  final UserModel user;
  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: MaintSysColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: MaintSysColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name, style: Theme.of(context).textTheme.bodyLarge),
            Text(user.email,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
