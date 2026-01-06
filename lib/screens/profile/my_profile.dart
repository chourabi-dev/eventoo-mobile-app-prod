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
import 'package:mobile/widgets/event_card.dart';
import 'package:mobile/widgets/language_switcher.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> with SingleTickerProviderStateMixin {
  String _fullname = '';
  String _email = '';
  String _phone = '';
  String _avatar = '';
  String _countryFlag = '';
  bool _isLoading = true; 
  List<Event> _events = []; 

  final AuthService _authService = AuthService();
  final EventService _eventService = EventService();
  final GeneralGervice _generalGervice = GeneralGervice();
  FcmService fcmService = FcmService();
  
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _loadingEvents = true;
  List<Event> _myEvents = [];

  List<dynamic> _myContacts = [];

  

    File? _image;

  Future<void> _pickAndCropImage() async {
    final ImagePicker picker = ImagePicker();

    // 1️⃣ Pick image
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) return;
 

    setState(() {
      _image = File(picked.path);
    });

    // 3️⃣ Upload
    await _uploadImage(_image!);
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isLoading = true;

    });
    _eventService.uploadImage(imageFile).then((res)async {
     final responseBody = await res.stream.bytesToString();
      print(responseBody);

      dynamic body = jsonDecode(responseBody);

        if( body['success'] ){
          getUserInfo(); 
        }

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
    getLatestEvents();
    registerUserFcm();
    getMyContacts();

  }

  

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getUserInfo() async {
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
        _countryFlag = user['country_flag'] ?? '';
        _avatar = user['photo'] ?? '';
        _isLoading = false;
      }); 
      _animationController.forward();
    } catch (err) { 
      print("oups");
      print(err);
      setState(() => _isLoading = false);
    }
  }



  Future<void> getUserEvents() async {
     // getUserEventRegistrations
     setState(() {
       _loadingEvents = true;
     });

    _eventService.getUserEventRegistrations().then((res){
      dynamic body = jsonDecode(res.body);
      List<dynamic> tmp = body['data'];

      setState(() {
        _myEvents = (body['data'] as List)
            .map((item) => Event.fromJson(item))
            .toList();
      });

     setState(() {
       _loadingEvents = false;
     }); 
    }).catchError((err){
      print("EER 1");
      print(err);
      
      setState(() {
        _loadingEvents = false;
      });
      
     
    });
    
  }




  Future<void> getLatestEvents() async {
     // getUserEventRegistrations
     setState(() {
       _loadingEvents = true;
     });

    _eventService.getCurrentEvents().then((res){
      dynamic body = jsonDecode(res.body);
      List<dynamic> tmp = body['data'];

      setState(() {
        _events = (body['data'] as List)
            .map((item) => Event.fromJson(item))
            .toList();
      });

     setState(() {
       _loadingEvents = false;
     }); 
    }).catchError((err){
      print("EER 2");
      print(err);

      setState(() {
        _loadingEvents = false;
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
    try {

      final res = await _eventService.myContacts(); 
      final body = jsonDecode(res.body);

      setState(() {
        _myContacts = body['contacts'] ?? [];
      });
      
 
      print(body);
      
    } catch (err) { 
      print(err);

      setState(() => _isLoading = false);
    }
  }





  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildModernAppBar(context, size),
          SliverToBoxAdapter(child: SizedBox(height: 24)),
          _buildStatsSection(l10n),
          SliverToBoxAdapter(child: SizedBox(height: 32)),
          _buildQuickActions(l10n),
          SliverToBoxAdapter(child: SizedBox(height: 32)),
          _buildEventsSection(l10n),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, Size size) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.white,
      elevation: 0,
      
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
            // Modern gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                    Color(0xFFf093fb),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Animated circles background
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
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
            // Blur overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(color: Colors.transparent),
            ),
            // Profile content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Avatar with edit button overlay
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
                  onTap: () async {
                     print("UPDATE IMAGE");
                     _pickAndCropImage();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.edit, size: 16, color: Color(0xFF667eea)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          // Name
          Text(
            _fullname,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          // Email
         Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.2),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.email_outlined, size: 14, color: Colors.white),
      SizedBox(width: 6),
      Flexible( // <-- prevents overflow in Row
        child: Text(
          _email, // first positional parameter
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis, // <-- handles overflow
          maxLines: 1, // <-- restrict to single line
        ),
      ),
    ],
  ),
)
,
          if (_phone.isNotEmpty) ...[
            SizedBox(height: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_outlined, size: 14, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    _phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection(AppLocalizations? l10n) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: 
        _loadingEvents == true ?
        Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
        :
        Row(
          children: [
            
            Expanded(child: GestureDetector(
              child: Container(child: _buildStatCard('${_myEvents.length}', l10n?.joinedEvents ?? 'Events', Icons.event)),
              onTap: (){
                context.push("/my-events");
              },
            )),
            SizedBox(width: 16),
            Expanded(child: GestureDetector(
              onTap: (){
                 context.push("/my-contacts");
              },
              child:  _buildStatCard( '${ _myContacts.length}'  , l10n!.myContacts, Icons.people_outline),
            ) ),
           SizedBox(width: 16),
            Expanded(child: _buildStatCard('128', l10n!.businessCardExchange, Icons.contacts_outlined)),
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

  Widget _buildQuickActions(AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickActions,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    l10n.editProfile,
                    Icons.edit_outlined,
                    Color(0xFF667eea),
                    () async {
                      final result = await context.push<bool>('/update-profile');
                      if (result == true) {
                        getUserInfo();
                      }
                    },
                  ),
                ),
                /*SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    l10n.settings,
                    Icons.settings_outlined,
                    Color(0xFF764ba2),
                    () {
                      // Navigate to settings
                    },
                  ),
                ),*/

                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    l10n.logout,
                    Icons.logout,
                    Color.fromARGB(255, 195, 55, 55),
                    () async {
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
                l10n.moreEvents ,
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
                    color: Color(0xFF667eea),
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
                onTap: () {
                  context.push('/events/${e.id}/pick-profile');
                },
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
      child: Container(
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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