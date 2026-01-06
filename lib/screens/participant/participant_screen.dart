import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/participant_model.dart';
import 'package:mobile/screens/chat_screen/chat_screen.dart';
import 'package:mobile/services/event_service.dart';

class ParticipantDetailScreen extends StatefulWidget {
  final Participant participant;

  const ParticipantDetailScreen({super.key, required this.participant});

  @override
  State<ParticipantDetailScreen> createState() =>
      _ParticipantDetailScreenState();
}

class _ParticipantDetailScreenState extends State<ParticipantDetailScreen> {
  final EventService _eventService = EventService();

  bool _isAddingToFav = false;
  bool _isFavourite = false;

  Participant get participant => widget.participant;
  EventService eventService = EventService();
  

  // ================= FAVORITE ACTION =================

  Future<void> _addToFavourite() async {
     
    setState(() => _isAddingToFav = true);

    try {
      final body = await _eventService.addParticipantToMyFavoutites(
        participant.id,
        ""
      );
      dynamic res = jsonDecode(body.body);

      if (res != null && res['success'] == true) {
        setState(() => _isFavourite = true);

        _showToast(
          context,
          message: res['message'] ?? 'Added to favourites',
          success: true,
        );
      } else {
        _showToast(
          context,
          message: res['message'] ?? 'Something went wrong',
          success: false,
        );
      }
    } catch (_) {
      _showToast(
        context,
        message: 'Server error, please try again',
        success: false,
      );
    } finally {
      setState(() => _isAddingToFav = false);
    }
  }


  Future<void>  _removeFromContact() async {
     
    setState(() => _isAddingToFav = true);

    try {
      final body = await _eventService.removeParticipantFromContactList(
        participant.id,
        
      );
      dynamic res = jsonDecode(body.body);

      if (res != null && res['success'] == true) {
        
        _showToast(
          context,
          message: res['message'] ?? 'Removed from favourites',
          success: true,
        );

        setState(() {
          _isFavourite = false;
        });

        
      } else {
        _showToast(
          context,
          message: res['message'] ?? 'Something went wrong',
          success: false,
        );
      }
    } catch (_) {
      _showToast(
        context,
        message: 'Server error, please try again',
        success: false,
      );
    } finally {
      setState(() => _isAddingToFav = false);
    }
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkAlreadyFav();
  }
  

  void checkAlreadyFav(){ 
    setState(() {
      _isAddingToFav = true;
    });

     eventService.myContacts().then((res){
      dynamic body = jsonDecode(res.body);

      print(body);

      List<dynamic> contacts = body['contacts'];

      for (var i = 0; i < contacts.length; i++) {
        if (contacts.elementAt(i)['participant_id'] == participant.id ) {
          setState(() {
            _isFavourite = true;

          });
        }
      }

      setState(() {
        _isAddingToFav = false;
      });

     });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  

                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          GestureDetector(
                    onTap: (){
                      if (_isAddingToFav) {
                        return;
                      }

                      if( _isFavourite == false ){
                        _addToFavourite();
                      }else{
                        _removeFromContact();
                      }
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isAddingToFav
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Color(0xFF6C63FF),
                                    ),
                                  )
                                : Icon(
                                    _isFavourite ? Icons.favorite  : Icons.favorite_border,
                                    color: _isFavourite
                                        ? Colors.redAccent
                                        : const Color(0xFF6C63FF),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(l10n.addToFavourites,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(width: 35,),



                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, new MaterialPageRoute(builder: (context) =>  new ChatScreen(participant: participant.id),));
                      
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Center(
                            child:  Icon( Icons.chat, color: Colors.blue.shade300, ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Chat",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  


                      ],
                    ),
                  ),



                  const SizedBox(height: 24),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  if (participant.feilds.isNotEmpty) _buildExtraCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(participant.photoUrl, fit: BoxFit.cover),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 16),
                  Text(
                    participant.fullName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00F5D4), // Miami cyan
                              Color(0xFF4D96FF), // Soft blue
                              Color(0xFFFF5EDF), // Miami pink
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF00F5D4).withOpacity(0.6),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          participant.profileLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
        ),
      ),
      child: CircleAvatar(
        radius: 52,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage(participant.photoUrl),
        ),
      ),
    );
  }

  // ================= INFO =================

  Widget _buildInfoCard() {
    return _card(
      children: [
        //_infoRow(Icons.email_outlined, 'Email', participant.email),
        //_infoRow(Icons.phone_outlined, 'Phone', participant.phone),
        _infoRow(Icons.flag_outlined, 'Country', participant.country.name),
      ],
    );
  }

  Widget _buildExtraCard() {
    final l10n = AppLocalizations.of(context);
    return _card(
      title: l10n.additonalDetails,
      children: participant.feilds
          .where((e) => e.showOnParticipantPage == true)
          .map(
            (e) => _infoRow(
              Icons.info_outline,
              e.label,
              e.type == 'multiCheckbox'
                  ? (e.multipleValuesSelected?.join(', ') ?? '')
                  : (e.value?.toString() ?? ''),
            ),
          )
          .toList(),
    );
  }

  // ================= REUSABLE =================

  Widget _card({String? title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= TOAST =================

  void _showToast(
    BuildContext context, {
    required String message,
    required bool success,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 90,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: success ? Colors.green.shade600 : Colors.red.shade600,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), entry.remove);
  }
}
