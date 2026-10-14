import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_client/resqlink_client.dart';
import '../providers/auth_provider.dart';
import '../providers/responder_provider.dart';
import '../theme/app_theme.dart';

class ResponderScreen extends StatefulWidget {
  const ResponderScreen({super.key});

  @override
  State<ResponderScreen> createState() => _ResponderScreenState();
}

class _ResponderScreenState extends State<ResponderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentResponderProfile != null) {
        context.read<ResponderProvider>().init(auth.currentResponderProfile);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final responderProv = context.watch<ResponderProvider>();
    final profile = responderProv.profile ?? auth.currentResponderProfile;
    final activeEmergency = responderProv.assignedEmergency;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.successMint.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: AppTheme.successMint,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Responder Unit'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.successMint.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.successMint.withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'DISPATCH',
                style: TextStyle(
                  color: AppTheme.successMint,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            tooltip: 'Ping live GPS telemetry',
            onPressed: () async {
              await responderProv.sendLocationUpdate();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('GPS Telemetry pinged to Serverpod server'),
                    backgroundColor: AppTheme.successMint,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // If logged in as non-responder, show informational notice
            if (auth.activeRole != 'responder') ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.safetyAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.safetyAmber.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.safetyAmber,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Logged in as "${auth.activeRole.toUpperCase()}". Switch to a Responder profile in Account to receive direct dispatches.',
                        style: const TextStyle(
                          color: AppTheme.safetyAmber,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Duty Status Card
            _buildDutyStatusCard(responderProv, profile),
            const SizedBox(height: 20),

            // Active Dispatch / Assignment Section
            if (activeEmergency != null) ...[
              _buildDispatchCard(activeEmergency, responderProv),
              const SizedBox(height: 20),
            ] else ...[
              _buildStandbyCard(responderProv.isAvailable),
              const SizedBox(height: 20),
            ],

            // Responder Statistics Card
            _buildStatsCard(profile, responderProv.isAvailable),
          ],
        ),
      ),
    );
  }

  Widget _buildDutyStatusCard(
    ResponderProvider prov,
    ResponderProfile? profile,
  ) {
    final isOnDuty = prov.isAvailable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnDuty ? AppTheme.successMint : Colors.grey,
                        boxShadow: isOnDuty
                            ? [
                                BoxShadow(
                                  color: AppTheme.successMint.withValues(
                                    alpha: 0.6,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnDuty
                              ? 'ON DUTY • AVAILABLE'
                              : 'OFF DUTY • STANDBY',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isOnDuty
                                ? AppTheme.successMint
                                : AppTheme.textMuted,
                          ),
                        ),
                        Text(
                          isOnDuty
                              ? 'Receiving priority emergency dispatches'
                              : 'Turn on duty to receive calls',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: isOnDuty,
                  activeThumbColor: AppTheme.successMint,
                  onChanged: (val) => prov.toggleAvailability(),
                ),
              ],
            ),
            const Divider(color: AppTheme.borderSubtle, height: 24),
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: AppTheme.infoCyan,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Capabilities: ${profile?.capabilities ?? "medical,accident,rescue,fire"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchCard(
    EmergencyRequest emergency,
    ResponderProvider prov,
  ) {
    final isAccepted = emergency.status != 'assigned';

    return Card(
      color: AppTheme.surfaceCardElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.urgentCritical, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.urgentCritical.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.urgentCritical),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.urgentCritical,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'DISPATCH: ${emergency.type.toUpperCase()}',
                        style: const TextStyle(
                          color: AppTheme.urgentCritical,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'PRIORITY: ${emergency.priority.toUpperCase()}',
                  style: const TextStyle(
                    color: AppTheme.safetyAmber,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              emergency.description,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.navigation_rounded,
                  size: 16,
                  color: AppTheme.infoCyan,
                ),
                const SizedBox(width: 6),
                Text(
                  'GPS: ${emergency.latitude.toStringAsFixed(4)}, ${emergency.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('hh:mm a').format(emergency.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const Divider(color: AppTheme.borderSubtle, height: 24),

            // Stepper and Action Buttons
            if (!isAccepted) ...[
              // Assigned state: Accept or Decline
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.urgentCritical,
                        side: const BorderSide(color: AppTheme.urgentCritical),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () =>
                          prov.declineEmergency('Too far from scene'),
                      child: const Text('DECLINE'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('ACCEPT DISPATCH'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successMint,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => prov.acceptEmergency(),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Lifecycle Stage Progression
              _buildStageStepper(emergency.status),
              const SizedBox(height: 16),
              if (emergency.status == 'accepted')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.directions_car_rounded),
                    label: const Text('DEPART: MARK EN ROUTE 🚨'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.safetyAmber,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => prov.advanceStatus(
                      'enRoute',
                      note: 'Responder vehicle departed to scene',
                    ),
                  ),
                ),
              if (emergency.status == 'enRoute')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.location_on_rounded),
                    label: const Text('ARRIVED: ON SCENE 📍'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9D4EDD),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => prov.advanceStatus(
                      'arrived',
                      note: 'Responder arrived at scene',
                    ),
                  ),
                ),
              if (emergency.status == 'arrived')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.task_alt_rounded),
                    label: const Text('COMPLETE: MARK RESOLVED ✅'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successMint,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => prov.advanceStatus(
                      'resolved',
                      note: 'Emergency resolved on scene.',
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStageStepper(String status) {
    final stages = ['accepted', 'enRoute', 'arrived', 'resolved'];
    final currentIndex = stages.indexOf(status);

    return Row(
      children: stages.asMap().entries.map((entry) {
        final idx = entry.key;
        final name = entry.value;
        final isDone = idx <= currentIndex;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppTheme.successMint : AppTheme.surfaceCard,
                  border: Border.all(
                    color: isDone
                        ? AppTheme.successMint
                        : AppTheme.borderSubtle,
                  ),
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${idx + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                name.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                  color: isDone ? Colors.white : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStandbyCard(bool isAvailable) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            isAvailable
                ? Icons.radar_rounded
                : Icons.pause_circle_outline_rounded,
            size: 48,
            color: isAvailable ? AppTheme.infoCyan : AppTheme.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            isAvailable
                ? 'Listening for Live Dispatches...'
                : 'Responder Unit is Off Duty',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAvailable
                ? 'Serverpod Smart Matching Engine will route nearby emergencies to this unit based on GPS & capabilities.'
                : 'Toggle the On Duty switch above to start receiving alerts.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ResponderProfile? profile, bool isOnDuty) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '${profile?.totalResponseCount ?? 0}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successMint,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Resolved Calls',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            Container(width: 1, height: 40, color: AppTheme.borderSubtle),
            Column(
              children: [
                Text(
                  isOnDuty ? 'ACTIVE' : 'STANDBY',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isOnDuty ? AppTheme.infoCyan : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Fleet Readiness',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
