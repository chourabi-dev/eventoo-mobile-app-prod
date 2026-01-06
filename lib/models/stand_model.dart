import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Stand {
  final int id;
  final String name;
  final String logo;
  final String coverPhoto;
  final String email;
  final String provider;
  final String description;
  final List<String> tags;
  final String location;
  final String? websiteUrl;
  final SocialMedia socialMedia;
  final bool isClickable;
  final List<Product> products;
  final List<Video> videos;
  final List<Catalogue> catalogues;

  Stand({
    required this.id,
    required this.name,
    required this.logo,
    required this.coverPhoto,
    required this.email,
    required this.provider,
    required this.description,
    required this.tags,
    required this.location,
    this.websiteUrl,
    required this.socialMedia,
    required this.isClickable,
    required this.products,
    required this.videos,
    required this.catalogues,
  });

  factory Stand.fromJson(Map<String, dynamic> json) {
    return Stand(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      coverPhoto: json['coverPhoto'],
      email: json['email'],
      provider: json['provider'],
      description: json['description'],
      tags: List<String>.from(json['tags'] ?? []),
      location: json['location'],
      websiteUrl: json['websiteUrl'],
      socialMedia: SocialMedia.fromJson(json['socialMedia']),
      isClickable: json['isClickable'] ?? true,
      products: (json['products'] as List?)
              ?.map((p) => Product.fromJson(p))
              .toList() ??
          [],
      videos: (json['videos'] as List?)
              ?.map((v) => Video.fromJson(v))
              .toList() ??
          [],
      catalogues: (json['catalogues'] as List?)
              ?.map((c) => Catalogue.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class SocialMedia {
  final String? linkedin;
  final String? instagram;
  final String? whatsapp;
  final String? twitter;
  final String? facebook;
  final String? skype;

  SocialMedia({
    this.linkedin,
    this.instagram,
    this.whatsapp,
    this.twitter,
    this.facebook,
    this.skype,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      linkedin: json['linkedin'],
      instagram: json['instagram'],
      whatsapp: json['whatsapp'],
      twitter: json['twitter'],
      facebook: json['facebook'],
      skype: json['skype'],
    );
  }

List<SocialLink> get links {
  final list = <SocialLink>[];

  if (linkedin?.isNotEmpty == true) {
    list.add(SocialLink(
      'LinkedIn',
      linkedin!,
      FontAwesomeIcons.linkedin,
      const Color(0xFF0A66C2),
    ));
  }

  if (instagram?.isNotEmpty == true) {
    list.add(SocialLink(
      'Instagram',
      instagram!,
      FontAwesomeIcons.instagram,
      const Color(0xFFE4405F),
    ));
  }

  if (whatsapp?.isNotEmpty == true) {
    list.add(SocialLink(
      'WhatsApp',
      whatsapp!,
      FontAwesomeIcons.whatsapp,
      const Color(0xFF25D366),
    ));
  }

  if (twitter?.isNotEmpty == true) {
    list.add(SocialLink(
      'Twitter / X',
      twitter!,
      FontAwesomeIcons.xTwitter, // new X logo
      Colors.black,
    ));
  }

  if (facebook?.isNotEmpty == true) {
    list.add(SocialLink(
      'Facebook',
      facebook!,
      FontAwesomeIcons.facebook,
      const Color(0xFF1877F2),
    ));
  }

  if (skype?.isNotEmpty == true) {
    list.add(SocialLink(
      'Skype',
      skype!,
      FontAwesomeIcons.skype,
      const Color(0xFF00AFF0),
    ));
  }

  return list;
}
}

class SocialLink {
  final String name;
  final String url;
  final IconData icon;
  final Color color;

  SocialLink(this.name, this.url, this.icon, this.color);
}

class Product {
  final int id;
  final String image;
  final String title;
  final String description;

  Product({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      image: json['image'],
      title: json['title'],
      description: json['description'],
    );
  }
}

class Video {
  final int id;
  final String title;
  final String iframeUrl;
  final String thumbnail;

  Video({
    required this.id,
    required this.title,
    required this.iframeUrl,
    required this.thumbnail,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'],
      iframeUrl: json['iframeUrl'],
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}

class Catalogue {
  final int id;
  final String title;
  final String pdfUrl;
  final String thumbnail;

  Catalogue({
    required this.id,
    required this.title,
    required this.pdfUrl,
    required this.thumbnail,
  });

  factory Catalogue.fromJson(Map<String, dynamic> json) {
    return Catalogue(
      id: json['id'],
      title: json['title'],
      pdfUrl: json['pdfUrl'],
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}
