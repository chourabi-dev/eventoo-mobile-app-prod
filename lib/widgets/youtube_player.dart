/*import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YoutubeFramePlayer extends StatefulWidget {
  final String videoUrl; // URL d'embed (ex: www.youtube.com...)
  final String base;

  const YoutubeFramePlayer({super.key, required this.videoUrl, required this.base});

  @override
  State<YoutubeFramePlayer> createState() => _YoutubeFramePlayerState();
}

class _YoutubeFramePlayerState extends State<YoutubeFramePlayer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) => debugPrint('Erreur Webview: ${error.description}'),
        ),
      )
      // Indispensable pour YouTube Error 153 : Définir une origine de confiance
      ..loadHtmlString(
        '''
        <!DOCTYPE html>
        <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <!-- Politique de Referer exigée par YouTube et Meta en 2025 -->
            <meta name="referrer" content="strict-origin-when-cross-origin">
            <style>
              body { margin: 0; padding: 0; background-color: black; }
              .container { position: relative; width: 100%; height: 100vh; }
              iframe { border: none; width: 100%; height: 100%; }
            </style>
          </head>
          <body>
            <div class="container">
              <iframe 
                src="${widget.videoUrl}" 
                allow="autoplay; encrypted-media; picture-in-picture" 
                allowfullscreen
                referrerpolicy="strict-origin-when-cross-origin">
              </iframe>
            </div>
          </body>
        </html>
        ''',
        baseUrl: widget.base, // Base URL fictive mais nécessaire pour le Referer
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WebViewWidget(controller: _controller),
    );
  }
}*/




import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YoutubeFramePlayer extends StatefulWidget {
  final String videoUrl; // URL d'embed (ex: www.youtube.com...)
  final String base;

  const YoutubeFramePlayer({super.key, required this.videoUrl, required this.base});

  @override
  State<YoutubeFramePlayer> createState() => _YoutubeFramePlayerState();
}

class _YoutubeFramePlayerState extends State<YoutubeFramePlayer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) => debugPrint('Erreur Webview: ${error.description}'),
        ),
      )
      // Indispensable pour YouTube Error 153 : Définir une origine de confiance
      ..loadHtmlString(
        widget.videoUrl,
        baseUrl: widget.base
        
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WebViewWidget(controller: _controller),
    );
  }
}