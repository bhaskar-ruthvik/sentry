import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry/constants.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

const String appId = app_id;



class StreamScreen extends StatefulWidget {
StreamScreen({Key? key, required this.isJoined,required this.isHost,required this.remoteUid,required this.agoraEngine}) : super(key: key);
final bool isJoined;
final bool isHost;
int? remoteUid;

    final RtcEngine agoraEngine; // Agora engine instance
@override
_StreamScreenState createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> {
    String channelName = "test";
    String token = temp_token;
    int? _remoteUid;
    int uid = 0; // uid of the local user

void updateState(){
    widget.agoraEngine.registerEventHandler(
    RtcEngineEventHandler(
      
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
            widget.remoteUid = remoteUid;
        });
        }
        
    ),
    );
}

@override
  void initState() {
    // TODO: implement initState
      updateState();
    super.initState();

  }
void leave() {
    widget.agoraEngine.leaveChannel();
    Navigator.of(context).pop(
      {
        "isJoined": false,
        "remoteUid": null
      }
    );
}
    @override
  Widget build(BuildContext context) {
   return Scaffold(
        body: 
            // Container for the local video
            Column(
              children: [
                Expanded(
                  child:
                    Container(
                        height: 240,
                        decoration: BoxDecoration(border: Border.all()),
                        child: Center(child: _videoPanel()),
                    ),
                  
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(onPressed: (){
                      widget.agoraEngine.switchCamera();
                    }, icon: Icon(Icons.switch_camera)),
                    SizedBox(width: 20,),
                    IconButton(onPressed: leave, icon: const Icon(Icons.close)),
                  ],
                )
              ],
            ),
       
        );
  }
  Widget _videoPanel() {
    if (widget.isHost) {
        // Show local video preview
        return AgoraVideoView(
            controller: VideoViewController(
            rtcEngine: widget.agoraEngine,
            canvas: VideoCanvas(uid: 0),
            ),
        );
    }
        // Show remote video
        if (widget.remoteUid != null) {
            return AgoraVideoView(
            controller: VideoViewController.remote(
                rtcEngine: widget.agoraEngine,
                canvas: VideoCanvas(uid:widget.remoteUid),
                connection: RtcConnection(channelId: channelName),
            ),
            );
        } else {
            return const Text(
            'No Camera Setup',
            textAlign: TextAlign.center,
            );
        }
    
    
}


}
