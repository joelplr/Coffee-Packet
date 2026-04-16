import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class Sidebar extends StatelessWidget {
  Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Container(
          width: 240,
          decoration: BoxDecoration(
            color: context.theme.surface,
            border: Border(right: BorderSide(color: context.theme.border, width: 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [context.theme.accentLight, context.theme.accentDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.coffee, color: Colors.black, size: 20),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CoffeeMatic',
                              style: GoogleFonts.inter(
                                color: context.theme.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Powered by XyphX',
                              style: GoogleFonts.inter(
                                color: context.theme.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(color: context.theme.border, height: 1),
              SizedBox(height: 8),
              // Machine Status Badge
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _MachineStatusBadge(status: provider.machineStatus),
              ),
              SizedBox(height: 8),
              // Nav Items
              _navItem(context, provider, NavPage.dashboard, Icons.dashboard_rounded, 'Dashboard'),
              _navItem(context, provider, NavPage.recipes, Icons.science_rounded, 'Recipes'),
              _navItem(context, provider, NavPage.machineControl, Icons.settings_input_hdmi_rounded, 'Machine Control'),
              _navItem(context, provider, NavPage.inventory, Icons.inventory_2_rounded, 'Inventory'),
              _navItem(context, provider, NavPage.analytics, Icons.bar_chart_rounded, 'Analytics'),
              Spacer(),
              Divider(color: context.theme.border, height: 1),
              _navItem(context, provider, NavPage.settings, Icons.manage_accounts_rounded, 'Settings'),
              SizedBox(height: 8),
              // User Card
              Padding(
                padding: EdgeInsets.all(12),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.theme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.theme.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: context.theme.accent.withOpacity(0.2),
                        child: Icon(Icons.person, color: context.theme.accent, size: 18),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.currentUser,
                              style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              provider.currentRole,
                              style: GoogleFonts.inter(color: context.theme.accent, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navItem(BuildContext context, AppProvider provider, NavPage page, IconData icon, String label) {
    final isActive = provider.currentPage == page;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: () => provider.navigate(page),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? context.theme.accent.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive ? Border.all(color: context.theme.accent.withOpacity(0.3)) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? context.theme.accent : context.theme.textSecondary,
              ),
              SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isActive ? context.theme.accent : context.theme.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              if (isActive) ...[
                Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: context.theme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MachineStatusBadge extends StatelessWidget {
  final MachineStatus status;
  const _MachineStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case MachineStatus.running:
        color = context.theme.success;
        label = 'Machine Running';
        icon = Icons.circle;
        break;
      case MachineStatus.paused:
        color = context.theme.warning;
        label = 'Machine Paused';
        icon = Icons.pause_circle;
        break;
      case MachineStatus.error:
        color = context.theme.error;
        label = 'Machine Error';
        icon = Icons.error;
        break;
      default:
        color = context.theme.textMuted;
        label = 'Machine Idle';
        icon = Icons.circle_outlined;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == MachineStatus.running)
            _PulsingDot(color: color)
          else
            Icon(icon, color: color, size: 8),
          SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(color: color, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_animation.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
