import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../providers/responder_provider.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController(text: 'Community Citizen');
  final _emailController = TextEditingController(text: 'citizen@resqlink.app');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  String _selectedRole = 'citizen';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _applyQuickPreset(String role, String name, String email, String phone) {
    setState(() {
      _selectedRole = role;
      _nameController.text = name;
      _emailController.text = email;
      _phoneController.text = phone;
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: AppTheme.urgentCritical,
        ),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppTheme.urgentCritical,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.authenticate(
      email: email,
      displayName: name,
      role: _selectedRole,
      phone: phone.isNotEmpty ? phone : null,
    );

    if (success && mounted) {
      if (_selectedRole == 'responder') {
        context.read<ResponderProvider>().init(auth.currentResponderProfile);
      } else {
        context.read<EmergencyProvider>().fetchMyEmergencies();
      }
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppTheme.urgentCritical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDarkest,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryRed.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      size: 48,
                      color: AppTheme.primaryRed,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ResQLink',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Community Emergency Response Network\nPowered by Serverpod 4 & PostgreSQL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),

                // Role Selector
                const Text(
                  'SELECT YOUR ROLE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildRoleTab(
                      'citizen',
                      'Citizen',
                      Icons.person_rounded,
                      AppTheme.infoCyan,
                    ),
                    const SizedBox(width: 8),
                    _buildRoleTab(
                      'responder',
                      'Responder',
                      Icons.medical_services_rounded,
                      AppTheme.successMint,
                    ),
                    const SizedBox(width: 8),
                    _buildRoleTab(
                      'admin',
                      'Admin',
                      Icons.admin_panel_settings_rounded,
                      const Color(0xFF9D4EDD),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Form Inputs
                Card(
                  color: AppTheme.surfaceCard,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            hintStyle: const TextStyle(
                              color: AppTheme.textMuted,
                            ),
                            prefixIcon: const Icon(
                              Icons.badge_outlined,
                              color: AppTheme.textMuted,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceCardElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Email Address',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'user@resqlink.app',
                            hintStyle: const TextStyle(
                              color: AppTheme.textMuted,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppTheme.textMuted,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceCardElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Emergency Contact Phone (Optional)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: '+91 98765 43210',
                            hintStyle: const TextStyle(
                              color: AppTheme.textMuted,
                            ),
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              color: AppTheme.textMuted,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: AppTheme.surfaceCardElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'AUTHENTICATE & ENTER RESQLINK',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                ),
                const SizedBox(height: 20),

                // Quick Setup Presets
                const Text(
                  'QUICK SETUP PROFILES (TESTING)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ActionChip(
                      label: const Text(
                        'Citizen Preset',
                        style: TextStyle(fontSize: 11),
                      ),
                      avatar: const Icon(
                        Icons.person,
                        size: 14,
                        color: AppTheme.infoCyan,
                      ),
                      backgroundColor: AppTheme.surfaceCardElevated,
                      onPressed: () => _applyQuickPreset(
                        'citizen',
                        'Community Citizen',
                        'citizen@resqlink.app',
                        '+91 98765 43210',
                      ),
                    ),
                    ActionChip(
                      label: const Text(
                        'Responder Preset',
                        style: TextStyle(fontSize: 11),
                      ),
                      avatar: const Icon(
                        Icons.medical_services,
                        size: 14,
                        color: AppTheme.successMint,
                      ),
                      backgroundColor: AppTheme.surfaceCardElevated,
                      onPressed: () => _applyQuickPreset(
                        'responder',
                        'Paramedic First Responder',
                        'responder@resqlink.app',
                        '+91 98111 22233',
                      ),
                    ),
                    ActionChip(
                      label: const Text(
                        'Admin Preset',
                        style: TextStyle(fontSize: 11),
                      ),
                      avatar: const Icon(
                        Icons.admin_panel_settings,
                        size: 14,
                        color: Color(0xFF9D4EDD),
                      ),
                      backgroundColor: AppTheme.surfaceCardElevated,
                      onPressed: () => _applyQuickPreset(
                        'admin',
                        'Incident Command Admin',
                        'admin@resqlink.app',
                        '+91 98444 55566',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(String role, String label, IconData icon, Color color) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : AppTheme.surfaceCard,
            border: Border.all(
              color: isSelected ? color : AppTheme.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppTheme.textMuted,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
