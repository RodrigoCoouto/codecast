import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeAudioPlayer extends StatefulWidget {
  const QRCodeAudioPlayer({super.key});

  @override
  _QRCodeAudioPlayerState createState() => _QRCodeAudioPlayerState();
}

class _QRCodeAudioPlayerState extends State<QRCodeAudioPlayer> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  late FlutterTts flutterTts;
  bool audioPlaying = false;
  String qrData = '';

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
  }

  @override
  void dispose() {
    controller.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Audio Player'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(borderColor: Colors.red, borderRadius: 10, borderLength: 30, borderWidth: 10, cutOutSize: scanArea),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (audioPlaying) {
                    flutterTts.stop();
                  } else {
                    _playAudio();
                  }
                  setState(() {
                    audioPlaying = !audioPlaying;
                  });
                },
                child: Text(audioPlaying ? 'Stop Audio' : 'Play Audio'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrData = scanData.code ?? '';
        _speakText(qrData);
      });
    });
  }

  Future<void> _speakText(String text) async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.speak(text);
  }

  void _playAudio() {
    _speakText(qrData);
  }
}
