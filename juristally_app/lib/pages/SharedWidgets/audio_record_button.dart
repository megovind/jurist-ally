import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

typedef _Fn = void Function();

const int tSampleRate = 44000;

// const theSource = AudioSource.microphone;

class AudioRecordButton extends StatefulWidget {
  final Function saveRecoring;
  AudioRecordButton({Key? key, required this.saveRecoring}) : super(key: key);

  @override
  _AudioRecordButtonState createState() => _AudioRecordButtonState();
}

class _AudioRecordButtonState extends State<AudioRecordButton> {
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String? _mPath;
  StreamSubscription? _mRecordingDataSubscription;
  StreamController<Food>? _recordingDataController;
  SpeechToText _speechToText = SpeechToText();
  IOSink? _sink;
  bool _speechEnabled = false;
  String? _txtMsg;

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // throw RecordingPermissionException('Microphone permission not granted');
      print("Microphone Permissions not provided to record the audio");
    }
    _mRecorder!.openAudioSession().then((value) => setState(() {
          _mRecorderIsInited = true;
        }));
    ;
  }

  @override
  void initState() {
    super.initState();
    initSpeechState();
    _openRecorder();
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _mPlayer!.closeAudioSession();
    _mRecorder!.closeAudioSession();
    _recordingDataController?.close();
    _mRecordingDataSubscription?.cancel();
    if (_sink != null) _sink?.close();
    super.dispose();
  }

  /// This has to happen only once per app
  Future<void> initSpeechState() async {
    var hasSpeech = await _speechToText.initialize(debugLogging: false, finalTimeout: Duration(milliseconds: 0));
    print('RECORDINGNN $hasSpeech');

    if (!mounted) return;
    setState(() {
      _speechEnabled = hasSpeech;
    });
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    print("RECORDINGNN called listeneing, $_speechEnabled");

    if (_speechEnabled) await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    print("RECORDINGNN stopping now ${_speechToText.isListening} ");
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    print('RECORDINGNN recognised words ${result.recognizedWords}');
    setState(() {
      _txtMsg = result.recognizedWords;
    });
  }

  Future<IOSink> createFile() async {
    var tempDir = await getTemporaryDirectory();
    _mPath = '${tempDir.path}/flutter_sound_example.pcm';
    var outputFile = File(_mPath!);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    return outputFile.openWrite();
  }

  Future<void> record() async {
    if (_speechEnabled || _speechToText.isListening) _startListening();
    assert(_mRecorderIsInited && _mPlayer!.isStopped);
    _sink = await createFile();
    _recordingDataController = StreamController<Food>();
    _mRecordingDataSubscription = _recordingDataController?.stream.listen((buffer) {
      if (buffer is FoodData) {
        _sink?.add(buffer.data!);
      }
    });
    await _mRecorder!.startRecorder(
      toStream: _recordingDataController?.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: tSampleRate,
    );
    setState(() {});
  }
  // --------------------- (it was very simple, wasn't it ?) -------------------

  Future<void> stopRecorder() async {
    print('RECORDINGNN stopping... ');
    _stopListening();
    await _mRecorder!.stopRecorder();
    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription!.cancel();
      _mRecordingDataSubscription = null;
    }
    _mplaybackReady = true;

    if (_mRecorder!.isStopped) widget.saveRecoring(_mPath, _txtMsg);
    setState(() {});
  }

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped
        ? record
        : () {
            stopRecorder().then((value) => null);
          };
  }

  void play() async {
    assert(_mPlayerIsInited && _mplaybackReady && _mRecorder!.isStopped && _mPlayer!.isStopped);
    await _mPlayer!.startPlayer(
        fromURI: _mPath,
        sampleRate: tSampleRate,
        codec: Codec.pcm16,
        numChannels: 1,
        whenFinished: () {
          setState(() {});
        }); // The readability of Dart is very special :-(
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: Color(0xfff2f2f2)),
      onPressed: getRecorderFn(),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(5),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.red,
                child: Icon(Icons.mic_rounded, color: Colors.black, size: 30),
              ),
            ),
            _mRecorder!.isRecording
                ? Text(
                    "Recording...",
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
                  )
                : Container(height: 0)
          ],
        ),
      ),
    );
  }
}
