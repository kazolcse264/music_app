import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:just_audio/just_audio.dart';


class AudioFile extends StatefulWidget {
  AudioPlayer audioPlayer;
  final String audioPath;


  AudioFile({
    Key? key,
    required this.audioPlayer,
    required this.audioPath,
   
  }) : super(key: key);

  @override
  State<AudioFile> createState() => _AudioFileState();
}

class _AudioFileState extends State<AudioFile> {
  Duration _duration = Duration();
  Duration _position = Duration();
  bool isPlaying = false;
  bool isPaused = false;
  bool isRepeat = false;
  Color color = Colors.black;

  // String path = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3';
  final List<IconData> _icons = [
    Icons.play_circle_fill,
    Icons.pause_circle_filled,
  ];

  @override
  void initState() {
    super.initState();
    widget.audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    widget.audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });
    widget.audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _position = Duration(seconds: 0);
        if (isRepeat == true) {
          isPlaying = true;
        } else {
          isRepeat = false;
          isPlaying = false;
        }
      });
    });
    widget.audioPlayer.setSourceUrl(widget.audioPath);


  }

  Widget btnStart() {
    return IconButton(
      padding: EdgeInsets.only(
        bottom: 10,
      ),
      onPressed: () {
        if (isPlaying == false) {
          widget.audioPlayer.play(UrlSource(widget.audioPath));
          setState(() {
            isPlaying = true;
          });
        } else if (isPlaying == true) {
          widget.audioPlayer.pause();
          setState(() {
            isPlaying = false;
          });
        }
      },
      icon: isPlaying == false
          ? Icon(
              _icons[0],
              size: 50,
              color: Colors.blue,
            )
          : Icon(
              _icons[1],
              size: 50,
              color: Colors.blue,
            ),
    );
  }

  Widget loadAsset() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          btnRepeat(),
          btnSlow(),
          btnStart(),
          btnFast(),
          btnLoop(),
        ],
      ),
    );
  }

  Widget slider() {
    return Slider(
      value: _position.inSeconds.toDouble(),
      activeColor: Colors.red,
      inactiveColor: Colors.grey,
      min: 0.0,
      max: _duration.inSeconds.toDouble(),
      onChanged: (value) {
        setState(() {
          changeToSecond(value.toInt());
          value = value;
        });
      },
    );
  }

  Widget btnLoop() {
    return IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.loop,
          size: 25,
          color: Colors.black,
        ));
  }

  Widget btnRepeat() {
    return IconButton(
        onPressed: () {
          if (isRepeat == false) {
            widget.audioPlayer.setReleaseMode(ReleaseMode.loop);
            setState(() {
              isRepeat = true;
              color = Colors.blue;
            });
          } else if (isRepeat == true) {
            widget.audioPlayer.setReleaseMode(ReleaseMode.release);
            color = Colors.black;
            isRepeat = false;
          }
        },
        icon: Icon(
          Icons.repeat,
          size: 25,
          color: color,
        ));
  }

  Widget btnFast() {
    return IconButton(
        onPressed: () {
          widget.audioPlayer.setPlaybackRate(1.5);
        },
        icon: Icon(
          Icons.skip_next,
          size: 30,
          color: Colors.black,
        ));
  }

  Widget btnSlow() {
    return IconButton(
        onPressed: () {
          widget.audioPlayer.setPlaybackRate(0.5);
        },
        icon: Icon(
          Icons.skip_previous,
          size: 30,
          color: Colors.black,
        ));
  }

  void changeToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    widget.audioPlayer.seek(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _position.toString().split('.')[0],
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  _duration.toString().split('.')[0],
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          slider(),
          loadAsset(),
        ],
      ),
    );
  }
}
