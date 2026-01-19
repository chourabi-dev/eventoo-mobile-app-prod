import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/invitation_model.dart';
import 'package:mobile/models/participant_model.dart';
import 'package:mobile/screens/networking_experience/tabs/participants_tabs.dart';
import 'package:mobile/screens/networking_experience/widgets/date_planifier.dart';
import 'package:mobile/screens/networking_experience/widgets/invitation_re_planifier.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/theme/app_theme.dart';

class NetworkingInvitationsTab extends StatefulWidget {
  const NetworkingInvitationsTab({Key? key}) : super(key: key);

  @override
  State<NetworkingInvitationsTab> createState() => _NetworkingInvitationsTabState();
}

class _NetworkingInvitationsTabState extends State<NetworkingInvitationsTab>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  bool _isLoading = false;
  late TabController _tabController;

  // Mock data - replace with your API calls
   List<Invitation> _incomingInvitations = [];

   List<Invitation> _outgoingInvitations = [];

  EventService eventService = EventService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });

    fetchInvitations();
  }



  void fetchInvitations(){
    setState(() {
      _isLoading = true;
    });


    eventService.myInvitations().then((res){

      dynamic body = jsonDecode(res.body);

      setState(() {
        _outgoingInvitations = (body['sentInvitations'] as List<dynamic>)
            .map((e) => Invitation.fromJson(e as Map<String, dynamic>))
            .toList();
      });

      setState(() {
        _incomingInvitations = (body['receivedInvitations'] as List<dynamic>)
            .map((e) => Invitation.fromJson(e as Map<String, dynamic>))
            .toList();
      });
 
      setState(() {
        _isLoading = false;
      });



    }).catchError((err){
        print(err.toString());

        setState(() {
          _isLoading = false;
          
        });
        _showErrorDialog("Network error");
    });
  }





  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleInvitationAction(
    int invitationId,
    int action, {
    DateTime? newDateTime,
  }) async {

    print(invitationId); 
    print(action);

    setState(() => _isLoading = true);


    eventService.updateInvitationStatus(invitationId,action, null, null).then((res){

        dynamic body = jsonDecode(res.body);
         setState(() => _isLoading = false);

        if( body['success'] == true ){
          _showSuccessDialog(body['message'] ?? "Invitation accepted");
          fetchInvitations();
        }else{

          _showErrorDialog( body['message'] ?? "Invitation accepted");
        }

      
    });

    
  }

  void _showSuccessDialog(int action) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        message: _getSuccessMessage(action, l10n),
      ),
    );
  }

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(message: message),
    );
  }

  String _getSuccessMessage(int action, AppLocalizations l10n) {
    switch (action) {
      case 1:
        return l10n.invitationAccepted;
      case 2:
        return l10n.invitationRejected;
      case 3:
        return l10n.invitationRescheduled;
      
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      
      body: Stack(
        children: [
          // Background gradient
          Container(
            
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
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
                              Icons.group,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                             l10n.myInvitations,
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

                // Custom Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.mainDeepBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color.fromRGBO(199, 18, 94, 1), Color.fromRGBO(107, 22, 81, 1)],
                        ),
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text( '${l10n.incoming}(${_incomingInvitations.length})'  ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.send_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text('${l10n.outgoing}(${_outgoingInvitations.length})'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInvitationsList(
                        _incomingInvitations,
                        InvitationType.incoming,
                        l10n,
                      ),
                      _buildInvitationsList(
                        _outgoingInvitations,
                        InvitationType.outgoing,
                        l10n,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.processing,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInvitationsList(
    List<Invitation> invitations,
    InvitationType type,
    AppLocalizations l10n,
  ) {
    if (invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == InvitationType.incoming
                  ? Icons.inbox_rounded
                  : Icons.send_rounded,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              type == InvitationType.incoming
                  ? l10n.noIncomingInvitations
                  : l10n.noOutgoingInvitations,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: InvitationCard(
            invitation: invitations[index],
            onAccept: () => _handleInvitationAction(
              invitations[index].id,
              1 ,
            ),
            onReject: () => _handleInvitationAction(
              invitations[index].id,
              2,
            ),
            onReschedule: (){
              print("RESENDING...");

              fetchInvitations();
            },
          ),
        );
      },
    );
  }
}

// Invitation Card Widget
class InvitationCard extends StatelessWidget {
  final Invitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onReschedule;

  const InvitationCard({
    Key? key,
    required this.invitation,
    required this.onAccept,
    required this.onReject,
    required this.onReschedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.mainDeepBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              // Header with photo and info
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Avatar with gradient ring
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color.fromRGBO(199, 18, 94, 1), Color.fromRGBO(107, 22, 81, 1)],
                        ),
                        
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: NetworkImage(invitation.photoUrl),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invitation.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDateTime(invitation.dateTime),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  invitation.location,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontFamily: 'Inter',
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
              ),
              
              
              // Status badge for outgoing
              if (invitation.type == InvitationType.outgoing)
              Column( 
                children: [
                  Container(
            key: const ValueKey('status'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.mainDeepBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: _StatusBadge(invitation.status!, l10n),
          ),
 
                ],
              ),
              
                

              // Actions / Status section
if (invitation.type == InvitationType.incoming)
  AnimatedSwitcher(
    duration: const Duration(milliseconds: 250),
    child: invitation.status == InvitationStatus.pending
        ? Container(
            key: const ValueKey('actions'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.mainDeepBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: l10n.reject,
                    icon: Icons.close_rounded,
                    color: const Color(0xFFEF4444),
                    onPressed: onReject,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: l10n.reschedule,
                    icon: Icons.schedule_rounded,
                    color: const Color(0xFFF59E0B),
                    onPressed: () => _showReschedulePicker(context, invitation.id),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: l10n.accept,
                    icon: Icons.check_rounded,
                    color: const Color(0xFF10B981),
                    onPressed: onAccept,
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          )
        : Container(
            key: const ValueKey('status'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
             color: AppTheme.mainDeepBackgroundColor,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: _StatusBadge(invitation.status!, l10n),
          ),
  ),

              

               
            ],
          ),
        ),
      ),
    );
  }


  Widget _StatusBadge(
  InvitationStatus status,
  AppLocalizations l10n,
) {
  final color = _getStatusColor(status);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          status == InvitationStatus.accepted
              ? Icons.check_circle_rounded
              : status == InvitationStatus.rejected
                  ? Icons.cancel_rounded
                  : Icons.hourglass_bottom_rounded,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          _getStatusText(status, l10n),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
            fontFamily: 'Inter',
          ),
        ),
      ],
    ),
  );
}


  void _showReschedulePicker(BuildContext context ,int invitationID ) async {
    
    final invitation = await showDialog<MeetingInvitation>(
      context: context,
      builder: (context) => MeetingInvitationReplanifierDialog(invitationID: invitationID),
    );

    onReschedule();

    
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow, ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Color _getStatusColor(InvitationStatus? status) {
    switch (status) {
      case InvitationStatus.accepted:
        return const Color(0xFF10B981);
      case InvitationStatus.rejected:
        return const Color(0xFFEF4444);
      case InvitationStatus.pending:
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _getStatusText(InvitationStatus? status, AppLocalizations l10n) {
    switch (status) {
      case InvitationStatus.accepted:
        return l10n.accepted;
      case InvitationStatus.rejected:
        return l10n.rejected;
      case InvitationStatus.pending:
      default:
        return l10n.pending;
    }
  }
}

// Action Button Widget
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? color : color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary ? Colors.white : color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : color,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Success Dialog
class SuccessDialog extends StatelessWidget {
  final String message;

  const SuccessDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withOpacity(0.1),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 40,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "ok",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Error Dialog
class ErrorDialog extends StatelessWidget {
  final String message;

  const ErrorDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF4444).withOpacity(0.1),
              ),
              child: const Icon(
                Icons.error_rounded,
                size: 40,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                 "ok",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Models
