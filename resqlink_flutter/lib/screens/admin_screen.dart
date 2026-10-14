import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_client/resqlink_client.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().startDashboardUpdates();
    });
  }

  void _showForceResolveDialog(int emergencyId) {
    final reasonController = TextEditingController(
      text: 'Resolved by incident commander via administrative override',
    );
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          title: Text(
            'Force Resolve Incident #$emergencyId',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Provide reason for administrative closure:',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.surfaceCardElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successMint,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await context
                    .read<AdminProvider>()
                    .forceResolve(
                      emergencyId,
                      reasonController.text.trim(),
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Incident #$emergencyId force-resolved.'
                            : 'Failed to resolve: ${context.read<AdminProvider>().errorMessage}',
                      ),
                      backgroundColor: success
                          ? AppTheme.successMint
                          : AppTheme.urgentCritical,
                    ),
                  );
                }
              },
              child: const Text('Confirm Resolution'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final adminProv = context.watch<AdminProvider>();
    final stats = adminProv.stats;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF9D4EDD).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.dashboard_customize_rounded,
                color: Color(0xFF9D4EDD),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Command Center'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF9D4EDD).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF9D4EDD).withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Color(0xFF9D4EDD),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => adminProv.refreshAll(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informational banner if role != admin
            if (auth.activeRole != 'admin') ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF9D4EDD).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF9D4EDD).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: Color(0xFF9D4EDD),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Logged in as "${auth.activeRole.toUpperCase()}". Incident Command requires Admin authorization. Switch role in the Account tab.',
                        style: const TextStyle(
                          color: Color(0xFFC77DFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // KPI Grid
            _buildKpiGrid(stats),
            const SizedBox(height: 24),

            // Incident Management Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Incident Feed & Dispatch Log',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${adminProv.emergencies.length} items',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filter Chips
            _buildFilterChips(adminProv),
            const SizedBox(height: 12),

            // Incidents List
            _buildIncidentList(adminProv),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(AdminStats? stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildKpiCard(
          'ACTIVE INCIDENTS',
          '${stats?.activeCount ?? 0}',
          Icons.warning_rounded,
          AppTheme.urgentCritical,
        ),
        _buildKpiCard(
          'MATCHING QUEUE',
          '${stats?.pendingCount ?? 0}',
          Icons.hourglass_top_rounded,
          AppTheme.safetyAmber,
        ),
        _buildKpiCard(
          'AVAILABLE UNITS',
          '${stats?.availableResponderCount ?? 0}',
          Icons.health_and_safety_rounded,
          AppTheme.successMint,
        ),
        _buildKpiCard(
          'RESOLVED TODAY',
          '${stats?.resolvedTodayCount ?? 0}',
          Icons.verified_rounded,
          AppTheme.infoCyan,
        ),
      ],
    );
  }

  Widget _buildKpiCard(String title, String count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(AdminProvider prov) {
    final filters = [
      {'id': null, 'label': 'All'},
      {'id': 'pending', 'label': 'Pending'},
      {'id': 'assigned', 'label': 'Assigned'},
      {'id': 'enRoute', 'label': 'En Route'},
      {'id': 'arrived', 'label': 'Arrived'},
      {'id': 'resolved', 'label': 'Resolved'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = prov.selectedStatusFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f['label'] as String),
              selected: isSelected,
              selectedColor: AppTheme.primaryRed.withValues(alpha: 0.3),
              backgroundColor: AppTheme.surfaceCard,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => prov.setFilter(f['id']),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIncidentList(AdminProvider prov) {
    if (prov.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (prov.emergencies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        alignment: Alignment.center,
        child: Column(
          children: const [
            Icon(Icons.inbox_rounded, color: AppTheme.textMuted, size: 36),
            SizedBox(height: 10),
            Text(
              'No Incidents Recorded',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Zero emergencies in this sector matching the selected filter.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: prov.emergencies.length,
      itemBuilder: (context, index) {
        final item = prov.emergencies[index];
        final isResolved = item.status == 'resolved';

        Color statusColor = AppTheme.safetyAmber;
        if (item.status == 'assigned') statusColor = AppTheme.infoCyan;
        if (item.status == 'enRoute' || item.status == 'accepted') {
          statusColor = AppTheme.safetyAmber;
        }
        if (item.status == 'arrived') statusColor = const Color(0xFF9D4EDD);
        if (item.status == 'resolved') statusColor = AppTheme.successMint;
        if (item.status == 'cancelled') statusColor = Colors.grey;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${item.id} • ${item.type.toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Requester: #${item.requesterId}  |  Responder: ${item.assignedResponderId != null ? "#${item.assignedResponderId}" : "Unassigned"}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('hh:mm a').format(item.createdAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                if (!isResolved && item.status != 'cancelled') ...[
                  const Divider(color: AppTheme.borderSubtle, height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppTheme.successMint,
                      ),
                      label: const Text(
                        'Force Resolve',
                        style: TextStyle(
                          color: AppTheme.successMint,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () => _showForceResolveDialog(item.id!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
