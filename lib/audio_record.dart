// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({super.key});

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  FlutterSoundRecorder? _recordingSession;
  String? pathToAudio;
  File? audioFile;
  bool isRecording = false;
  // int timeLimit = 300;
  // int maxTime = 300;
  int elapsedTime = 0;
  bool isPlaying = false;
  int audioDuration = 0;
  int audioPosition = 0;
  Timer? timer;
  AudioPlayer? audioPlayer;

  void initializer() async {
    pathToAudio = await getTemporaryDirectory().then((value) {
      return '${value.path}/audio.mp4';
    });
    _recordingSession = FlutterSoundRecorder();
    PermissionStatus value = await Permission.microphone.request();
    // await Permission.storage.request();
    if (value.isGranted) {
      debugPrint("permission granted");
    } else {
      debugPrint("permission denied");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Permissions Required"),
            content: const Text(
              "Please allow microphone permission to use this feature",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Open Settings"),
              ),
            ],
          );
        },
      );
      // openAppSettings();
      // context.pop();
    }
  }

  @override
  void initState() {
    initializer();
    super.initState();
  }

  @override
  void dispose() {
    _recordingSession!.closeRecorder();
    if (audioPlayer != null) {
      audioPlayer!.dispose();
    }
    super.dispose();
  }

  void _startRecording() async {
    setState(() {
      isRecording = true;
    });
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          elapsedTime++;
        });
      },
    );
    await _recordingSession!.openRecorder();
    await _recordingSession!.startRecorder(
      toFile: pathToAudio,
      // codec: Codec.aacMP4,
    );
  }

  void _stopRecording() async {
    await _recordingSession!.stopRecorder().then((value) {
      setState(() {
        audioFile = File(value!);
        timer!.cancel();
        elapsedTime = 0;
      });
    });
    await _recordingSession!.closeRecorder();
    setState(() {
      isRecording = false;
    });
    audioPlayer = AudioPlayer();
    await audioPlayer!.setFilePath(audioFile!.path);
    audioPlayer!.playerStateStream.listen(
      (playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          setState(() {
            isPlaying = false;
            // audioPosition = 0;
            // audioPlayer!.seek(Duration.zero);
          });
        }
      },
    );

    audioPlayer!.positionStream.listen((position) {
      if (!mounted) return;
      setState(() {
        audioPosition = position.inSeconds;
      });
    });

    audioPlayer!.durationStream.listen((totalDuration) {
      setState(() {
        audioDuration = totalDuration!.inSeconds;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: audioFile != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Icon(Icons.arrow_back),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Voice Recorder",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1e1e1e),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    // height: 390,
                    // width: 390,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xffC4DDDD),
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Lottie.asset(
                      'assets/audio_preview.json',
                      height: 390,
                      width: 390,
                      repeat: isPlaying,
                      animate: isPlaying,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ProgressBar(
                      progress: Duration(seconds: audioPosition),
                      // buffered: Duration(seconds: audioPosition),
                      total: Duration(seconds: audioDuration),
                      onSeek: (value) {
                        audioPlayer!.seek(value);
                      },
                      progressBarColor: Theme.of(context).colorScheme.primary,
                      baseBarColor: const Color(0xffC4DDDD),
                      thumbColor: Colors.grey,
                      thumbGlowColor: Theme.of(context).colorScheme.primary,
                      timeLabelTextStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff5c5c5c),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            audioFile = null;
                            elapsedTime = 0;
                          });
                        },
                        child: const Icon(
                          Icons.close,
                          size: 40,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          isPlaying
                              ? audioPlayer!.pause()
                              : audioPlayer!.play();
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                          if (audioPosition == audioDuration) {
                            setState(() {
                              audioPosition = 0;
                              audioPlayer!.seek(Duration.zero);
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 37,
                          backgroundColor: const Color(0xffF73B26),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop(audioFile!);
                        },
                        child: const Icon(
                          Icons.done,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                ],
              )
            : Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Icon(Icons.arrow_back),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Voice Recorder",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1e1e1e)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Text(
                  //   "${(timeLimit ~/ 60).toString().padLeft(2, "0")}:${(timeLimit % 60).toString().padLeft(2, '0')}",
                  //   style: const TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //     color: Color(0xff5c5c5c),
                  //   ),
                  // ),
                  const SizedBox(
                    height: 50,
                  ),
                  Lottie.asset(
                    "assets/audio_record.json",
                    // height: 500,
                    // width: 500,
                    repeat: isRecording,
                    animate: isRecording,
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        "${(elapsedTime ~/ 60).toString().padLeft(2, "0")}:${(elapsedTime % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff5c5c5c),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          if (isRecording) {
                            _stopRecording();
                            return;
                          } else {
                            _startRecording();
                          }
                        },
                        child: Container(
                          height: 73,
                          width: 73,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: const Color(0xffF73B26),
                              width: 5,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              height: isRecording ? 35 : 57,
                              width: isRecording ? 35 : 57,
                              decoration: BoxDecoration(
                                color: const Color(0xffF73B26),
                                borderRadius: BorderRadius.circular(
                                  isRecording ? 0 : 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
