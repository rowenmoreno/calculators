import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';
import 'widgets/firebase_video_player.dart';

class VideoCarouselScreen extends StatefulWidget {
  const VideoCarouselScreen({Key? key}) : super(key: key);

  @override
  State<VideoCarouselScreen> createState() => _VideoCarouselScreenState();
}

class _VideoCarouselScreenState extends State<VideoCarouselScreen> {
  final PageController _pageController = PageController();
  late List<String> _videoNames;
  late List<VideoPlayerController> _controllers;
  late List<bool> _isLoading;
  late List<String?> _errors;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideoList();
    _initializeVideos();
  }

  void _initializeVideoList() {
    // Fixed list of all videos from video_1 to video_10
    _videoNames = [
      'video_1.mp4',
      'video_2.mp4', 
      'video_3.mp4',
      'video_4.mp4',
      'video_5.mp4',
      'video_6.mp4',
      'video_7.mp4',
      'video_8.mp4',
      'video_9.mp4',
      'video_10.mp4',
    ];
    
    // Initialize controllers, loading states, and errors lists
    _controllers = [];
    _isLoading = List.generate(_videoNames.length, (index) => true);
    _errors = List.generate(_videoNames.length, (index) => null);
    
    // Set random starting index
    _currentIndex = Random().nextInt(_videoNames.length);
  }

  Future<void> _initializeVideos() async {
    for (int i = 0; i < _videoNames.length; i++) {
      await _initializeVideo(i);
    }
    // Ensure the randomly selected video plays after all are loaded
    if (_controllers.isNotEmpty && _currentIndex < _controllers.length && _controllers[_currentIndex].value.isInitialized) {
      _controllers[_currentIndex].play();
      // Jump to the random starting page
      _pageController.jumpToPage(_currentIndex);
    }
  }

  Future<void> _initializeVideo(int index) async {
    try {
      // Get the download URL from Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(_videoNames[index]);
      final downloadUrl = await ref.getDownloadURL();

      // Initialize the video player with the URL
      final controller = VideoPlayerController.networkUrl(Uri.parse(downloadUrl));
      await controller.initialize();
      controller.setLooping(true);

      setState(() {
        _controllers.add(controller);
        _isLoading[index] = false;
      });

      // Auto-play immediately when video is loaded
      if (index == _currentIndex) {
        controller.play();
      }

    } catch (e) {
      setState(() {
        _isLoading[index] = false;
        _errors[index] = 'Error loading video: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Play the current video when page changes
    if (index < _controllers.length && _controllers[index].value.isInitialized) {
      _controllers[index].play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Carousel'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _videoNames.length,
              itemBuilder: (context, index) {
                return _buildVideoPage(index);
              },
            ),
          ),
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildVideoPage(int index) {
    if (_isLoading[index]) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_errors[index] != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errors[index]!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (index < _controllers.length) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FirebaseVideoPlayer(
            controller: _controllers[index],
            width: double.infinity,
            height: double.infinity,
            showControls: false,
          ),
        ),
      );
    }

    return const Center(
      child: Text(
        'Video not available',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _videoNames.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
} 