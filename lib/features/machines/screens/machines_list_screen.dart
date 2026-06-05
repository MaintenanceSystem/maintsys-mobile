import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/resource_services.dart';

class MachinesListScreen extends StatefulWidget {
  const MachinesListScreen({super.key});

  @override
  State<MachinesListScreen> createState() => _MachinesListScreenState();
}

class _MachinesListScreenState extends State<MachinesListScreen> {
  final _service = MachinesService();
  List<MachineModel> _machines = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await _service.index();
      if (mounted) {
        setState(() {
          _machines = res.data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<MachineModel> get _filtered => _search.isEmpty
      ? _machines
      : _machines
          .where((m) =>
              m.name.toLowerCase().contains(_search.toLowerCase()) ||
              m.serialNumber.toLowerCase().contains(_search.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Máquinas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: MaintSysColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Buscar por nome ou serial...',
                prefixIcon: Icon(Icons.search_rounded,
                    color: MaintSysColors.textSecondary),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final m = _filtered[i];
                  return Card(
                    child: ListTile(
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
                        ),
                      ),
                      title: Text(m.name),
                      subtitle: Text(m.serialNumber),
                      trailing: MachineStatusBadge(status: m.status),
                      onTap: () => context.go('/machines/${m.id}'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
