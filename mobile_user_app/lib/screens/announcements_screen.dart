// File: announcements_screen.dart
// Path: mobile_user_app/lib/screens/announcements_screen.dart

import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'announcement_detail_screen.dart';

class Announcement {
  final int id;
  final String title;
  final String body;
  final DateTime publishedAt;
  final String? barangay; // null = general
  final String? imageUrl; // optional image URL

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
    this.barangay,
    this.imageUrl,
  });

  bool get isGeneral => barangay == null;

  bool isNew() {
    final difference = DateTime.now().difference(publishedAt);
    return difference.inDays < 1;
  }

  String get formattedDate {
    return '${_monthAbbr(publishedAt.month)} ${publishedAt.day}, ${publishedAt.year}';
  }

  String _monthAbbr(int month) {
    const months = [
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
    ];
    return months[month - 1];
  }
}

// Mock data with images (replace with real API)
final List<Announcement> _mockAnnouncements = [
  Announcement(
    id: 1,
    title: 'Municipal Hall Closed on April 25',
    body:
        'The San Rafael Municipal Hall will be closed on April 25, 2026, in observance of a local holiday. Regular operations will resume on April 26. For emergencies, please call MDRRMO hotline (044) 123-4567.',
    publishedAt: DateTime(2026, 4, 18),
    barangay: null,
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/8/8b/San_Rafael_Municipal_Hall%2C_Bulacan%2C_Jan_2026_%281%29.jpg', // example image
  ),
  Announcement(
    id: 2,
    title: 'Free Dengue Spraying – Barangay Poblacion',
    body:
        'The Municipal Health Office will conduct free dengue mosquito spraying in Barangay Poblacion on April 22, 2026, from 8:00 AM to 5:00 PM. Please keep windows and doors open during this time.',
    publishedAt: DateTime(2026, 4, 19),
    barangay: 'Poblacion',
    imageUrl: 'https://od2-image-api.abs-cbn.com/prod/editorImage/173986838233220240822-dengue-spray-old-balara-MT3.jpg',
  ),
  Announcement(
    id: 3,
    title: 'Disaster Preparedness Training',
    body:
        'Register now for the free Disaster Preparedness Training on May 5, 2026, at the Municipal Gym. Topics include first aid, evacuation procedures, and emergency communication. Limited slots available.',
    publishedAt: DateTime(2026, 4, 15),
    barangay: null,
    imageUrl: 'https://www.global-islamic.com/~img/bencana-9579a-3395_228-t598_25.webp',
  ),
  Announcement(
    id: 4,
    title: 'Road Repair – Barangay Sampaloc',
    body:
        'A section of the national highway in Barangay Sampaloc will be under repair from April 20 to April 25. Expect heavy traffic. Use alternate routes if possible.',
    publishedAt: DateTime(2026, 4, 20), // today – will show NEW badge
    barangay: 'Sampaloc',
    imageUrl: null,
  ),
];

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  bool _isLoading = true;
  List<Announcement> _announcements = [];

  // TODO: Replace with actual user data
  final bool _isResident = true;
  final String _userBarangay = 'Poblacion';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final filtered = _filterAnnouncements(_mockAnnouncements);
    setState(() {
      _announcements = filtered;
      _isLoading = false;
    });
  }

  List<Announcement> _filterAnnouncements(List<Announcement> all) {
    if (!_isResident) {
      return all.where((a) => a.isGeneral).toList();
    } else {
      return all
          .where((a) => a.isGeneral || a.barangay == _userBarangay)
          .toList();
    }
  }

  Future<void> _refresh() async {
    await _loadAnnouncements();
  }

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
          'Announcements',
          style: SreaText.titleLarge(
            context,
          ).copyWith(color: SreaColors.textOnPrimary),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: SreaColors.primary,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: SreaColors.primary),
                )
              : _announcements.isEmpty
              ? _EmptyAnnouncements()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = _announcements[index];
                    return _AnnouncementCard(
                      announcement: announcement,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnnouncementDetailScreen(
                              announcement: announcement,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback onTap;

  const _AnnouncementCard({required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isNew = announcement.isNew();
    final isBarangaySpecific = !announcement.isGeneral;
    final hasLongBody = announcement.body.length > 120;
    final preview = hasLongBody
        ? '${announcement.body.substring(0, 120)}...'
        : announcement.body;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SreaCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optional image
            if (announcement.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(SreaRadius.md),
                child: Image.network(
                  announcement.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Title row with NEW badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    announcement.title,
                    style: SreaText.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: SreaColors.textPrimary,
                    ),
                  ),
                ),
                if (isNew)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: SreaColors.primary,
                      borderRadius: SreaRadius.pill,
                    ),
                    child: Text(
                      'NEW',
                      style: SreaText.label(context).copyWith(
                        color: SreaColors.textOnPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // Date and barangay tag (if any)
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: SreaColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  announcement.formattedDate,
                  style: SreaText.label(
                    context,
                  ).copyWith(color: SreaColors.textHint),
                ),
                if (isBarangaySpecific) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.location_on_outlined,
                    size: 12,
                    color: SreaColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    announcement.barangay!,
                    style: SreaText.label(
                      context,
                    ).copyWith(color: SreaColors.primary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            // Body preview
            Text(
              preview,
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: SreaColors.textSecondary, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Read more indicator (only if body is long)
            if (hasLongBody)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Read more →',
                  style: SreaText.label(context).copyWith(
                    color: SreaColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAnnouncements extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 64, color: SreaColors.textHint),
          const SizedBox(height: 16),
          Text(
            'No announcements',
            style: SreaText.bodyLarge(
              context,
            ).copyWith(color: SreaColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates from MDRRMO.',
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
