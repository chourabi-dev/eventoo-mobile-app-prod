import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/event.dart';
import 'package:mobile/screens/welcome/welcome_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/services/fcm_service.dart';
import 'package:mobile/services/general_service.dart';
import 'package:mobile/theme/app_theme.dart';
import 'package:mobile/widgets/animated_button.dart';
import 'package:mobile/widgets/delete_account_sheet.dart';
import 'package:mobile/widgets/event_card.dart';
import 'package:mobile/widgets/language_switcher.dart';
import 'package:mobile/widgets/my_events_slider.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> with SingleTickerProviderStateMixin {
  String _fullname = '';
  String _email = '';
  String _phone = '';

  String _company = '';
  String _role = '';

  String _avatar = '';
  String _countryFlag = '';
  bool _isLoading = true; 
  List<Event> _events = []; 

  // ── Error states ──────────────────────────────────────────────
  bool _userInfoError = false;
  bool _myEventsError = false;
  bool _latestEventsError = false;
  bool _contactsError = false;
  // ─────────────────────────────────────────────────────────────

  final AuthService _authService = AuthService();
  final EventService _eventService = EventService();
  final GeneralGervice _generalGervice = GeneralGervice();
  FcmService fcmService = FcmService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _loadingEvents = true;
  List<Event> _myEvents = [];

  List<dynamic> _myContacts = [];
  List<dynamic> _businessCards = [];
  
  bool? emailValid; 
  bool _clickedOnSendValidationEmailButton = false;

  File? _image;

  Future<void> _pickAndCropImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
    });

    await _uploadImage(_image!);
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });
    _eventService.uploadImage(imageFile).then((res) async {
      final responseBody = await res.stream.bytesToString();
      print(responseBody);

      dynamic body = jsonDecode(responseBody);

      if (body['success']) {
        getUserInfo(); 
      } else {
        setState(() {
          _isLoading = false;
        }); 
      }
    }).catchError((err) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    getUserInfo();
    getUserEvents();
    registerUserFcm();
    getMyContacts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getUserInfo() async {
    setState(() {
      _isLoading = true;
      _userInfoError = false; // reset on retry
    });
    try {
      final res = await _authService.getUserInfo(); 
      final body = jsonDecode(res.body);

      print("user info"); 
      print(body); 

      final user = body['user'];
      final fullName = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();

      setState(() {
        _fullname = fullName.isEmpty ? 'User' : fullName;
        _email = user['email'] ?? '';
        _phone = user['phone'] ?? '';
        _company = user['company'] ?? '';
        _role = user['role'] ?? '';
        _countryFlag = user['country_flag'] ?? '';
        _avatar = user['photo'] ?? ''; 
        emailValid = user['emailValid'];
        _isLoading = false;
      }); 
      _animationController.forward();
    } catch (err) { 
      print("oups");
      print(err);
      setState(() {
        _isLoading = false;
        _userInfoError = true; // ← flag the error
      });
    }
  }

  Future<void> getUserEvents() async {
    setState(() {
      _loadingEvents = true;
      _myEventsError = false; // reset on retry
    });

    _eventService.getUserEventRegistrations().then((res) {
      dynamic body = jsonDecode(res.body);

      print("USER EVENTS REPONSE:");
      print(body);

      setState(() {
        _myEvents = (body['data'] as List)
            .map((item) => Event.fromJson(item))
            .toList();
        _loadingEvents = false;
      }); 
    }).catchError((err) {
      print("EER 1");
      print(err);
      setState(() {
        _loadingEvents = false;
        _myEventsError = true; // ← flag the error
      });
    }).then((d) {
      getLatestEvents();
    });
  }

  Future<void> getLatestEvents() async {
    setState(() {
      _loadingEvents = true;
      _latestEventsError = false; // reset on retry
    });

    _generalGervice.getEvents().then((res) {
      dynamic body = jsonDecode(res.body);

      print("ALL EVENTS");

      setState(() {
        _events = (body['data'] as List)
            .map((item) => Event.fromJson(item))
            .toList();
        _loadingEvents = false;
      }); 
    }).catchError((err) {
      print("EER 2");
      print(err);
      setState(() {
        _loadingEvents = false;
        _latestEventsError = true; // ← flag the error
      });
    });
  }

  Future<void> registerUserFcm() async {
    await fcmService.requestPermission();

    String? token = await fcmService.getDeviceToken();
    if (token != null) {
      print("FCM");
      print(token);
      
      final res = await _authService.updateAccountFCM(fcm: token);
      dynamic body = jsonDecode(res.body);
      print(body);
    }
  }

  Future<void> getMyContacts() async {
    print("GETTING CONTACTS LIST:...");
    setState(() {
      _contactsError = false; // reset on retry
    });
    try {
      final res = await _eventService.myContacts(); 
      final res2 = await _eventService.myBusinessCardsContacts(); 

      final body = jsonDecode(res.body);
      final body2 = jsonDecode(res2.body);

      setState(() {
        _myContacts = body['contacts'] ?? [];
        _businessCards = body2['contacts'] ?? [];
      });

      print(body);
    } catch (err) { 
      print(err);
      setState(() {
        _contactsError = true; // ← flag the error
      });
    }
  }

  // ── Reusable error + retry widget ────────────────────────────
  Widget _buildErrorRetry({
    required String message,
    required VoidCallback onRetry,
    double topPadding = 24,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, left: 24, right: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.red.shade400, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.red.shade300),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ─────────────────────────────────────────────────────────────

  Widget emailVerificationRequired(BuildContext context, VoidCallback onResend) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryButtonGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_unread_outlined,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.emailRequiredValidationTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.emailRequiredValidationContent,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _clickedOnSendValidationEmailButton == false
                  ? AnimatedButton(
                      gradient: AppTheme.secondaryButtonGradient,
                      onPressed: onResend,
                      text: l10n.emailRequiredValidationButton,
                      textColor: AppTheme.deepColor,
                    )
                  : Container(
                      child: Center(
                        child: Icon(Icons.check, color: Colors.green, size: 30),
                      ),
                    ),
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: AnimatedButton(
                    onPressed: () async {
                      setState(() {
                        emailValid = null; 
                      });
                      await getUserInfo();
                      if (emailValid == false) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(l10n.emailRequiredValidationTitle),
                              content: Text(l10n.emailNotValidDesptionPopUp),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    text: l10n.refreshLabel,
                    gradient: AppTheme.primaryButtonGradient,
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: TextButton(
                    child: Text(l10n.logout, style: TextStyle(color: Colors.grey)),
                    onPressed: () async {
                      final storage = FlutterSecureStorage();
                      await storage.deleteAll();
                      context.go('/');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> finishLogin(int eventId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    _eventService.authToEvent(eventID: eventId).then((res) async {
      dynamic response = jsonDecode(res.body);
      dynamic participantID = response['participantID'];
      bool success = response['success'];

      print("Connectiing ...");

      if (success == true) {
        if (participantID != null) { 
          print("WELCOME BACk");
          print(participantID);

          final storage = const FlutterSecureStorage();
          await storage.write(key: 'participantId', value: participantID.toString());

          if (context.mounted) context.go('/home'); 
        } 
      } else {
        if (context.mounted) Navigator.of(context).pop();
      }
    }).catchError((err) { 
      print(err);
      if (context.mounted) Navigator.of(context).pop();
    });
  }

  Widget _buildDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Drawer(
      backgroundColor: AppTheme.mainBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerItem(
              context,
              icon: Icons.event_rounded,
              title: l10n.joinedEvents,
              onTap: () => context.push("/my-events"),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.notifications_rounded,
              title: l10n.myContacts,
              onTap: () => context.push("/my-contacts"),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.credit_card_outlined,
              title: l10n.businessCardExchange,
              onTap: () => context.push('/business-cards'),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.delete,
              title: l10n.deleteMyAccount,
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => const DeleteAccountSheet(),
                );
              },
              textColor: Colors.red,
              iconColor: Colors.red,
            ),
            const Spacer(),
            _buildDrawerItem(
              context,
              icon: Icons.logout_sharp,
              title: l10n.logout,
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () async {
                final storage = FlutterSecureStorage();
                await storage.deleteAll(); 
                context.go('/');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color iconColor = Colors.black87,
    Color textColor = Colors.black87,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black38, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  _emptyEventsWidget() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              l10n.noEventsContent,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    // ── Full-page user info error (can't render anything useful) ──
    if (_userInfoError && !_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.mainBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 72, color: Colors.grey.shade400),
                const SizedBox(height: 20),
                Text(l10n.somethingWentWrongTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text( l10n.somethingWentWrongContent,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      getUserInfo();
                      getUserEvents();
                      getMyContacts();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.tryAgainLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    // ─────────────────────────────────────────────────────────────

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      drawer: _buildDrawer(context),
      body: emailValid == null
          ? const Center(child: CircularProgressIndicator())
          : emailValid == true
              ? CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildModernAppBar(context, size),

                    // ── My Events header ──
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l10n.myEventsLabel} (${_myEvents.length})',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${l10n.myEventsSubTitleDans}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => context.push('/my-events'),
                              child: Text(
                                l10n.seeAll,
                                style: TextStyle(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── My Events body: error OR slider OR empty ──
                    SliverToBoxAdapter(
                      child: _myEventsError
                          ? _buildErrorRetry(
                              message: 'Couldn\'t load your events. Please try again.',
                              onRetry: getUserEvents,
                            )
                          : _myEvents.isNotEmpty
                              ? SizedBox(
                                  height: 400,
                                  child: PremiumEventSlider(
                                    events: _myEvents,
                                    onContinue: (id) {
                                      print(id);
                                      finishLogin(int.parse(id));
                                    },
                                  ),
                                )
                              : _emptyEventsWidget(),
                    ),

                    // ── More Events header ──
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.only(top: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l10n.moreEvents} (${_events.length})',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${l10n.moreEventsSubtitle}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => context.push('/events'),
                              child: Text(
                                l10n.seeAll,
                                style: TextStyle(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Latest Events body: error OR slider ──
                    SliverToBoxAdapter(
                      child: _latestEventsError
                          ? _buildErrorRetry(
                              message: 'Couldn\'t load upcoming events. Please try again.',
                              onRetry: getLatestEvents,
                            )
                          : _events.isNotEmpty
                              ? SizedBox(
                                  height: 400,
                                  child: PremiumEventSlider(
                                    events: _events.take(5).toList(),
                                    onContinue: (id) {
                                      print(id);
                                      context.push('/events/$id/pick-profile');
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                    ),
                  ],
                )
              : emailVerificationRequired(context, () {
                  print("SENDING EMAIL TO:");
                  print(_email);

                  _authService.sendVerifyEmail(_email).then((res) {
                    dynamic body = jsonDecode(res.body);
                    print(body);
                  });

                  setState(() {
                    _clickedOnSendValidationEmailButton = true;
                  });
                }),
    );
  }

  Widget _buildModernAppBar(BuildContext context, Size size) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.accentColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: LanguageSwitcher(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(color: Colors.transparent),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _isLoading ? _buildLoadingSkeleton() : _buildProfileHeader(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        _shimmerCircle(80),
        SizedBox(height: 16),
        _shimmerBox(200, 24),
        SizedBox(height: 8),
        _shimmerBox(150, 16),
      ],
    );
  }

  Widget _shimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Hero(
                tag: 'profile-avatar',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: _avatar.isEmpty
                        ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                        : ClipOval(
                            child: Image.network(
                              _avatar,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.person, size: 50, color: Colors.grey[400]);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndCropImage,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(110, 185, 67, 1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _fullname,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.check_circle, size: 25, color: Colors.blue),
                  ],
                ),

                if (_role.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _role,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                if (_company.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _company,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 12),

                _buildActionButton(
                  l10n.editProfile,
                  Icons.edit_outlined,
                  Color.fromARGB(255, 57, 65, 53),
                  () async {
                    final result = await context.push<bool>('/update-profile');
                    if (result == true) getUserInfo();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AppLocalizations? l10n) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _loadingEvents == true
            ? Container(child: Center(child: CircularProgressIndicator()))
            : Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: _buildStatCard('${_myEvents.length}', l10n?.joinedEvents ?? 'Events', Icons.event),
                      onTap: () => context.push("/my-events"),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push("/my-contacts"),
                      child: _buildStatCard('${_myContacts.length}', l10n!.myContacts, Icons.people_outline),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push('/business-cards'),
                      child: _buildStatCard('${_businessCards.length}', l10n!.businessCardExchange, Icons.contacts_outlined),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF667eea), size: 28),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection(AppLocalizations l10n) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.moreEvents,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/events'),
                child: Text(
                  l10n.seeAll,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          ..._events.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: EventCard(
                event: e,
                onTap: () => context.push('/events/${e.id}/pick-profile'),
              ),
            );
          }).toList(),

          SizedBox(height: 24),
          _buildExploreButton(),
          SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _buildExploreButton() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.push('/events'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF667eea),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.exploreMoreEvents,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}