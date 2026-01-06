import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/theme/app_theme.dart';

class BadgeDisplayScreen extends StatefulWidget {
  final Map<String, dynamic> badgeSettings;
  final Map<String, dynamic> userData;

  const BadgeDisplayScreen({
    super.key,
    required this.badgeSettings,
    required this.userData,
  });

  @override
  State<BadgeDisplayScreen> createState() => _BadgeDisplayScreenState();
}

class _BadgeDisplayScreenState extends State<BadgeDisplayScreen> {
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();

    print(widget.userData);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _circleButton(
          icon: Icons.close,
          onTap: () => Navigator.pop(context),
        ),
        actions: [
          // _circleButton(icon: Icons.download, onTap: _downloadBadge),
          // _circleButton(icon: Icons.share, onTap: _shareBadge),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.surfaceColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  /// Scale slider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        const Icon(Icons.brightness_low, color: Colors.white70),
                        Expanded(
                          child: Slider(
                            value: _scale,
                            min: 0.7,
                            max: 1.3,
                            activeColor: AppTheme.primaryColor,
                            inactiveColor: Colors.white24,
                            onChanged: (v) => setState(() => _scale = v),
                          ),
                        ),
                        const Icon(Icons.brightness_high, color: Colors.white70),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Badge
                  Transform.scale(
                    scale: _scale,
                    child: _buildBadge(),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    'Pinch to zoom • Screenshot to save',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== BADGE =====================

  Widget _buildBadge() {
    final settings = widget.badgeSettings;
    final user = widget.userData;

    final String? modelUrl = settings['email_badge_background'];
    final String? backgroundUrl = modelUrl != null && modelUrl.isNotEmpty
        ? modelUrl.startsWith('http')
            ? modelUrl
            : 'https://eventoo.io$modelUrl'
        : null;

    return Container(
      width: 350,
      height: 600,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            /// Background
            if (backgroundUrl != null)
              Positioned.fill(
                child: Image.network(
                  backgroundUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackBackground(),
                ),
              ),

            /// CENTERED CONTENT (FIX)
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(height: 50),
                        if (_shouldShowField(settings['show_profile_photo']))
                          _buildProfilePhoto(user['photoUrl']),

                        const SizedBox(height: 5),

                        if (_shouldShowField(settings['profile_activate_view']))
                          _buildTextField(
                            text: user['profile'] ?? '',
                            size: _getDouble(settings['profile_size']),
                            bold: _getBool(settings['profile_bold']),
                            uppercase: _getBool(settings['profile_upper_case']),
                          ),

                        if (_shouldShowField(settings['first_name_activate_view']))
                          _buildTextField(
                            text: user['fullName'] ?? '',
                            size: _getDouble(settings['first_name_size']),
                            bold: _getBool(settings['first_name_bold']),
                            uppercase: _getBool(settings['first_name_upper_case']),
                          ),

                          if (_shouldShowField(settings['profile_activate_view']))
                          _buildTextField(
                            text: user['profileLabel'] ?? '',
                            size: _getDouble(settings['profile_size']),
                            bold: _getBool(settings['profile_bold']),
                            uppercase: _getBool(settings['profile_upper_case']),
                          ),

                        if (_shouldShowField(settings['contry_activate_view']))
                          _buildTextField(
                            text: user['country']?['name'] ?? '',
                            size: _getDouble(settings['contry_size']),
                            bold: _getBool(settings['country_bold']),
                            uppercase: _getBool(settings['country_uppercase']),
                          ),

                       ...(user['feilds'] as List).map<Widget>((f) {
                        if (settings['show_on_badge'] == true ) {
                          return const SizedBox.shrink();
                        }

                        return _buildTextField(
                          text: f['value']?.toString() ?? '',
                          size: _getDouble(settings['secondary_information_size']),
                          bold: _getBool(settings['secondary_information_bold']),
                          uppercase: _getBool(settings['secondary_information_uppercase']),
                        );
                      }).toList(),
                      
                        if (_shouldShowField(settings['qrcode_activate_view']))
                          _buildQRCode(user['userID']?.toString() ?? ''),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            )
          ],
        ),
      ),
    );
  }

  // ===================== WIDGETS =====================

  Widget _buildProfilePhoto(String? photoUrl) {
    final double size = _getDouble(widget.badgeSettings['profile_photo_width'], 120);

    if (photoUrl == null || photoUrl.isEmpty) {
      return _defaultAvatar(size);
    }

    final String fullUrl =
        photoUrl.startsWith('http') ? photoUrl : 'https://eventoo.io$photoUrl';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipOval(
        child: Image.network(
          fullUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultAvatar(size),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String text,
    required double size,
    required bool bold,
    required bool uppercase,
  }) {
    if (text.isEmpty || size == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        uppercase ? text.toUpperCase() : text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildQRCode(String data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: 120,
      ),
    );
  }

  // ===================== HELPERS =====================

  Widget _fallbackBackground() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.accentColor.withOpacity(0.1),
            ],
          ),
        ),
      );

  Widget _defaultAvatar(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.primaryGradient,
        ),
        child: const Icon(Icons.person, size: 60, color: Colors.white),
      );

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
      onPressed: onTap,
    );
  }

  bool _shouldShowField(dynamic v) =>
      v == true || v == 1 || v == '1' || v == 'true';

  bool _getBool(dynamic v) =>
      v == true || v == 1 || v == '1' || v == 'true';

  double _getDouble(dynamic v, [double fallback = 0]) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  void _downloadBadge() => _toast('Badge downloaded');
  void _shareBadge() => _toast('Badge shared');

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
