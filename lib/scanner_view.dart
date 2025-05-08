import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:vibration/vibration.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  _ScannerViewState createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  String result = '';
  List<TextSpan> textSpans = <TextSpan>[];
  Uint8List? createdCodeBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "QUICK SCANNER",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  strutStyle: StrutStyle(leading: 1.7, height: 1.7),
                ),
                SizedBox(height: 48),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: ReaderWidget(
                    cropPercent: 1,
                    codeFormat: Format.any,
                    onScan: (result) async {
                      buildFormattedScannedOutput(result.text!);
                      playSound();
                      if (await Vibration.hasVibrator()) {
                        Vibration.vibrate();
                      }
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(height: 12),
                if (textSpans.isNotEmpty)
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: RichText(text: TextSpan(children: textSpans)),
                    ),
                  ),
                SizedBox(height: 48),
                WriterWidget(
                  text: "01000000000001241722050610139115923019333",
                  messages: const Messages(createButton: 'Create Code'),
                  format: Format.dataMatrix,
                  onSuccess: (result, bytes) {
                    setState(() {
                      createdCodeBytes = bytes as Uint8List?;
                    });
                  },
                  onError: (error) {
                    _showMessage(context, 'Error: $error');
                  },
                ),
                if (createdCodeBytes != null) Image.memory(createdCodeBytes!),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void buildFormattedScannedOutput(String data) {
    String symbolIdentifier = ']d2';
    data = '$symbolIdentifier$data';
    final parts = data.split('<GS>');
    List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      // Add the data part
      if (parts[i].isNotEmpty) {
        spans.add(
          TextSpan(
            text: parts[i],
            style:
                parts[i].compareTo(symbolIdentifier) == 0
                    ? TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                    : TextStyle(color: Colors.black),
          ),
        );
      }

      // Add the blue <GS> marker (except after last part)
      if (i < parts.length - 1) {
        spans.add(
          TextSpan(
            text: '<GS>',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    }
    textSpans = spans;
  }

  void playSound() {
    FlutterRingtonePlayer().play(fromAsset: "assets/sound/scanner-beep.mp3");
  }

  _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
