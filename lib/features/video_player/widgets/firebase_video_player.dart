import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FirebaseVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final double? width;
  final double? height;
  
  const FirebaseVideoPlayer({
    Key? key,
    required this.controller,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<FirebaseVideoPlayer> createState() => _FirebaseVideoPlayerState();
}

class _FirebaseVideoPlayerState extends State<FirebaseVideoPlayer> {
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
            GestureDetector(
              onTap: () {
                setState(() {
                  widget.controller.value.isPlaying
                      ? widget.controller.pause()
                      : widget.controller.play();
                });
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
          ],
        ),
      ),
    );
  }
}
