import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FirebaseVideoPlayerScreen extends StatefulWidget {
  final String videoName; // The Firebase Storage URL or path to the video
  
  const FirebaseVideoPlayerScreen({
    Key? key,
    required this.videoName,
  }) : super(key: key);

  @override
  State<FirebaseVideoPlayerScreen> createState() => _FirebaseVideoPlayerScreenState();
}

class _FirebaseVideoPlayerScreenState extends State<FirebaseVideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Get the download URL from Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(widget.videoName);
      print('Attempting to load video from: ${ref.fullPath}');
      final downloadUrl = await ref.getDownloadURL();

      // Initialize the video player with the URL
      _controller = VideoPlayerController.networkUrl(Uri.parse(downloadUrl));
      
      await _controller.initialize();
      _controller.setLooping(true); // Optional: set video to loop
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading video: \${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_error != null) {
      return Text(
        _error!,
        style: const TextStyle(color: Colors.red),
      );
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
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
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
