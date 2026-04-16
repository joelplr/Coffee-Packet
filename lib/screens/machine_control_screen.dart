import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class MachineControlScreen extends StatelessWidget {
  MachineControlScreen({super.key});

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
                  Expanded(flex: 2, child: _ControlButtonsCard(provider: provider)),
                  SizedBox(width: 16),
                  Expanded(flex: 3, child: _SettingsCard(provider: provider)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _RecipeSelectorCard(provider: provider)),
                  SizedBox(width: 16),
                  Expanded(child: _LiveMetricsCard(provider: provider)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ControlButtonsCard extends StatelessWidget {
  final AppProvider provider;
  const _ControlButtonsCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isRunning = provider.machineStatus == MachineStatus.running;
    final isPaused = provider.machineStatus == MachineStatus.paused;
    final isError = provider.machineStatus == MachineStatus.error;

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
          Text('Machine Controls', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 24),
          if (isError)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.theme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.theme.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_rounded, color: context.theme.error, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text('Machine error detected. Check inventory levels.',
                      style: GoogleFonts.inter(color: context.theme.error, fontSize: 12))),
                ],
              ),
            ),
          SizedBox(height: 16),
          _BigControlButton(
            label: 'START',
            icon: Icons.play_arrow_rounded,
            color: context.theme.success,
            enabled: !isRunning && !isError,
            onTap: provider.startMachine,
          ),
          SizedBox(height: 12),
          _BigControlButton(
            label: isPaused ? 'RESUME' : 'PAUSE',
            icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            color: context.theme.warning,
            enabled: isRunning || isPaused,
            onTap: provider.pauseMachine,
          ),
          SizedBox(height: 12),
          _BigControlButton(
            label: 'STOP',
            icon: Icons.stop_rounded,
            color: context.theme.error,
            enabled: isRunning || isPaused,
            onTap: provider.stopMachine,
          ),
        ],
      ),
    );
  }
}

class _BigControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;
  const _BigControlButton({required this.label, required this.icon, required this.color, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.35,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: enabled ? color.withOpacity(0.12) : context.theme.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: enabled ? color.withOpacity(0.4) : context.theme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: enabled ? color : context.theme.textMuted, size: 22),
              SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: enabled ? color : context.theme.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final AppProvider provider;
  const _SettingsCard({required this.provider});

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
          Text('Production Settings', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 20),
          _SliderSetting(
            label: 'Production Speed',
            value: provider.productionSpeed,
            min: 10,
            max: 200,
            unit: 'pkt/min',
            color: context.theme.accent,
            onChanged: provider.setProductionSpeed,
          ),
          SizedBox(height: 20),
          _SliderSetting(
            label: 'Sachet Size',
            value: provider.sachetSize,
            min: 10,
            max: 50,
            unit: 'grams',
            color: context.theme.info,
            onChanged: provider.setSachetSize,
          ),
          SizedBox(height: 20),
          _SliderSetting(
            label: 'Sealing Temperature',
            value: provider.sealingTemp,
            min: 120,
            max: 250,
            unit: '°C',
            color: context.theme.error,
            onChanged: provider.setSealingTemp,
          ),
        ],
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color color;
  final ValueChanged<double> onChanged;
  const _SliderSetting({required this.label, required this.value, required this.min, required this.max, required this.unit, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                '${value.toInt()} $unit',
                style: GoogleFonts.inter(color: color, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: context.theme.surfaceLighter,
            thumbColor: color,
            overlayColor: color.withOpacity(0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.toInt()}', style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 10)),
            Text('${max.toInt()}', style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}

class _RecipeSelectorCard extends StatelessWidget {
  final AppProvider provider;
  const _RecipeSelectorCard({required this.provider});

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
          Text('Select Recipe', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 16),
          ...provider.recipes.map((recipe) {
            final isActive = provider.activeRecipe?.id == recipe.id;
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => provider.setActiveRecipe(recipe),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? context.theme.accent.withOpacity(0.1) : context.theme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isActive ? context.theme.accent.withOpacity(0.4) : context.theme.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.science_rounded, size: 16, color: isActive ? context.theme.accent : context.theme.textMuted),
                      SizedBox(width: 10),
                      Expanded(child: Text(recipe.name,
                          style: GoogleFonts.inter(color: isActive ? context.theme.accent : context.theme.textPrimary, fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400))),
                      Text('${recipe.totalWeight.toInt()}g', style: GoogleFonts.inter(color: context.theme.textMuted, fontSize: 11)),
                      if (isActive) ...[
                        SizedBox(width: 8),
                        Icon(Icons.check_circle_rounded, size: 16, color: context.theme.accent),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LiveMetricsCard extends StatelessWidget {
  final AppProvider provider;
  const _LiveMetricsCard({required this.provider});

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
          Text('Live Metrics', style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 16),
          _metricRow(context, Icons.inventory_rounded, 'Today\'s Output', '${provider.weeklyProduction.last.toInt()} sachets', context.theme.accent),
          _metricRow(context, Icons.speed_rounded, 'Current Rate', provider.machineStatus == MachineStatus.running ? '${provider.currentRate} pkt/min' : '—', context.theme.success),
          _metricRow(context, Icons.scale_rounded, 'Sachet Size', '${provider.sachetSize.toInt()} g', context.theme.info),
          _metricRow(context, Icons.thermostat_rounded, 'Seal Temp', '${provider.sealingTemp.toInt()} °C', context.theme.error),
          _metricRow(context, Icons.science_rounded, 'Active Recipe', provider.activeRecipe?.name ?? 'None', context.theme.accentLight),
          Divider(color: context.theme.border),
          _metricRow(context, Icons.all_inclusive_rounded, 'Total Production', '${provider.totalSachetsProduced} sachets', context.theme.textSecondary),
        ],
      ),
    );
  }

  Widget _metricRow(BuildContext context, IconData icon, String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 10),
          Text(label, style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 12)),
          Spacer(),
          Text(value, style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}