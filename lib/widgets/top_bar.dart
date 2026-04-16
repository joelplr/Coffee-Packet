import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/notification_item.dart';
import '../theme/app_theme.dart';

class TopBar extends StatelessWidget {
  TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final pageTitle = _getPageTitle(provider.currentPage);
        return Container(
          height: 64,
          padding: EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: context.theme.surface,
            border: Border(bottom: BorderSide(color: context.theme.border, width: 1)),
          ),
          child: Row(
            children: [
              Text(
                pageTitle,
                style: GoogleFonts.inter(
                  color: context.theme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Spacer(),
              // Production counter if running
              if (provider.machineStatus == MachineStatus.running) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.theme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.theme.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.speed, color: context.theme.success, size: 14),
                      SizedBox(width: 6),
                      Text(
                        '${provider.currentRate} pkt/min',
                        style: GoogleFonts.inter(color: context.theme.success, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
              ],
              // Theme toggle
              _ThemeToggleButton(provider: provider),
              SizedBox(width: 12),
              // Notification bell
              _NotificationButton(provider: provider),
              SizedBox(width: 12),
              // Clock
              _LiveClock(),
            ],
          ),
        );
      },
    );
  }

  String _getPageTitle(NavPage page) {
    switch (page) {
      case NavPage.dashboard: return '📊 Production Dashboard';
      case NavPage.recipes: return '🧪 Recipe Management';
      case NavPage.machineControl: return '⚙️ Machine Control Panel';
      case NavPage.inventory: return '📦 Inventory Management';
      case NavPage.analytics: return '📈 Analytics & Reports';
      case NavPage.settings: return '👤 Settings';
    }
  }
}

class _ThemeToggleButton extends StatelessWidget {
  final AppProvider provider;
  const _ThemeToggleButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = provider.isDarkMode;
    return InkWell(
      onTap: provider.toggleTheme,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.theme.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.theme.border),
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: context.theme.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final AppProvider provider;
  const _NotificationButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showNotifications(context, provider),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.theme.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.theme.border),
        ),
        child: Stack(
          children: [
            Icon(Icons.notifications_rounded, color: context.theme.textSecondary, size: 20),
            if (provider.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: context.theme.error, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context, AppProvider provider) {
    provider.markAllRead();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: context.theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: context.theme.border)),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text('Notifications', style: GoogleFonts.inter(color: context.theme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, color: context.theme.textSecondary, size: 18)),
                  ],
                ),
              ),
              Divider(color: context.theme.border, height: 1),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: provider.notifications.length,
                  separatorBuilder: (_, __) => Divider(color: context.theme.border, height: 1),
                  itemBuilder: (ctx, i) {
                    final n = provider.notifications[i];
                    final color = _notificationColor(n.type);
                    return ListTile(
                      leading: Icon(_notificationIcon(n.type), color: color, size: 18),
                      title: Text(n.title, style: GoogleFonts.inter(color: context.theme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(n.message, style: GoogleFonts.inter(color: context.theme.textSecondary, fontSize: 11)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _notificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success: return AppTheme.success;
      case NotificationType.warning: return AppTheme.warning;
      case NotificationType.error: return AppTheme.error;
      default: return AppTheme.info;
    }
  }

  IconData _notificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success: return Icons.check_circle;
      case NotificationType.warning: return Icons.warning;
      case NotificationType.error: return Icons.error;
      default: return Icons.info;
    }
  }
}

class _LiveClock extends StatefulWidget {
  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late String _time;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _update();
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (!mounted) return false;
      setState(_update);
      return true;
    });
  }

  void _update() {
    _now = DateTime.now();
    _time = '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.theme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.theme.border),
      ),
      child: Text(
        _time,
        style: GoogleFonts.robotoMono(color: context.theme.textSecondary, fontSize: 13),
      ),
    );
  }
}