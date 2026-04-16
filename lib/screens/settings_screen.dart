import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  Expanded(child: _ProfileCard(provider: provider)),
                  SizedBox(width: 16),
                  // System Info
                  Expanded(child: _SystemInfoCard()),
                ],
              ),
              SizedBox(height: 16),
              // API Endpoints Reference
              _ApiCard(),
              SizedBox(height: 16),
              // Logout
              _LogoutCard(provider: provider),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final AppProvider provider;
  const _ProfileCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Profile', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: context.theme.accent.withOpacity(0.15),
                child: Icon(Icons.person_rounded, color: context.theme.accent, size: 32),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.currentUser,
                      style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.theme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: context.theme.accent.withOpacity(0.3)),
                    ),
                    child: Text(provider.currentRole,
                        style: GoogleFonts.inter(color: context.theme.accent, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),
          Divider(color: context.theme.border),
          SizedBox(height: 16),
          _infoRow(context, Icons.email_rounded, 'Email', 'admin@coffematic.io'),
          _infoRow(context, Icons.lock_rounded, 'Authentication', 'Email / Google'),
          _infoRow(context, Icons.security_rounded, 'Permissions', 'Full Access'),
          _infoRow(context, Icons.badge_rounded, 'Employee ID', 'EMP-001'),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.theme.textMuted),
          SizedBox(width: 10),
          Text(label, style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12)),
          Spacer(),
          Text(value, style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SystemInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Information', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 20),
          _infoItem(context, 'Platform', 'Flutter Web'),
          _infoItem(context, 'Backend', 'Firebase / Supabase'),
          _infoItem(context, 'IoT Protocol', 'MQTT / REST API'),
          _infoItem(context, 'Controller', 'ESP32'),
          _infoItem(context, 'App Version', 'v1.0.0'),
          _infoItem(context, 'Environment', 'Production'),
          SizedBox(height: 16),
          Divider(color: context.theme.border),
          SizedBox(height: 16),
          Text('Security', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          _secBadge(Icons.https_rounded, 'HTTPS Encryption', context.theme.success),
          SizedBox(height: 6),
          _secBadge(Icons.shield_rounded, 'Role-Based Access Control', context.theme.info),
          SizedBox(height: 6),
          _secBadge(Icons.lock_rounded, 'Secure API Endpoints', context.theme.accent),
        ],
      ),
    );
  }

  Widget _infoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(label, style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12)),
          Spacer(),
          Text(value, style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _secBadge(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ApiCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final endpoints = [
      ('GET', '/machine/status', 'Get machine status'),
      ('POST', '/machine/start', 'Start machine'),
      ('POST', '/machine/stop', 'Stop machine'),
      ('GET', '/recipes', 'List all recipes'),
      ('POST', '/recipes', 'Create recipe'),
      ('PUT', '/recipes/{id}', 'Update recipe'),
      ('GET', '/inventory', 'Get inventory levels'),
    ];

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('API Endpoints Reference', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: endpoints.map((ep) {
              final methodColor = ep.$1 == 'GET' ? context.theme.success : ep.$1 == 'POST' ? context.theme.info : context.theme.warning;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.theme.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.theme.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: methodColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                      child: Text(ep.$1, style: GoogleFonts.robotoMono(color: methodColor, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    SizedBox(width: 8),
                    Text(ep.$2, style: GoogleFonts.robotoMono(color: context.theme.textPrimary, fontSize: 12)),
                    SizedBox(width: 8),
                    Text('—  ${ep.$3}', style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 11)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LogoutCard extends StatelessWidget {
  final AppProvider provider;
  const _LogoutCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.border),
      ),
      child: Row(
        children: [
          Icon(Icons.logout_rounded, color: context.theme.error, size: 20),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sign Out', style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              Text('You are logged in as ${provider.currentUser}', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12)),
            ],
          ),
          Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sign out functionality requires Firebase Auth integration.', style: GoogleFonts.inter()),
                  backgroundColor: context.theme.surface,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(Icons.logout_rounded, size: 16),
            label: Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.theme.error.withOpacity(0.15),
              foregroundColor: context.theme.error,
              side: BorderSide(color: context.theme.error, width: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}