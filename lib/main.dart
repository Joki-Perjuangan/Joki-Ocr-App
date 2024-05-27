import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FlutterTts flutterTts;
  String text = "";
  bool letsSpeak = false;
  final StreamController<String> controller = StreamController<String>();

  void setText(value) {
    setState(() {
      text = value;
    });
    controller.add(value);
  }

  @override
  initState() {
    super.initState();
    initTts();
  }

  void initTts() {
    flutterTts = FlutterTts();
  }

  Future<void> _speak(String scannedText) async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);

    if (scannedText.isNotEmpty) {
      var result = await flutterTts.speak(scannedText);
      if (result == 1) {
        log('Success');
      } else {
        log('Failed to speak');
      }
    } else {
      log('Text is empty');
    }
  }

  @override
  void dispose() {
    controller.close();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color:const Color.fromARGB(255, 190, 190, 190),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ScalableOCR(
                paintboxCustom: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 4.0
                  ..color = const Color.fromARGB(153, 102, 160, 241),
                boxLeftOff: 5,
                boxBottomOff: 5,
                boxRightOff: 5,
                boxTopOff: 5,
                boxHeight: MediaQuery.of(context).size.height / 3,
                getRawData: (value) {
                  inspect(value);
                },
                getScannedText: (value) {
                  setText(value);
                  if(letsSpeak){
                    _speak(value);
                  }
                },
              ),
              Expanded(
                child: StreamBuilder<String>(
                  stream: controller.stream,
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return Result(
                      text: snapshot.data != null ? snapshot.data! : "",
                    );  
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                letsSpeak ? "speaking" : "not speaking",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  setState(() {
                    letsSpeak = !letsSpeak;
                  });
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 66, 148, 216),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  height: 80,
                  width: 80,
                  child: const Icon(Icons.play_arrow),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class Result extends StatelessWidget {
  const Result({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Readed text:",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
