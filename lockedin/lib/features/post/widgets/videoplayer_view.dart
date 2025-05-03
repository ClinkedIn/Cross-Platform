import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
// Import your responsive sizing package (looks like sizer or something similar)
import 'package:sizer/sizer.dart'; // Update this to match your actual package

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  
  const VideoPlayerWidget({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.network(widget.url);
      
      await _videoPlayerController.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: false,
        placeholder: Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error loading video: $errorMessage',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
      print('Error initializing video player: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }
    
    if (_isInitialized && _chewieController != null) {
      return AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    }
    
    return _buildLoadingThumbnail();
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 100.w,
      height: 25.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(1.h),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red, size: 4.h),
            SizedBox(height: 1.h),
            Text(
              'Failed to load video',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingThumbnail() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100.w,
          height: 25.h,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(1.h),
          ),
          child: Center(
            child: Icon(
              Icons.movie,
              size: 4.h,
              color: Colors.white70,
            ),
          ),
        ),
        CircularProgressIndicator(color: Colors.white),
        Positioned(
          bottom: 1.h,
          left: 1.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(0.5.h),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 1.5.h,
                ),
                SizedBox(width: 0.5.w),
                Text(
                  'Loading Video...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}