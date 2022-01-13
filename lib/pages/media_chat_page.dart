import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:passenger/constants/app_constants.dart';
import 'package:passenger/signaling.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaChatPage extends StatefulWidget {
  MediaChatPage({Key? key}) : super(key: key);

  @override
  _MediaChatPageState createState() => _MediaChatPageState();
}

class _MediaChatPageState extends State<MediaChatPage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  late bool _showRoomId = true;
  late bool _isMediaOpen = false;
  late bool _hasRoomOpen = false;
  late bool? _callOff = true;
  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    //     roomId = await signaling.createRoom(_remoteRenderer);
    //     textEditingController.text = roomId!;
    //     setState(() {});

    super.initState();
    // _initForRTC();
  }

  _initForRTC() async {
    await [Permission.microphone, Permission.camera].request();
    roomId = await signaling.createRoom(_remoteRenderer);
    textEditingController.text = roomId!;
    setState(() {});
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);

    if (_callOff != true) signaling.hangUp(_localRenderer);
    // dispose();
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => onBackPress(),
        ),
        title: const Text(AppConstants.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_front),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showRoomId = !_showRoomId;
              setState(() {});
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RTCVideoView(
            _remoteRenderer,
            mirror: false,
          ),
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
                width: 70,
                height: 120,
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                )),
          ),
          Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: "turn_on_media_btn",
                    onPressed: () async {
                      _callOff = false;
                      await signaling.openUserMedia(
                          _localRenderer, _remoteRenderer);
                      setState(() {});
                      _initForRTC();
                      setState(() {});
                      _isMediaOpen = !true;
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(Icons.video_call),
                          Icon(Icons.mic),
                        ]),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Add roomId
                      if (!_isMediaOpen) {
                        await signaling.openUserMedia(
                            _localRenderer, _remoteRenderer);
                        _isMediaOpen = true;
                      }
                      await signaling.joinRoom(
                        textEditingController.text,
                        _remoteRenderer,
                      );
                      _callOff = false;
                      setState(() {});
                    },
                    child: Text("Join"),
                  ),
                  FloatingActionButton(
                    heroTag: "end_call_btn",
                    backgroundColor: Colors.red,
                    onPressed: () {
                      signaling.hangUp(_localRenderer);
                      _callOff = true;
                      setState(() {});
                      onBackPress();
                    },
                    child: Icon(Icons.call_end),
                  ),
                ],
              )),
          /** */
          if (_showRoomId)
            Container(
              // alignment: Alignment.bottomCenter,
              // margin: EdgeInsets.only(bottom: 50),
              child: Visibility(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Room ID:"),
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Flexible(
                        child: TextFormField(
                          controller: textEditingController,
                        ),
                      )
                    ],
                  ),
                ),
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: _showRoomId,
              ),
            ),

          /** */
        ],
      ),
    );
  }
}
