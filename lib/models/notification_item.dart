enum NotificationType { info, success, warning, error }

class NotificationItem {
  String title;
  String message;
  NotificationType type;
  DateTime timestamp;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}
