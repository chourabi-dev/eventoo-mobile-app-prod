import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'dart:convert';

import 'package:mobile/services/event_service.dart';
import 'package:mobile/theme/app_theme.dart';

// Models
class MeetingsResponse {
  final bool success;
  final List<DailyPlanning> planning;

  MeetingsResponse({required this.success, required this.planning});

  factory MeetingsResponse.fromJson(Map<String, dynamic> json) {
    return MeetingsResponse(
      success: json['success'],
      planning: (json['planning'] as List)
          .map((e) => DailyPlanning.fromJson(e))
          .toList(),
    );
  }
}

class DailyPlanning {
  final String date;
  final List<Meeting> meetings;

  DailyPlanning({required this.date, required this.meetings});

  factory DailyPlanning.fromJson(Map<String, dynamic> json) {
    return DailyPlanning(
      date: json['date'],
      meetings:
          (json['meetings'] as List).map((e) => Meeting.fromJson(e)).toList(),
    );
  }
}

class Meeting {
  final int id;
  final String status;
  final String fullName;
  final String photoUrl;
  final DateTime dateTime;
  final String location;
  final String type;
  final String time;

  Meeting({
    required this.id,
    required this.status,
    required this.fullName,
    required this.photoUrl,
    required this.dateTime,
    required this.location,
    required this.type,
    required this.time,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      status: json['status'],
      fullName: json['fullName'],
      photoUrl: json['photoUrl'],
      dateTime: DateTime.parse(json['dateTime']),
      location: json['location'],
      type: json['type'],
      time: json['time'],
    );
  }
}

// Main Screen
class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({Key? key}) : super(key: key);

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late MeetingsResponse _meetingsData;
  bool _isLoading = true;
  EventService eventService = EventService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadMeetings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMeetings() async {
    setState(() {
      _isLoading = true;
    });

    eventService.myPlanning().then((res){

      setState(() {
        _meetingsData = MeetingsResponse.fromJson(json.decode(res.body));
        _isLoading = false;
      });

      _animationController.forward();

    });
    
    

    
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      
     
     
      body: 
      
          _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _loadMeetings,
              color: const Color(0xFF6366F1),
              child: 
              
              Column(
                children: [
                  Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 50, bottom: 35),
                  child:  Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color.fromRGBO(199, 18, 94, 1), Color.fromRGBO(107, 22, 81, 1)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(199, 18, 94, 1).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                             l10n.myMeetings,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                                fontFamily: 'Poppins',
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                ),
                Expanded(
                  child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _meetingsData.planning.length,
                itemBuilder: (context, index) { 
                  return _buildDaySection(
                    _meetingsData.planning[index],
                    index,
                  );
                },
              ),
                )
                ],
              )
              


            ),
    );
  }

  Widget _buildLoadingState() {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.loadingParticipant,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(DailyPlanning dayPlanning, int sectionIndex) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          sectionIndex * 0.1,
          0.5 + (sectionIndex * 0.1),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader(dayPlanning.date),
          const SizedBox(height: 12),
          ...dayPlanning.meetings.asMap().entries.where((m)=> m.value.status =="accepted" ).map((entry) {
            return _buildMeetingCard(
              entry.value,
              entry.key,
              sectionIndex,
            );
          }).toList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    final l10n = AppLocalizations.of(context);


    final parsedDate = DateFormat('dd/MM/yyyy').parse(date);
    final formattedDate = DateFormat('EEEE, MMMM d').format(parsedDate);
    final isToday = _isToday(parsedDate);
    final isTomorrow = _isTomorrow(parsedDate);

    String displayText = formattedDate;
    if (isToday) displayText = '${l10n.todayLabel}, $formattedDate';
    if (isTomorrow) displayText = '${l10n.tomorrowLabel}, $formattedDate';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(width: 8),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(Meeting meeting, int index, int sectionIndex) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.1 + (sectionIndex * 0.1) + (index * 0.05),
          0.6 + (sectionIndex * 0.1) + (index * 0.05),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(30 * (1 - animation.value), 0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showMeetingDetails(meeting),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildTimeColumn(meeting),
                  const SizedBox(width: 16),
                  _buildVerticalDivider(meeting),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMeetingInfo(meeting),
                  ),
                  _buildMeetingTypeIcon(meeting),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(Meeting meeting) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          meeting.time,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getStatusColor(meeting.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            l10n.accepted,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(meeting.status),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(Meeting meeting) {
    return Container(
      width: 4,
      height: 60,
      decoration: BoxDecoration(
        color: meeting.type == 'incoming'
            ? const Color(0xFF10B981)
            : const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMeetingInfo(Meeting meeting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(meeting.photoUrl),
              onBackgroundImageError: (_, __) {},
              child: meeting.photoUrl.contains('blank.png')
                  ? Text(
                      meeting.fullName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meeting.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          meeting.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeetingTypeIcon(Meeting meeting) {
    final isIncoming = meeting.type == 'incoming';
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isIncoming
            ? const Color(0xFF10B981).withOpacity(0.1)
            : const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
        size: 20,
        color: isIncoming ? const Color(0xFF10B981) : const Color(0xFF6366F1),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'declined':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  void _showMeetingDetails(Meeting meeting) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMeetingDetailsSheet(meeting),
    );
  }

  Widget _buildMeetingDetailsSheet(Meeting meeting) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(meeting.photoUrl),
                onBackgroundImageError: (_, __) {},
                child: meeting.photoUrl.contains('blank.png')
                    ? Text(
                        meeting.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meeting.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(meeting.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.accepted,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(meeting.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow(
            Icons.access_time,
            l10n.timeLabel,
            '${meeting.time} - ${DateFormat('EEEE, MMMM d, y').format(meeting.dateTime)}',
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.location_on,
            l10n.locationLabel,
            meeting.location,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.swap_vert,
            'Type',
            meeting.type == 'incoming' ? l10n.incoming : l10n.outgoing,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
             /* Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),*/
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
 