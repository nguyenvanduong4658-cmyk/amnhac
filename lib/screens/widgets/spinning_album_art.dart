import 'dart:io';
import 'package:flutter/material.dart';

class SpinningAlbumArt extends StatefulWidget {
  final String imageUrl;
  final bool isPlaying;
  final double size;
  final double borderRadius;
  final bool isCircle;

  const SpinningAlbumArt({
    super.key,
    required this.imageUrl,
    required this.isPlaying,
    required this.size,
    this.borderRadius = 4,
    this.isCircle = true,
  });

  @override
  State<SpinningAlbumArt> createState() => _SpinningAlbumArtState();
}

class _SpinningAlbumArtState extends State<SpinningAlbumArt> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SpinningAlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop(canceled: false);
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (widget.imageUrl.startsWith('http://') || widget.imageUrl.startsWith('https://')) {
      imageWidget = Image.network(
        widget.imageUrl,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF282828),
          width: widget.size,
          height: widget.size,
          child: const Icon(Icons.music_note, color: Colors.white24),
        ),
      );
    } else {
      final file = File(widget.imageUrl);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF282828),
            width: widget.size,
            height: widget.size,
            child: const Icon(Icons.music_note, color: Colors.white24),
          ),
        );
      } else {
        imageWidget = Container(
          color: const Color(0xFF282828),
          width: widget.size,
          height: widget.size,
          child: const Icon(Icons.music_note, color: Colors.white24),
        );
      }
    }

    return RotationTransition(
      turns: _rotationController,
      child: widget.isCircle
          ? ClipOval(child: imageWidget)
          : ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: imageWidget,
            ),
    );
  }
}
