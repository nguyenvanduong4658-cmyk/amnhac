import 'package:flutter/material.dart';

class Song {
  final String title;
  final String artist;
  final String albumArt;
  final String bannerText;
  final String subtitle;
  final Color themeColor;
  final List<String> lyrics;
  final String audioUrl;

  const Song({
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.bannerText,
    required this.subtitle,
    required this.themeColor,
    required this.lyrics,
    required this.audioUrl,
  });
}
