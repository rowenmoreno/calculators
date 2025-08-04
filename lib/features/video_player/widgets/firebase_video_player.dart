import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class FirebaseVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final double? width;
  final double? height;
  final bool showControls;
  
  const FirebaseVideoPlayer({
    Key? key,
    required this.controller,
    this.width,
    this.height,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<FirebaseVideoPlayer> createState() => _FirebaseVideoPlayerState();
}

class _FirebaseVideoPlayerState extends State<FirebaseVideoPlayer> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _onTap() {
    setState(() {
      _showControls = true;
    });
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
            if (widget.showControls) ...[
              GestureDetector(
                onTap: _onTap,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.controller.value.isPlaying
                          ? widget.controller.pause()
                          : widget.controller.play();
                    });
                    _startHideTimer();
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      widget.controller.value.isPlaying 
                          ? Icons.pause 
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
