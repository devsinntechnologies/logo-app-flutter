// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';

// class VideoSplashScreen extends StatefulWidget {
//   const VideoSplashScreen({super.key});

//   @override
//   _VideoSplashScreenState createState() => _VideoSplashScreenState();
// }

// class _VideoSplashScreenState extends State<VideoSplashScreen> {
//   late VideoPlayerController _videoPlayerController;
//   ChewieController? _chewieController;

//   @override
//   void initState() {
//     super.initState();
//     _videoPlayerController =
//         VideoPlayerController.asset("assets/videos/splash.mp4");

//     _chewieController = ChewieController(
//       videoPlayerController: _videoPlayerController,
//       autoPlay: true,
//       looping: true,
//       aspectRatio: 16 / 9,
//       // showControls: true, // optional
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: _chewieController != null
//             ? Chewie(controller: _chewieController!)
//             : CircularProgressIndicator(),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _chewieController?.dispose();
//     _videoPlayerController.dispose();
//     super.dispose();
//   }
// }
