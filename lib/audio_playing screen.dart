import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_app/audio_file.dart';
//import 'package:just_audio/just_audio.dart';

class AudioPlayingScreen extends StatefulWidget {

final audioData ;
final index;


  const AudioPlayingScreen({Key? key,required this.audioData, required this.index,}) : super(key: key);

  @override
  State<AudioPlayingScreen> createState() => _AudioPlayingScreenState();
}

class _AudioPlayingScreenState extends State<AudioPlayingScreen> {
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade200,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: height / 3,
            child: Container(
              color: Colors.blue,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AppBar(
              leading: IconButton(
                onPressed: () {
                  audioPlayer.stop();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search_outlined),
                ),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: height * 0.2,
            height: height * 0.36,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: height * 0.1,
                  ),
                  Text(
                    widget.audioData[widget.index]['title'],
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Avenir',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.audioData[widget.index]['artist'],
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Avenir',
                    ),
                  ),
                  AudioFile(
                    audioPlayer: audioPlayer,
                    audioPath : widget.audioData[widget.index]['audio_source'],

                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: (width - 150) / 2,
            right: (width - 150) / 2,
            top: height * 0.12,
            height: height * 0.16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 2,
                  color: Colors.white,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 5,
                    color: Colors.grey.shade100,
                  ),
                  shape: BoxShape.circle,
                  image:  DecorationImage(
                    image: NetworkImage(
                        widget.audioData[widget.index]['img']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
