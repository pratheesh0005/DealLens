import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../client.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../providers/responder_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isTestingConnection = false;
  String? _serverPingResult;

  Future<void> _pingServer() async {
    setState(() {
      _isTestingConnection = true;
      _serverPingResult = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      await client.user.getMyProfile();
      stopwatch.stop();
      setState(() {
        _serverPingResult =
            'Online (${stopwatch.elapsedMilliseconds}ms latency)';
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _serverPingResult = 'Error: ${e.toString().split('\n').first}';
      });
    } finally {
      setState(() {
        _isTestingConnection = false;
      });
    }
  }

  void _showRoleSwitchDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          title: const Text(
            'Switch Account Role',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update your current active role in the Serverpod PostgreSQL database:',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildRoleOption(
                ctx,
                auth,
                'citizen',
                'Citizen',
                Icons.person,
                AppTheme.infoCyan,
              ),
              const SizedBox(height: 8),
              _buildRoleOption(
                ctx,
                auth,
                'responder',
                'Responder',
                Icons.medical_services,
                AppTheme.successMint,
              ),
              const SizedBox(height: 8),
              _buildRoleOption(
                ctx,
                auth,
                'admin',
                'Admin',
                Icons.admin_panel_settings,
                const Color(0xFF9D4EDD),
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
          ],
        );
      },
    );
  }

  Widget _buildRoleOption(
    BuildContext ctx,
    AuthProvider auth,
    String role,
    String title,
    IconData icon,
    Color color,
  ) {
    final isCurrent = auth.activeRole == role;

    return ListTile(
      tileColor: isCurrent
          ? color.withValues(alpha: 0.15)
          : AppTheme.surfaceCardElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isCurrent ? color : AppTheme.borderSubtle,
        ),
      ),
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: isCurrent ? Colors.white : AppTheme.textPrimary,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'CURRENT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () async {
        Navigator.pop(ctx);
        if (isCurrent) return;

        final success = await auth.authenticate(
          email: auth.activeEmail,
          displayName: auth.activeDisplayName,
          role: role,
          phone: auth.activePhone,
        );

        if (success && mounted) {
          if (role == 'responder') {
            context.read<ResponderProvider>().init(
              auth.currentResponderProfile,
            );
          } else {
            context.read<EmergencyProvider>().fetchMyEmergencies();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Switched role to ${role.toUpperCase()} in PostgreSQL.',
              ),
              backgroundColor: AppTheme.successMint,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Infrastructure'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current User Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.primaryRed.withValues(
                            alpha: 0.2,
                          ),
                          child: Text(
                            (auth.activeDisplayName.isNotEmpty
                                ? auth.activeDisplayName[0].toUpperCase()
                                : 'U'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auth.activeDisplayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                auth.activeEmail,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              if (auth.activePhone != null &&
                                  auth.activePhone!.isNotEmpty)
                                Text(
                                  auth.activePhone!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.infoCyan.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ROLE: ${auth.activeRole.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.infoCyan,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppTheme.borderSubtle, height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.swap_horiz_rounded,
                              size: 18,
                            ),
                            label: const Text('CHANGE ROLE'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.infoCyan,
                              side: const BorderSide(color: AppTheme.infoCyan),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () =>
                                _showRoleSwitchDialog(context, auth),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('SIGN OUT'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.surfaceCardElevated,
                              foregroundColor: AppTheme.urgentCritical,
                              side: const BorderSide(
                                color: AppTheme.urgentCritical,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () async {
                              await auth.signOut();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live Telemetry & Serverpod Architecture Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Serverpod Backend Telemetry',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton.icon(
                  icon: _isTestingConnection
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.successMint,
                          ),
                        )
                      : const Icon(
                          Icons.speed_rounded,
                          size: 16,
                          color: AppTheme.successMint,
                        ),
                  label: const Text(
                    'Ping Server',
                    style: TextStyle(color: AppTheme.successMint, fontSize: 12),
                  ),
                  onPressed: _isTestingConnection ? null : _pingServer,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Serverpod Server',
                      'v4.0.2 (Port 8080)',
                      Icons.dns_rounded,
                    ),
                    const Divider(color: AppTheme.borderSubtle, height: 20),
                    _buildInfoRow(
                      'Primary Database',
                      'PostgreSQL 16 (Serverpod ORM)',
                      Icons.storage_rounded,
                    ),
                    const Divider(color: AppTheme.borderSubtle, height: 20),
                    _buildInfoRow(
                      'Real-time Messaging',
                      'Serverpod 4 Stream Channels',
                      Icons.bolt_rounded,
                    ),
                    const Divider(color: AppTheme.borderSubtle, height: 20),
                    _buildInfoRow(
                      'Session Authentication',
                      'Serverpod SessionManager',
                      Icons.vpn_key_rounded,
                    ),
                    const Divider(color: AppTheme.borderSubtle, height: 20),
                    _buildInfoRow(
                      'Server Address',
                      'http://10.204.10.251:8080/',
                      Icons.wifi_rounded,
                    ),
                    if (_serverPingResult != null) ...[
                      const Divider(color: AppTheme.borderSubtle, height: 20),
                      _buildInfoRow(
                        'Live Server Latency',
                        _serverPingResult!,
                        Icons.check_circle_outline_rounded,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.infoCyan),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
