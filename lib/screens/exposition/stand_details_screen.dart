
import 'package:flutter/material.dart';
import 'package:mobile/models/stand_model.dart';
import 'package:mobile/widgets/youtube_player.dart';
import 'package:url_launcher/url_launcher.dart';


class StandDetailScreen extends StatefulWidget {
  final Stand stand;

  const StandDetailScreen({super.key, required this.stand});

  @override
  State<StandDetailScreen> createState() => _StandDetailScreenState();
}

class _StandDetailScreenState extends State<StandDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final success = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Cover Photo
          SliverAppBar(
            iconTheme: IconThemeData(
              color: Colors.white
            ),
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color.fromARGB(255, 189, 186, 248),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.stand.coverPhoto,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 70,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        // Logo
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              widget.stand.logo,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.stand.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.stand.provider,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Contact Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.email, widget.stand.email),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.location_on, widget.stand.location),
                      if (widget.stand.websiteUrl != null) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _launchUrl(widget.stand.websiteUrl!),
                          child: _buildInfoRow(
                            Icons.language,
                            widget.stand.websiteUrl!,
                            isLink: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About', // l10n.about
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.stand.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Tags
                if (widget.stand.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.stand.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF6C63FF).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: Color(0xFF6C63FF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 20),
                
                // Social Media
                if (widget.stand.socialMedia.links.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connect With Us', // l10n.connectWithUs
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: widget.stand.socialMedia.links.map((link) {
                            return GestureDetector(
                              onTap: () => _launchUrl(link.url),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: link.color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: link.color.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  link.icon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),      // Tabs
      SliverPersistentHeader(
        pinned: true,
        delegate: _SliverAppBarDelegate(
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF6C63FF),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF6C63FF),
            tabs: [
              Tab(
                text: 'Products (${widget.stand.products.length})',
              ),
              Tab(
                text: 'Videos (${widget.stand.videos.length})',
              ),
              Tab(
                text: 'Catalogues (${widget.stand.catalogues.length})',
              ),
            ],
          ),
        ),
      ),

      // Tab Content
      SliverFillRemaining(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsTab(),
            _buildVideosTab(),
            _buildCataloguesTab(),
          ],
        ),
      ),
    ],
  ),
);
}
Widget _buildInfoRow(IconData icon, String text, {bool isLink = false}) {
return Row(
children: [
Icon(
icon,
size: 20,
color: const Color(0xFF6C63FF),
),
const SizedBox(width: 12),
Expanded(
child: Text(
text,
style: TextStyle(
fontSize: 14,
color: isLink ? const Color(0xFF6C63FF) : Colors.grey[700],
decoration: isLink ? TextDecoration.underline : null,
),
),
),
],
);
}
Widget _buildProductsTab() {
if (widget.stand.products.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[400]),
const SizedBox(height: 16),
Text(
'No products available',
style: TextStyle(color: Colors.grey[600]),
),
],
),
);
}
return ListView.builder(
  padding: const EdgeInsets.all(20),
  itemCount: widget.stand.products.length,
  itemBuilder: (context, index) {
    final product = widget.stand.products[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Image.network(
              product.image,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 60),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  },
);
}
Widget _buildVideosTab() {
if (widget.stand.videos.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.videocam_outlined, size: 60, color: Colors.grey[400]),
const SizedBox(height: 16),
Text(
'No videos available',
style: TextStyle(color: Colors.grey[600]),
),
],
),
);
}
return ListView.builder(
  padding: const EdgeInsets.all(20),
  itemCount: widget.stand.videos.length,
  itemBuilder: (context, index) {
    final video = widget.stand.videos[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: YoutubeFramePlayer(videoUrl: video.iframeUrl, base: "https://www.youtube-nocookie.com")
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              video.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  },
);
}
Widget _buildCataloguesTab() {
if (widget.stand.catalogues.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.picture_as_pdf_outlined, size: 60, color: Colors.grey[400]),
const SizedBox(height: 16),
Text(
'No catalogues available',
style: TextStyle(color: Colors.grey[600]),
),
],
),
);
}
return GridView.builder(
  padding: const EdgeInsets.all(20),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 0.7,
  ),
  itemCount: widget.stand.catalogues.length,
  itemBuilder: (context, index) {
    final catalogue = widget.stand.catalogues[index];
    return GestureDetector(
      onTap: () => _launchUrl(catalogue.pdfUrl),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.picture_as_pdf,
                      size: 60,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                catalogue.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  },
);
}
}
// ============================================================================
// SLIVER APP BAR DELEGATE (FOR PINNED TABS)
// ============================================================================
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
final TabBar _tabBar;
_SliverAppBarDelegate(this._tabBar);
@override
double get minExtent => _tabBar.preferredSize.height;
@override
double get maxExtent => _tabBar.preferredSize.height;
@override
Widget build(
BuildContext context,
double shrinkOffset,
bool overlapsContent,
) {
return Container(
color: Colors.white,
child: _tabBar,
);
}
@override
bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
return false;
}
}