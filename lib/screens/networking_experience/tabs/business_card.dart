import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/business_card_model.dart'; 
import 'package:mobile/services/event_service.dart';

class BusinessCardExchangeTab extends StatefulWidget {
  const BusinessCardExchangeTab({Key? key}) : super(key: key);

  @override
  State<BusinessCardExchangeTab> createState() => _BusinessCardExchangeTabState();
}

class _BusinessCardExchangeTabState extends State<BusinessCardExchangeTab>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  bool _isLoading = false;
  late TabController _tabController;

  List<BusinessCard> _incomingRequests = [];
  List<BusinessCard> _outgoingRequests = [];

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

    fetchBusinessCardRequests();
  }

  void fetchBusinessCardRequests() {
   setState(() {
      _isLoading = true;
    });

    // Replace this with your actual API endpoint
    eventService.myBusinessCardsInvitations().then((res) {
      dynamic body = jsonDecode(res.body);

      print(body);

      setState(() {
        _outgoingRequests = (body['sentInvitations'] as List<dynamic>)
            .map((e) => BusinessCard.fromJson(e as Map<String, dynamic>))
            .toList();
      });

      setState(() {
        _incomingRequests = (body['receivedInvitations'] as List<dynamic>)
            .map((e) => BusinessCard.fromJson(e as Map<String, dynamic>))
            .toList();
      });

      setState(() {
        _isLoading = false;
      });
    }).catchError((err) {
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

  Future<void> _handleRequestAction(
    int requestId,
    int action, // 1 = accept, 2 = reject
  ) async {
    setState(() => _isLoading = true);

    try {
      

      await eventService.handleBusinessCardRequest(requestId, action);
      
      
      
      fetchBusinessCardRequests();
      _showSuccessDialog(action);

    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Failed to process request");
    }
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
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(message: message),
    );
  }

  String _getSuccessMessage(int action, AppLocalizations l10n) {
    switch (action) {
      case 1:
        return /**l10n.businessCardAccepted ?? */ "Business card accepted!";
      case 2:
        return /**l10n.businessCardRejected ?? */ "Business card rejected";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFE9ECEF).withOpacity(0.5),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.credit_card_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                             l10n.businessCardExchange,
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
                    ],
                  ),
                ),

                // Custom Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
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
                              const Icon(
                                Icons.call_received_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${l10n.incoming }(${_incomingRequests.length})',
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.call_made_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${l10n.outgoing }(${_outgoingRequests.length})',
                              ),
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
                      _buildRequestsList(
                        _incomingRequests,
                        BusinessCardRequestType.incoming,
                        l10n,
                      ),
                      _buildRequestsList(
                        _outgoingRequests,
                        BusinessCardRequestType.outgoing,
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

  Widget _buildRequestsList(
    List<BusinessCard> requests,
    BusinessCardRequestType type,
    AppLocalizations l10n,
  ) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
              ),
              child: Icon(
                type == BusinessCardRequestType.incoming
                    ? Icons.call_received_rounded
                    : Icons.call_made_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              type == BusinessCardRequestType.incoming
                  ? l10n.noIncomingBusinessCards
                  : l10n.noOutgoingBusinessCards ,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: requests.length,
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
          child: BusinessCardRequestCard(
            businessCard: requests[index],
            onAccept: () => _handleRequestAction(
              requests[index].id,
              1,
            ),
            onReject: () => _handleRequestAction(
              requests[index].id,
              2,
            ),
          ),
        );
      },
    );
  }
}

// Business Card Request Card Widget
class BusinessCardRequestCard extends StatelessWidget {
  final BusinessCard businessCard;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const BusinessCardRequestCard({
    Key? key,
    required this.businessCard,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: NetworkImage(businessCard.photoUrl),
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
                            businessCard.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),

                          if( businessCard.status == BusinessCardStatus.accepted )
                            Column(
                              children: [
                                 Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 10,),

                              Text("${businessCard.phone}")
                               
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 10,),
                              
                              Text("${businessCard.email}")
                               
                            ],
                          ),
                          const SizedBox(height: 8),
                              ],
                            ),

                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDateTime(businessCard.requestDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontFamily: 'Inter',
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
              if (businessCard.type == BusinessCardRequestType.outgoing)
                Container(
                  key: const ValueKey('status'),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: _StatusBadge(businessCard.status!, l10n),
                ),

              // Actions for incoming
              if (businessCard.type == BusinessCardRequestType.incoming)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: businessCard.status == BusinessCardStatus.pending
                      ? Container(
                          key: const ValueKey('actions'),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border(
                              top: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  label: l10n.reject ,
                                  icon: Icons.close_rounded,
                                  color: const Color(0xFFEF4444),
                                  onPressed: onReject,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: _ActionButton(
                                  label: l10n.accept ,
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
                            color: Colors.grey[50],
                            border: Border(
                              top: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: _StatusBadge(businessCard.status!, l10n),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _StatusBadge(
    BusinessCardStatus status,
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
            status == BusinessCardStatus.accepted
                ? Icons.check_circle_rounded
                : status == BusinessCardStatus.rejected
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Color _getStatusColor(BusinessCardStatus? status) {
    switch (status) {
      case BusinessCardStatus.accepted:
        return const Color(0xFF10B981);
      case BusinessCardStatus.rejected:
        return const Color(0xFFEF4444);
      case BusinessCardStatus.pending:
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _getStatusText(BusinessCardStatus? status, AppLocalizations l10n) {
    switch (status) {
      case BusinessCardStatus.accepted:
        return l10n.accepted;
      case BusinessCardStatus.rejected:
        return l10n.rejected ;
      case BusinessCardStatus.pending:
      default:
        return l10n.pending ;
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
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary ? Colors.white : color,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
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
                child: const Text(
                  "OK",
                  style: TextStyle(
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
                child: const Text(
                  "OK",
                  style: TextStyle(
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