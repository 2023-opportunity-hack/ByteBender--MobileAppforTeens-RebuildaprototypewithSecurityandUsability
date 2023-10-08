import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  // Replace these video URLs with your own YouTube video URLs.
  final List<String> videoUrls = [
    'https://www.youtube.com/watch?v=2o2dlueLmkM',
    'https://www.youtube.com/watch?v=2o2dlueLmkM',
    // Add more video URLs as needed.
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      backgroundColor: Color(4280758332), // Set your desired background color.
      body:Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.separated(
          separatorBuilder: (ctx,i)=>SizedBox(height:20),
          itemCount: videoUrls.length,
          itemBuilder: (context, index) {
            final videoId = YoutubePlayer.convertUrlToId(videoUrls[index]);
            if (videoId != null) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: videoId,
                    flags: YoutubePlayerFlags(
                      autoPlay: false,
                    ),
                  ),
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.blue,
                ),
              );
            } else {
              // Handle the case where a valid video ID cannot be extracted from the URL.
              // You can display an error message or take other actions as needed.
              return Container(
                alignment: Alignment.center,
                child: Text(
                  'Invalid Video URL',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              );
            }
          },
        ),
      ));
  }
}