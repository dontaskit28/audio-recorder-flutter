import 'dart:io';

import 'package:flutter/material.dart';
import 'package:document_file_save_plus/document_file_save_plus.dart';

import 'audio_record.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? file;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Audio Recorder"),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          file != null
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  // height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                file = null;
                              });
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const Icon(Icons.audiotrack, size: 100),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // const Icon(Icons.audiotrack),
                            const SizedBox(width: 10),
                            Text(file!.path.split("/").last),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                DocumentFileSavePlus()
                                    .saveFile(
                                  file!.readAsBytesSync(),
                                  "audio_${DateTime.now().millisecondsSinceEpoch}.mp4",
                                  "audio/mp4",
                                )
                                    .then((value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text("File Saved to Downloads"),
                                    ),
                                  );
                                });
                              },
                              icon: const Icon(Icons.download),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const Text(
                  "Record Audio to save",
                  style: TextStyle(fontSize: 20),
                ),
          const Spacer(),
          InkWell(
            onTap: () async {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => const AudioRecorder(),
                ),
              )
                  .then((value) {
                if (value != null) {
                  setState(() {
                    file = value as File;
                  });
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    spreadRadius: 2,
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic),
                  SizedBox(width: 10),
                  Text("Record"),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 100,
          ),
        ],
      )),
    );
  }
}
