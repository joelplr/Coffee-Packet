import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final todayProduction = provider.weeklyProduction.last.toInt();
        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good ${_greeting()}, ${provider.currentUser} 👋',
                            style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('Here\'s what\'s happening with your production line today.',
                            style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  // Quick Start/Stop
                  _QuickActionButtons(provider: provider),
                ],
              ),
              SizedBox(height: 24),
              // Stat Cards Row
              Row(
                children: [
                  Expanded(child: StatCard(
                    title: 'Total Sachets (All Time)',
                    value: _formatNumber(provider.totalSachetsProduced),
                    icon: Icons.inventory_rounded,
                    color: context.theme.accent,
                    subtitle: '+${todayProduction} today',
                  )),
                  SizedBox(width: 16),
                  Expanded(child: StatCard(
                    title: 'Today\'s Production',
                    value: _formatNumber(todayProduction),
                    icon: Icons.today_rounded,
                    color: context.theme.info,
                    subtitle: 'sachets packed',
                  )),
                  SizedBox(width: 16),
                  Expanded(child: StatCard(
                    title: 'Production Rate',
                    value: provider.machineStatus == MachineStatus.running
                        ? '${provider.currentRate}/min'
                        : '—',
                    icon: Icons.speed_rounded,
                    color: context.theme.success,
                    subtitle: provider.machineStatus == MachineStatus.running ? 'active' : 'machine idle',
                  )),
                  SizedBox(width: 16),
                  Expanded(child: StatCard(
                    title: 'Active Recipe',
                    value: provider.activeRecipe?.name ?? 'None',
                    icon: Icons.science_rounded,
                    color: context.theme.accentLight,
                    subtitle: '${provider.activeRecipe?.totalWeight.toInt() ?? 0}g per sachet',
                  )),
                ],
              ),
              SizedBox(height: 24),
              // Middle Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Machine Status Card
                  Expanded(flex: 2, child: _MachineStatusCard(provider: provider)),
                  SizedBox(width: 16),
                  // Inventory Quick View
                  Expanded(flex: 3, child: _InventoryQuickCard(provider: provider)),
                ],
              ),
              SizedBox(height: 24),
              // Recent Production Logs
              _RecentLogsCard(provider: provider),
            ],
          ),
        );
      },
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _QuickActionButtons extends StatelessWidget {
  final AppProvider provider;
  const _QuickActionButtons({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isRunning = provider.machineStatus == MachineStatus.running;
    final isPaused = provider.machineStatus == MachineStatus.paused;
    return Row(
      children: [
        if (!isRunning && !isPaused)
          ElevatedButton.icon(
            onPressed: provider.machineStatus == MachineStatus.error ? null : provider.startMachine,
            icon: Icon(Icons.play_arrow_rounded, size: 18),
            label: Text('Start Machine'),
            style: ElevatedButton.styleFrom(backgroundColor: context.theme.success, foregroundColor: Colors.white),
          ),
        if (isRunning) ...[
          ElevatedButton.icon(
            onPressed: provider.pauseMachine,
            icon: Icon(Icons.pause_rounded, size: 18),
            label: Text('Pause'),
            style: ElevatedButton.styleFrom(backgroundColor: context.theme.warning, foregroundColor: Colors.black),
          ),
          SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: provider.stopMachine,
            icon: Icon(Icons.stop_rounded, size: 18),
            label: Text('Stop'),
            style: ElevatedButton.styleFrom(backgroundColor: context.theme.error, foregroundColor: Colors.white),
          ),
        ],
        if (isPaused) ...[
          ElevatedButton.icon(
            onPressed: provider.pauseMachine, // resume
            icon: Icon(Icons.play_arrow_rounded, size: 18),
            label: Text('Resume'),
            style: ElevatedButton.styleFrom(backgroundColor: context.theme.success, foregroundColor: Colors.white),
          ),
          SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: provider.stopMachine,
            icon: Icon(Icons.stop_rounded, size: 18),
            label: Text('Stop'),
            style: ElevatedButton.styleFrom(backgroundColor: context.theme.error, foregroundColor: Colors.white),
          ),
        ],
      ],
    );
  }
}

class _MachineStatusCard extends StatelessWidget {
  final AppProvider provider;
  const _MachineStatusCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    switch (provider.machineStatus) {
      case MachineStatus.running:
        statusColor = context.theme.success;
        statusIcon = Icons.check_circle_rounded;
        break;
      case MachineStatus.paused:
        statusColor = context.theme.warning;
        statusIcon = Icons.pause_circle_rounded;
        break;
      case MachineStatus.error:
        statusColor = context.theme.error;
        statusIcon = Icons.error_rounded;
        break;
      default:
        statusColor = context.theme.textMuted;
        statusIcon = Icons.circle_outlined;
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Machine Status', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 16),
          Icon(statusIcon, color: statusColor, size: 48),
          SizedBox(height: 12),
          Text(
            provider.machineStatusLabel,
            style: GoogleFonts.inter(color: statusColor, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Speed: ${provider.productionSpeed.toInt()} pkt/min',
            style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12),
          ),
          Text(
            'Sachet: ${provider.sachetSize.toInt()}g | Seal: ${provider.sealingTemp.toInt()}°C',
            style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12),
          ),
          SizedBox(height: 12),
          Text(
            'Recipe: ${provider.activeRecipe?.name ?? "None"}',
            style: GoogleFonts.inter(color: context.theme.accent, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InventoryQuickCard extends StatelessWidget {
  final AppProvider provider;
  const _InventoryQuickCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inventory Levels', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 16),
          ...provider.inventory.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.name, style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 13)),
                    Spacer(),
                    if (item.isLow) Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.theme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: context.theme.error.withOpacity(0.3)),
                      ),
                      child: Text('LOW STOCK', style: GoogleFonts.inter(color: context.theme.error, fontSize: 9, fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(width: 8),
                    Text('${item.quantity.toStringAsFixed(1)} ${item.unit}',
                        style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.percentFull,
                    backgroundColor: context.theme.surfaceLighter,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.isEmpty ? context.theme.error : item.isLow ? context.theme.warning : context.theme.accent,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _RecentLogsCard extends StatelessWidget {
  final AppProvider provider;
  const _RecentLogsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final logs = provider.productionLogs.reversed.take(5).toList();
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Production Logs', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 16),
          if (logs.isEmpty)
            Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No production logs yet.', style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 13)),
            ))
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.theme.border))),
                  children: ['Recipe', 'Date', 'Quantity', 'Status'].map((h) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(h, style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
                ...logs.map((log) => TableRow(
                  children: [
                    Padding(padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(log.recipeName, style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 13))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year}',
                            style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 13))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('${log.quantity}', style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 13))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          width: 80,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: context.theme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: context.theme.success.withOpacity(0.3)),
                          ),
                          child: Text('Completed', style: GoogleFonts.inter(color: context.theme.success, fontSize: 11)),
                        )),
                  ],
                )),
              ],
            ),
        ],
      ),
    );
  }
}
