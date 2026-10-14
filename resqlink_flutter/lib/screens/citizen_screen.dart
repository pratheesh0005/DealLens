import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_client/resqlink_client.dart';
import '../providers/emergency_provider.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

class CitizenScreen extends StatefulWidget {
  const CitizenScreen({super.key});

  @override
  State<CitizenScreen> createState() => _CitizenScreenState();
}

class _CitizenScreenState extends State<CitizenScreen>
    with SingleTickerProviderStateMixin {
  String _selectedType = 'medical';
  String _selectedPriority = 'high';
  final _descriptionController = TextEditingController();
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'medical',
      'label': 'Medical',
      'icon': Icons.medical_services_rounded,
      'color': const Color(0xFFE63946),
    },
    {
      'id': 'fire',
      'label': 'Fire Hazard',
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFF4A261),
    },
    {
      'id': 'accident',
      'label': 'Accident',
      'icon': Icons.car_crash_rounded,
      'color': const Color(0xFFE76F51),
    },
    {
      'id': 'rescue',
      'label': 'Search & Rescue',
      'icon': Icons.hiking_rounded,
      'color': const Color(0xFF2A9D8F),
    },
    {
      'id': 'missing',
      'label': 'Missing Person',
      'icon': Icons.person_search_rounded,
      'color': const Color(0xFF48CAE4),
    },
    {
      'id': 'other',
      'label': 'Other Danger',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFA8DADC),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyProvider>().fetchMyEmergencies();
      context.read<EmergencyProvider>().listenToLiveFeed();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _triggerEmergencyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRed.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.emergency_rounded,
                                  color: AppTheme.primaryRed,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Request Immediate Aid',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppTheme.textMuted,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '1. EMERGENCY CATEGORY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final isSelected = _selectedType == cat['id'];
                          return ChoiceChip(
                            avatar: Icon(
                              cat['icon'] as IconData,
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : cat['color'] as Color,
                            ),
                            label: Text(cat['label'] as String),
                            selected: isSelected,
                            selectedColor: AppTheme.primaryRed,
                            backgroundColor: AppTheme.surfaceCardElevated,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(
                                  () => _selectedType = cat['id'] as String,
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '2. PRIORITY LEVEL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: ['low', 'medium', 'high', 'critical'].map((
                          p,
                        ) {
                          final isSelected = _selectedPriority == p;
                          Color color = Colors.grey;
                          if (p == 'low') color = AppTheme.infoCyan;
                          if (p == 'medium') color = AppTheme.safetyAmber;
                          if (p == 'high') color = AppTheme.primaryRed;
                          if (p == 'critical') color = AppTheme.urgentCritical;

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: InkWell(
                                onTap: () =>
                                    setModalState(() => _selectedPriority = p),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color.withValues(alpha: 0.25)
                                        : AppTheme.surfaceCardElevated,
                                    border: Border.all(
                                      color: isSelected
                                          ? color
                                          : AppTheme.borderSubtle,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    p.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '3. SITUATION DETAILS (OPTIONAL)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'e.g. Person collapsed near 4th cross, unconscious...',
                          hintStyle: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: AppTheme.surfaceCardElevated,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.radar_rounded),
                          label: const Text(
                            'DISPATCH SOS TO NEARBY RESPONDERS',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryRed,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            final desc =
                                _descriptionController.text.trim().isEmpty
                                ? 'Emergency assistance requested for $_selectedType'
                                : _descriptionController.text.trim();

                            final messenger = ScaffoldMessenger.of(context);
                            final prov = context.read<EmergencyProvider>();
                            final created = await prov.reportEmergency(
                              type: _selectedType,
                              description: desc,
                              priority: _selectedPriority,
                            );
                            _descriptionController.clear();

                            if (mounted) {
                              if (created == null) {
                                final err =
                                    prov.errorMessage ??
                                    'Unable to dispatch emergency aid.';
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(err)),
                                      ],
                                    ),
                                    backgroundColor: AppTheme.urgentCritical,
                                    duration: const Duration(seconds: 5),
                                    action:
                                        (err.contains('GPS') ||
                                            err.contains('Location') ||
                                            err.contains('permission'))
                                        ? SnackBarAction(
                                            label: 'SETTINGS',
                                            textColor: Colors.white,
                                            onPressed: () =>
                                                LocationService.openSettings(),
                                          )
                                        : null,
                                  ),
                                );
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'SOS Dispatched! Emergency #${created.id} logged to Serverpod.',
                                    ),
                                    backgroundColor: AppTheme.successMint,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final emergencyProv = context.watch<EmergencyProvider>();
    final active = emergencyProv.activeEmergency;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppTheme.primaryRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('ResQLink'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.infoCyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.infoCyan.withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'CITIZEN',
                style: TextStyle(
                  color: AppTheme.infoCyan,
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
            onPressed: () {
              emergencyProv.fetchMyEmergencies();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Emergency Live Status Card (if exists)
            if (active != null) ...[
              _buildActiveEmergencyCard(active, emergencyProv),
              const SizedBox(height: 24),
            ],

            // Giant Panic Button (if no active emergency or if user wants to report another)
            if (active == null) ...[
              _buildSosButtonSection(emergencyProv),
              const SizedBox(height: 28),
            ],

            // History Section
            const Text(
              'Your Recent Emergency Reports',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildHistoryList(emergencyProv),
          ],
        ),
      ),
    );
  }

  Widget _buildSosButtonSection(EmergencyProvider prov) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.08);
              final shadowRadius = 20.0 + (_pulseController.value * 25);
              return Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRed.withValues(alpha: 0.4),
                        blurRadius: shadowRadius,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Material(
                    color: AppTheme.primaryRed,
                    shape: const CircleBorder(),
                    elevation: 10,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: prov.isCreating ? null : _triggerEmergencyDialog,
                      child: Container(
                        width: 170,
                        height: 170,
                        alignment: Alignment.center,
                        child: prov.isCreating
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.touch_app_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'SOS',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  Text(
                                    'TAP TO REPORT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white70,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.gps_fixed_rounded,
                size: 14,
                color: AppTheme.successMint,
              ),
              SizedBox(width: 6),
              Text(
                'Auto-detects GPS & matches nearest responder',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveEmergencyCard(
    EmergencyRequest emergency,
    EmergencyProvider prov,
  ) {
    Color statusColor = AppTheme.safetyAmber;
    if (emergency.status == 'assigned') statusColor = AppTheme.infoCyan;
    if (emergency.status == 'enRoute' || emergency.status == 'accepted') {
      statusColor = AppTheme.safetyAmber;
    }
    if (emergency.status == 'arrived') statusColor = const Color(0xFF9D4EDD);
    if (emergency.status == 'resolved') statusColor = AppTheme.successMint;
    if (emergency.status == 'cancelled') statusColor = Colors.grey;

    return Card(
      color: AppTheme.surfaceCardElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.bolt_rounded,
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INCIDENT #${emergency.id} • ${emergency.type.toUpperCase()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'hh:mm a, MMM dd',
                          ).format(emergency.createdAt),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    emergency.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              emergency.description,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.bgDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_pin_circle_rounded,
                    color: AppTheme.infoCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      emergency.assignedResponderId != null
                          ? 'Assigned to Responder #${emergency.assignedResponderId} • En route to scene'
                          : 'Serverpod Matching Engine searching nearby responders...',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'LIVE AUDIT TRAIL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            ...prov.activeTimeline.map((ev) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppTheme.successMint,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${ev.status.toUpperCase()}: ${ev.note ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm:ss a').format(ev.createdAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                if (emergency.status != 'resolved' &&
                    emergency.status != 'cancelled')
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.urgentCritical,
                        side: const BorderSide(color: AppTheme.urgentCritical),
                      ),
                      onPressed: () {
                        prov.cancelActiveEmergency(
                          'False alarm / Situation safe',
                        );
                      },
                      child: const Text('CANCEL REQUEST'),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceCard,
                      side: const BorderSide(color: AppTheme.borderSubtle),
                    ),
                    onPressed: () => prov.clearActiveEmergency(),
                    child: const Text('DISMISS CARD'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(EmergencyProvider prov) {
    if (prov.isLoadingHistory) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (prov.myEmergencies.isEmpty) {
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
            Icon(Icons.security_outlined, color: AppTheme.textMuted, size: 36),
            SizedBox(height: 10),
            Text(
              'Zero Emergencies Logged',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'You have no active or historical emergency reports in the database.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: prov.myEmergencies.length,
      itemBuilder: (context, index) {
        final item = prov.myEmergencies[index];
        final isResolved = item.status == 'resolved';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isResolved
                  ? AppTheme.successMint.withValues(alpha: 0.2)
                  : AppTheme.primaryRed.withValues(alpha: 0.2),
              child: Icon(
                isResolved
                    ? Icons.check_circle_outline_rounded
                    : Icons.pending_actions_rounded,
                color: isResolved ? AppTheme.successMint : AppTheme.primaryRed,
                size: 20,
              ),
            ),
            title: Text(
              '${item.type.toUpperCase()} • #${item.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              '${item.description}\n${DateFormat('MMM dd, hh:mm a').format(item.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            trailing: Text(
              item.status.toUpperCase(),
              style: TextStyle(
                color: isResolved ? AppTheme.successMint : AppTheme.safetyAmber,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            onTap: () {
              prov.subscribeToEmergency(item.id!);
              prov.fetchTimeline(item.id!);
            },
          ),
        );
      },
    );
  }
}
