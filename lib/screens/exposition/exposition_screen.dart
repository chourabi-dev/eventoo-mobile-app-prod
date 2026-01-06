import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/stand_model.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/widgets/stand_card.dart';
import 'dart:ui';

class ExpositionsScreen extends StatefulWidget {
  const ExpositionsScreen({super.key});

  @override
  State<ExpositionsScreen> createState() => _ExpositionsScreenState();
}

class _ExpositionsScreenState extends State<ExpositionsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoading = true;
  List<Stand> _stands = [];
  EventService eventService = EventService();


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _loadStands();
  }

  Future<void> _loadStands() async {
    
    eventService.expositionScreen().then((res){

      dynamic body = jsonDecode(res.body);

      dynamic data = body['data'];
      

      print(data);

      setState(() {
        _stands = (data as List) .map((e) => Stand.fromJson(e)).toList();
        _isLoading = false;
      });

    }).catchError((err){
      
      setState(() { 
        _isLoading = false;
      });
    });
    
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);



    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            //expandedHeight: 110,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    border: const Border(
                      bottom: BorderSide(color: Colors.black12),
                    ),
                  ),
                  child:  FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: EdgeInsets.only(left: 50, bottom: 16),
                    title: Text(
                      l10n.exposers,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _isLoading
                ? _buildLoadingGrid()
                : _stands.isEmpty
                ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noStandAvailable,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : _buildStandsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, __) => const _SkeletonCard(),
        childCount: 6,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
    );
  }

 
  Widget _buildStandsGrid() {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.08, 1, curve: Curves.easeOutCubic),
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: StandCard(stand: _stands[index]),
          ),
        );
      }, childCount: _stands.length),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
    );
  }
}

// ===================== SKELETON =====================

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEDEDED),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
