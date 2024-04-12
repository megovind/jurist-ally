import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:juristally/pages/SharedWidgets/url-file.dart';

typedef _Fn = void Function();

const int tSampleRate = 44000;

class NewAudioPlayer extends StatefulWidget {
  final String? audioUrl, assetFile;
  final bool isControls, playOnLoad;
  NewAudioPlayer({Key? key, this.audioUrl, this.assetFile, this.isControls = false, this.playOnLoad = false})
      : super(key: key);

  @override
  _NewAudioPlayerState createState() => _NewAudioPlayerState();
}

class _NewAudioPlayerState extends State<NewAudioPlayer> {
  final FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;
  double _mSubscriptionDuration = 0;
  bool _isLoading = false;
  StreamSubscription? _mPlayerSubscription;
  int pos = 0;
  File? _file;

  @override
  void initState() {
    super.initState();
    init().then((value) {
      setState(() {
        _mPlayerIsInited = true;
        if (widget.audioUrl != null && widget.playOnLoad) {
          print("PLAYEDING");
          getPlaybackFn(_mPlayer)!.call();
        }
      });
    });
  }

  @override
  void dispose() {
    cancelPlayerSubscriptions();
    // // Be careful : you must `close` the audio session when you have finished with it.
    _mPlayer.closeAudioSession();
    stopPlayer(_mPlayer);
    super.dispose();
  }

  void cancelPlayerSubscriptions() {
    if (_mPlayerSubscription != null) {
      _mPlayerSubscription!.cancel();
      _mPlayerSubscription = null;
    }
  }

  @override
  setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> init() async {
    await _mPlayer.openAudioSession();
    setState(() => _isLoading = true);
    _file = await urlToFile(widget.audioUrl ?? "");
    setState(() => _isLoading = false);
    _mPlayerSubscription = _mPlayer.onProgress?.listen((e) {
      setState(() {
        pos = e.position.inMilliseconds;
      });
    });
    _mPlayerSubscription?.onDone(() {
      if (widget.audioUrl != null && widget.playOnLoad) {
        print("DONE PLAYING paying");
        getPlaybackFn(_mPlayer);
      }
    });
  }

  Future<void> stopPlayer(FlutterSoundPlayer player) async {
    await player.stopPlayer();
  }

  Future<void> setSubscriptionDuration(double d) async {
    // v is between 0.0 and 2000 (milliseconds)
    _mSubscriptionDuration = d;
    setState(() {});
    await _mPlayer.setSubscriptionDuration(
      Duration(milliseconds: d.floor()),
    );
  }

  void play(FlutterSoundPlayer? player) async {
    print("PLAYEDING strted");
    await player!.startPlayer(
        fromURI: _file?.path,
        // fromDataBuffer: _buffer,
        codec: Codec.pcm16,
        sampleRate: tSampleRate,
        numChannels: 1,
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  // --------------------- UI -------------------

  _Fn? getPlaybackFn(FlutterSoundPlayer? player) {
    if (!_mPlayerIsInited) {
      return null;
    }
    // print("FiNISHED ${player?.isPaused}");
    // if (player!.isPlaying) {
    //   return () => _mPlayer.pausePlayer();
    // } else if (player.isPaused) {
    //   return () => _mPlayer.resumePlayer();
    // } else if (player.isStopped) {
    //   return () => play(player);
    // } else {
    //   print("FiNISHED object");
    //   return () => stopPlayer(player);
    // }
    print("PLAYEDING auto");

    return player!.isStopped
        ? () {
            play(player);
          }
        : () {
            stopPlayer(player).then((value) => setState(() {}));
          };
  }

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: _mSubscriptionDuration,
            min: 0.0,
            max: 2000.0,
            onChangeStart: (d) => setSubscriptionDuration.call(d),
            onChanged: (d) => setSubscriptionDuration.call(d),
          ),
          // PlaybarSlider(
          //   _mPlayer.dispositionStream() ?? Stream<PlaybackDisposition>.empty(),
          //   (duration) {
          //     print("FINISHED FLUTTER $duration");
          //     _mPlayer.seekToPlayer(duration);
          //     // setSubscriptionDuration(duration.inMicroseconds);
          //   },
          //   SliderThemeData(trackHeight: 3),
          // ),
          widget.isControls
              ? IconButton(
                  onPressed: getPlaybackFn(_mPlayer),
                  icon: _isLoading
                      ? Container(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(_mPlayer.isPlaying
                          ? _mPlayer.isPaused
                              ? Icons.pause
                              : Icons.stop
                          : Icons.play_arrow_outlined),
                )
              : Container(),
        ],
      );
    }

    return makeBody();
  }
//   _progressBar(){
//  StreamBuilder<PlaybarSlider>(
//   stream: Stream<PlayerState>(),
//   builder: (context, snapshot) {
//     final durationState = snapshot.data;
//     final progress = durationState?.playing  ?? Duration.zero;
//     final buffered = durationState?.buffered ?? Duration.zero;
//     final total = durationState?.total ?? Duration.zero;
//     return ProgressBar(
//       progress: progress,
//       buffered: buffered,
//       total: total,
//       onSeek: (duration) {
//         _player.seek(duration);
//       },
//     );
//   },
// ),
//   }

}

class DurationState {
  const DurationState({this.progress, this.buffered, this.total});
  final Duration? progress;
  final Duration? buffered;
  final Duration? total;
}
