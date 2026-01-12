import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/theme/app_theme.dart';
import 'dart:ui';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isScanning = true;
  bool _flashOn = false;
  late AnimationController _animationController;

  bool _adding = false;

  EventService _eventService = EventService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _isScanning = false);

    _handleScannedData(barcode.rawValue!);
  }

  void _handleScannedData(String data) {
    // Stop scanning temporarily
    cameraController.stop();

    _showParticipantInfo(data);
  }

  void showSuccessDialog(
    BuildContext context, {
    String title = 'Success',
    String message = 'Operation completed successfully',
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Message
              Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Future<String?> _showAddToFavoriteDialog(BuildContext context, dynamic l10n) {
  final TextEditingController noticeController = TextEditingController();

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title:  Text(l10n.addToFavLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              l10n.addToFavDescription,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noticeController,
              maxLines: 3,
              decoration:  InputDecoration(
                labelText: l10n.noticeLabel,
                hintText: l10n.noticeDescription,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child:  Text(l10n.cancelLabel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, noticeController.text.trim());
            },
            child:  Text(l10n.confirmLabel),
          ),
        ],
      );
    },
  );
}




  void _showParticipantInfo(String participantData) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.surfaceColor.withOpacity(0.95),
                  AppTheme.cardColor.withOpacity(0.95),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _fetchParticipantInfo(participantData),

                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                l10n.loadingParticipant ??
                                    'Loading participant...',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildErrorView(l10n);
                      }

                      if (!snapshot.hasData) {
                        return _buildNotFoundView(l10n);
                      }

                      return _buildParticipantCard(
                        l10n,
                        snapshot.data!,
                        scrollController,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(_resumeScanning);
  }

  Widget _buildParticipantCard(
    l10n,

    Map<String, dynamic> participant,
    ScrollController scrollController,
  ) {
    //BUILDING PARTICIPANT
    print("BUIDLING PARTICIPANT");
    print(participant);

    if( participant['data'] == null ){
      return Container(
        child: Center(
          child: Icon(Icons.error),
        ),
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Profile Photo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: participant['data']['photoUrl'] != null
                  ? Image.network(
                      participant['data']['photoUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        );
                      },
                    )
                  : const Icon(Icons.person, size: 60, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          // Name
          Text(
            '${participant['data']['fullName']}'.trim(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Function
          if (participant['data']['profileLabel'] != null)
            Text(
              participant['data']['profileLabel'],
              style: TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 4),

          // Info Cards
          _buildInfoCard(
            icon: Icons.email,
            label: 'Email',
            value: participant['data']['email'] ?? 'N/A',
          ), 
          _buildInfoCard(
            icon: Icons.phone,
            label: 'Phone',
            value: participant['data']['phone'] ?? 'N/A',
          ), 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...(participant['data']['feilds'] as List)
                  .where((f) => f['show_on_participant_page'] == true)
                  .map<Widget>(
                    (f) => _buildInfoCard(
                      icon: Icons.info,
                      label: '--',
                      value: f['value'] ?? 'N/A',
                    ),
                  )
                  .toList(),

              const SizedBox(height: 12),
            ],
          ),

           

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _adding == false
                    ? _buildActionButton(
                        icon: Icons.favorite,
                        label: l10n.connect,
                        gradient: AppTheme.primaryGradient,
                        onTap: () async {
                          final notice = await _showAddToFavoriteDialog(context, l10n);

                            if (notice != null) {
                              _eventService
                                  .addParticipantToMyFavoutites(
                                    participant['data']['id'],
                                    notice,
                                  )
                                  .then((res) {
                                    dynamic body = jsonDecode(res.body);
                                    print(body);
                                    showSuccessDialog(context);
                                  });
                            }
                        },
                      )
                    : Container(child: CircularProgressIndicator()),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.close,
                  label: l10n.close ?? 'Close',
                  gradient: AppTheme.accentGradient,
                  onTap: () {
                    Navigator.pop(context);
                    _resumeScanning();
                  },
                ),
              ),
            ],
          ),
       
       
       const SizedBox(height: 25),
       
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.errorLoadingParticipant ?? 'Error loading participant',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundView(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 80,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.participantNotFound ?? 'Participant not found',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // THIS IS USER ID NOT PARTICIPANT

  Future<Map<String, dynamic>> _fetchParticipantInfo(String userID) async {
    print(userID);

    final res = await _eventService.scanQRID(userID);

    final data = jsonDecode(res.body);

    return data;

    /*return {
      'id': 152651651, // 
      'first_name': 'John',
      'last_name': 'Doe',
      'function': 'Software Engineer',
      'company': 'Tech Corp',
      'email': 'john.doe@techcorp.com',
      'phone': '+1 234 567 8900',
      'country': 'USA',
      'town': 'San Francisco',
      'profile_photo': null,
    };*/
  }

  void _resumeScanning() {
    setState(() => _isScanning = true);
    cameraController.start();
  }

  void _toggleFlash() {
    setState(() => _flashOn = !_flashOn);
    cameraController.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.scanBadge ?? 'Scan Badge',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _flashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
            ),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera View
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          // Scanning Overlay
          CustomPaint(
            painter: ScannerOverlayPainter(
              borderColor: AppTheme.primaryColor,
              borderWidth: 4.0,
              overlayColor: Colors.black.withOpacity(0.5),
              animationValue: _animationController.value,
            ),
            child: Container(),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l10n.scanInstructions ?? 'Align QR code within the frame',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double animationValue;

  ScannerOverlayPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.overlayColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final Rect scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Draw overlay (darkened areas)
    final Paint overlayPaint = Paint()..color = overlayColor;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(scanRect, const Radius.circular(20)),
        ),
      ),
      overlayPaint,
    );

    // Draw corner borders
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double cornerLength = 30;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      borderPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top),
      Offset(left + scanAreaSize, top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + cornerLength),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanAreaSize - cornerLength),
      Offset(left, top + scanAreaSize),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + cornerLength, top + scanAreaSize),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - cornerLength),
      Offset(left + scanAreaSize, top + scanAreaSize),
      borderPaint,
    );

    // Draw scanning line
    final Paint linePaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double lineY = top + (scanAreaSize * animationValue);
    canvas.drawLine(
      Offset(left + 10, lineY),
      Offset(left + scanAreaSize - 10, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
