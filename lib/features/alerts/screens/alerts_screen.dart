import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/resource_services.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final _service = StatusAlertsService();
  List<StatusAlertModel> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await _service.index();
      if (mounted) {
        setState(() {
          _alerts = res.data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(StatusAlertModel alert) async {
    try {
      await _service.markAsRead(alert.id);
      _load();
    } catch (_) {}
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _alerts.where((a) => !a.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MaintSysColors.statusError.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unreadCount não lidos',
                    style: const TextStyle(
                      color: MaintSysColors.statusError,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _alerts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 56, color: MaintSysColors.statusOk),
                          SizedBox(height: 12),
                          Text(
                            'Nenhum alerta!',
                            style: TextStyle(
                                color: MaintSysColors.statusOk,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Todas as máquinas estão normais.',
                            style:
                                TextStyle(color: MaintSysColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _alerts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final a = _alerts[i];
                        return _AlertCard(
                          alert: a,
                          onMarkAsRead: a.isRead ? null : () => _markAsRead(a),
                          formatDate: _formatDate,
                        );
                      },
                    ),
            ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final StatusAlertModel alert;
  final VoidCallback? onMarkAsRead;
  final String Function(String) formatDate;

  const _AlertCard({
    required this.alert,
    required this.onMarkAsRead,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = alert.isRead;
    const activeColor = MaintSysColors.statusWarn;
    const readColor = MaintSysColors.textMuted;
    final color = isRead ? readColor : activeColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isRead
                        ? Icons.notifications_none_rounded
                        : Icons.warning_amber_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.message,
                        style: TextStyle(
                          color: isRead
                              ? MaintSysColors.textSecondary
                              : MaintSysColors.textPrimary,
                          fontSize: 14,
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusTransition(
                            from: alert.previousStatus,
                            to: alert.newStatus,
                          ),
                          const Spacer(),
                          if (alert.triggeredAt != null)
                            Text(
                              formatDate(alert.triggeredAt!),
                              style: const TextStyle(
                                color: MaintSysColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onMarkAsRead != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onMarkAsRead,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Marcar como lido'),
                  style: TextButton.styleFrom(
                    foregroundColor: MaintSysColors.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusTransition extends StatelessWidget {
  final String from;
  final String to;
  const _StatusTransition({required this.from, required this.to});

  Color _colorFor(String s) => machineStatusColor(s);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _colorFor(from).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            from,
            style: TextStyle(color: _colorFor(from), fontSize: 10),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.arrow_forward_rounded,
              size: 12, color: MaintSysColors.textMuted),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _colorFor(to).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            to,
            style: TextStyle(color: _colorFor(to), fontSize: 10),
          ),
        ),
      ],
    );
  }
}
