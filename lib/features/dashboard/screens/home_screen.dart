import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/auth_service.dart';
import '../../../core/network/resource_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _machinesService = MachinesService();
  final _ordersService = ServiceOrdersService();
  final _alertsService = StatusAlertsService();

  UserModel? _user;
  bool _loading = true;

  // Contadores do dashboard
  int _totalMachines = 0;
  int _operationalMachines = 0;
  int _openOrders = 0;
  int _unresolvedAlerts = 0;

  List<MachineModel> _recentMachines = [];
  List<ServiceOrderModel> _recentOrders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _logout() async {
    final router = GoRouter.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: MaintSysColors.cardBg,
        title: const Text('Sair'),
        content: const Text('Deseja encerrar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: MaintSysColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Sair',
                style: TextStyle(color: MaintSysColors.statusError)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _authService.logout();
    router.go('/login');
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _authService.me(),
        _machinesService.index(),
        _ordersService.index(status: 'open'),
        _alertsService.index(),
      ]);

      final user = results[0] as UserModel;
      final machines = results[1] as PaginatedResponse<MachineModel>;
      final orders = results[2] as PaginatedResponse<ServiceOrderModel>;
      final alerts = results[3] as PaginatedResponse<StatusAlertModel>;

      if (mounted) {
        setState(() {
          _user = user;
          _totalMachines = machines.total;
          _operationalMachines = machines.data
              .where((m) => m.status == 'active')
              .length;
          _openOrders = orders.total;
          _unresolvedAlerts = alerts.data.where((a) => !a.isRead).length;
          _recentMachines = machines.data.take(3).toList();
          _recentOrders = orders.data.take(3).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MaintSys'),
            if (_user != null)
              Text(
                'Olá, ${_user!.name.split(' ').first}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          // Badge de alertas
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.go('/alerts'),
              ),
              if (_unresolvedAlerts > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: MaintSysColors.statusError,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _unresolvedAlerts > 9 ? '9+' : '$_unresolvedAlerts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // --- Stats Grid ---
                  _StatsGrid(
                    totalMachines: _totalMachines,
                    operational: _operationalMachines,
                    openOrders: _openOrders,
                    alerts: _unresolvedAlerts,
                  ),
                  const SizedBox(height: 24),

                  // --- Máquinas recentes ---
                  _SectionHeader(
                    title: 'Máquinas',
                    onSeeAll: () => context.go('/machines'),
                  ),
                  const SizedBox(height: 12),
                  ..._recentMachines.map((m) => _MachineCard(machine: m)),
                  if (_recentMachines.isEmpty)
                    const _EmptyState(msg: 'Nenhuma máquina cadastrada'),
                  const SizedBox(height: 24),

                  // --- Ordens abertas ---
                  _SectionHeader(
                    title: 'Ordens Abertas',
                    onSeeAll: () => context.go('/orders'),
                  ),
                  const SizedBox(height: 12),
                  ..._recentOrders.map((o) => _OrderCard(order: o)),
                  if (_recentOrders.isEmpty)
                    const _EmptyState(msg: 'Nenhuma ordem aberta'),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// ---- Stats Grid ----
class _StatsGrid extends StatelessWidget {
  final int totalMachines;
  final int operational;
  final int openOrders;
  final int alerts;

  const _StatsGrid({
    required this.totalMachines,
    required this.operational,
    required this.openOrders,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _StatCard(
          icon: Icons.precision_manufacturing_rounded,
          value: '$totalMachines',
          label: 'Máquinas',
          color: MaintSysColors.primary,
        ),
        _StatCard(
          icon: Icons.check_circle_outline_rounded,
          value: '$operational',
          label: 'Operacionais',
          color: MaintSysColors.statusOk,
        ),
        _StatCard(
          icon: Icons.assignment_outlined,
          value: '$openOrders',
          label: 'Ordens Abertas',
          color: MaintSysColors.statusWarn,
        ),
        _StatCard(
          icon: Icons.warning_amber_rounded,
          value: '$alerts',
          label: 'Alertas',
          color: MaintSysColors.statusError,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Section Header ----
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: MaintSysColors.primary,
            padding: EdgeInsets.zero,
          ),
          child: const Text('Ver tudo →'),
        ),
      ],
    );
  }
}

// ---- Machine Card ----
class _MachineCard extends StatelessWidget {
  final MachineModel machine;
  const _MachineCard({required this.machine});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: MaintSysColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.precision_manufacturing_rounded,
            color: MaintSysColors.primary,
            size: 22,
          ),
        ),
        title: Text(machine.name,
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          machine.serialNumber,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: MachineStatusBadge(status: machine.status),
        onTap: () => context.go('/machines/${machine.id}'),
      ),
    );
  }
}

// ---- Order Card ----
class _OrderCard extends StatelessWidget {
  final ServiceOrderModel order;
  const _OrderCard({required this.order});

  String get _typeLabel => order.type == 'preventive' ? 'Preventiva' : 'Corretiva';

  Color get _typeColor => order.type == 'preventive'
      ? MaintSysColors.primary
      : MaintSysColors.statusWarn;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _typeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.assignment_outlined, color: _typeColor, size: 22),
        ),
        title: Text(
          'OS #${order.id} — $_typeLabel',
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Máquina #${order.machineId}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _typeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _typeLabel.toUpperCase(),
            style: TextStyle(
              color: _typeColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => context.go('/orders/${order.id}'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String msg;
  const _EmptyState({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(msg, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
