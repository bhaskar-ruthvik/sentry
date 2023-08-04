import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentry/screens/add_image_screen.dart';
import 'package:sentry/screens/streamscreen.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry/constants.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
const uuid = Uuid();
class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var stream = false;
   late RtcEngine agoraEngine; 
   String channelName = "test";
    String token = temp_token;
    int? _remoteUid;
    bool _isJoined = true; // Indicates if the local user has joined the channel
    bool _isHost = true; // Indicates whether the user has joined as a host or audience
String imageUrl = 'https://w7.pngwing.com/pngs/178/595/png-transparent-user-profile-computer-icons-login-user-avatars-thumbnail.png';
void getAvatar() async {

  final user = FirebaseAuth.instance.currentUser!;
  final data = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if(data.data()!=null && mounted){
    setState(() {
      imageUrl = data.data()!['image_url'];
    });
 
  }
  }
   void showMessage(String message) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        ));
    } 
Future<void> setupVideoSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone, Permission.camera].request();

    //create an instance of the Agora engine
    agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
    appId: appId
    ));

    await agoraEngine.enableVideo();
    



   // Register the event handler
    agoraEngine.registerEventHandler(
    RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
       showMessage("Local uid:${connection.localUid} started streaming footage");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        showMessage("Remote user uid:$remoteUid joined the channel");
        setState(() {
            _remoteUid = remoteUid;
        });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
        showMessage("Remote user uid:$remoteUid left the channel");
        setState(() {
            _remoteUid = null;
        });
        },
    ),
    );

   
}
void join(bool isHost,int? remoteUid) async {

    // Set channel options
    ChannelMediaOptions options;

    // Set channel profile and client role
    if (isHost) {
        options = const ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
            channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        );
        await agoraEngine.startPreview();
    } else {
        options = const ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleAudience,
            channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
            // Set the latency level
        audienceLatencyLevel: AudienceLatencyLevelType.audienceLatencyLevelLowLatency,
        );
        

    }

    await agoraEngine.joinChannel(
        token: token,
        channelId: channelName,
        options: options,
        uid: 0,
    );
    
    setState(() {
      print(_remoteUid);
      remoteUid = _remoteUid;
    });
}
 
 @override
  void initState() {
    getAvatar();
    super.initState();
    setupVideoSDKEngine();
  }
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
            child: Row(
              children: [
                Text(
                  'Your Home',
                  style: GoogleFonts.montserrat(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 32),
                ),
                const Spacer(),
                IconButton(onPressed: (){
                  FirebaseAuth.instance.signOut();
                  // Navigator.of(context).pop();
                }, icon: const Icon(
                  Icons.logout,
                  size: 32.0,
                ),),
                
                const SizedBox(
                  width: 24.0,
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      imageUrl,
                      ),
                 
                )
              ],
            ),
          ),
         Expanded(
          child:  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 170,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColorDark),
                      foregroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor)
                    ),
                   onPressed: () async {
                        join(false,_remoteUid);
                     final res = await  Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                        return StreamScreen(isJoined: true,isHost: false,remoteUid: _remoteUid,agoraEngine: agoraEngine,);
                      }));
                      setState(() {
                        _isJoined = res['isJoined'];
                       _remoteUid = res['remoteUid'];
                      });
                    },
                    child: Text('View Stream',
                    style: GoogleFonts.montserrat(fontSize: 15,fontWeight: FontWeight.bold),),
                  
                  ),
                ),
                SizedBox(height: 20,),
                SizedBox(
                  height: 50,
                  width: 170,
                  child: ElevatedButton(
                    onPressed: () async {
                        join(true,_remoteUid);
                     final res = await  Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                    
                        return StreamScreen(isJoined: true,isHost: true,remoteUid: _remoteUid, agoraEngine: agoraEngine,);
                      }));
                      setState(() {
                        _isJoined = res['isJoined'];
                        _remoteUid = res['remoteUid'];
                      });
                    },
                   
                    child: Text('Create Stream', 
                    style: GoogleFonts.montserrat(fontSize: 15,fontWeight: FontWeight.bold),),
                  
                  ),
                ),
              ],
            )
            ,
          )
         ,
         )
        
        ],
      ),
    ));
  }
}