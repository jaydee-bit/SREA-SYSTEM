import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'package:latlong2/latlong.dart';
import '../services/notification_service.dart';
import '../models/incident_report_model.dart';
import 'incident_report_detail_screen.dart';
import 'profile_screen.dart';

enum NotificationType {
  alert,
  announcement,
  traffic,
  incidentStatus,
  accountVerified,
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? payload;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.payload,
  });

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes} min ago';
      return '${diff.inHours} hr ago';
    } else if (diff.inDays == 1)
      return 'Yesterday';
    return '${_monthAbbr(timestamp.month)} ${timestamp.day}';
  }

  String _monthAbbr(int m) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    // Load mock data after the first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _service.addListener(_refresh);
    });
  }

  @override
  void dispose() {
    _service.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() => _notifications = _service.notifications);

  void _loadInitialData() {
    if (_service.notifications.isEmpty) {
      // Public updates
      _service.addNotification(
        AppNotification(
          id: '1',
          type: NotificationType.alert,
          title: 'Flooding reported near Madlum river area',
          body:
              'Heavy flooding has affected several houses. Residents advised to evacuate.',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          payload: {'type': 'alert', 'id': 'alert_1'},
        ),
      );
      _service.addNotification(
        AppNotification(
          id: '2',
          type: NotificationType.traffic,
          title: 'Road closure along San Rafael–Angat highway',
          body:
              'The highway will be closed for repair from April 25 to April 30.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          payload: {'type': 'traffic', 'id': 'traffic_1'},
        ),
      );
      _service.addNotification(
        AppNotification(
          id: '3',
          type: NotificationType.announcement,
          title: 'Power interruption scheduled maintenance',
          body:
              'Power interruption on April 22 from 8 AM to 5 PM in Poblacion.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          payload: {'type': 'announcement', 'id': 'ann_1'},
        ),
      );
      // Private: incident status changes
      _service.addNotification(
        AppNotification(
          id: '4',
          type: NotificationType.incidentStatus,
          title: 'Incident status updated: Road Accident',
          body: 'Your incident report has been marked as Under Review.',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          payload: {'incidentId': '2'},
        ),
      );
      _service.addNotification(
        AppNotification(
          id: '5',
          type: NotificationType.incidentStatus,
          title: 'Incident resolved: Fire',
          body: 'Your incident report has been marked as Resolved.',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          payload: {'incidentId': '3'},
        ),
      );
      _service.addNotification(
        AppNotification(
          id: '6',
          type: NotificationType.accountVerified,
          title: 'Account verified!',
          body:
              'Your SREA account has been verified. You can now report incidents.',
          timestamp: DateTime.now().subtract(const Duration(days: 4)),
          payload: null,
        ),
      );
    }
    _refresh();
  }

  void _onTap(AppNotification n) {
    _service.markAsRead(n.id);
    switch (n.type) {
      case NotificationType.incidentStatus:
        if (n.payload?['incidentId'] != null) {
          final mockReport = IncidentReport(
            id: n.payload!['incidentId'],
            type: n.title.replaceAll('Incident status updated: ', ''),
            description: n.body,
            photoPath: null,
            barangay: 'Poblacion',
            locationDetails: '',
            coordinates: const LatLng(15.0153, 120.9996),
            address: 'San Rafael',
            status: n.body.contains('Resolved') ? 'Resolved' : 'Under Review',
            reportedAt: n.timestamp,
            reporterRole: 'resident',
            reporterIsVerified: true,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => IncidentReportDetailScreen(report: mockReport),
            ),
          );
        }
        break;
      case NotificationType.accountVerified:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Details coming soon')));
    }
  }

  void _markAllRead() => _service.markAllAsRead();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SreaColors.background,
      appBar: AppBar(
        backgroundColor: SreaColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: SreaColors.textOnPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: SreaText.titleLarge(
            context,
          ).copyWith(color: SreaColors.textOnPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              'Mark all read',
              style: SreaText.label(
                context,
              ).copyWith(color: SreaColors.textOnPrimary),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? _EmptyNotifications()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, i) => _NotificationCard(
                notification: _notifications[i],
                onTap: () => _onTap(_notifications[i]),
              ),
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    switch (notification.type) {
      case NotificationType.alert:
        icon = Icons.warning_amber_rounded;
        iconColor = SreaColors.critical;
        break;
      case NotificationType.traffic:
        icon = Icons.traffic_outlined;
        iconColor = SreaColors.high;
        break;
      case NotificationType.announcement:
        icon = Icons.campaign_outlined;
        iconColor = SreaColors.primary;
        break;
      case NotificationType.incidentStatus:
        icon = Icons.report_problem_outlined;
        iconColor = SreaColors.medium;
        break;
      case NotificationType.accountVerified:
        icon = Icons.verified_rounded;
        iconColor = SreaColors.low;
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SreaCard(
        onTap: onTap,
        color: notification.isRead ? null : SreaColors.primaryLight,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: SreaRadius.input,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: SreaText.bodySmall(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: SreaText.label(
                      context,
                    ).copyWith(color: SreaColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.formattedTime,
                    style: SreaText.label(
                      context,
                    ).copyWith(color: SreaColors.textHint),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: SreaColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: SreaColors.textHint),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: SreaText.bodyLarge(
              context,
            ).copyWith(color: SreaColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'You will see updates about alerts, incident reports, and account verification here.',
            style: SreaText.bodySmall(
              context,
            ).copyWith(color: SreaColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
