import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:record/record.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';
import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
import 'package:wallet_app_prokit/utils/WAColors.dart';
import 'package:wallet_app_prokit/utils/WAConstants.dart';

// TODO import Dialogflow
 DialogflowGrpcV2Beta1 ? dialogflow;
class Chat  extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}
class _ChatState extends State<Chat > {
  ScrollController _scrollController = new ScrollController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  final List<Suggestions> _suggestions = <Suggestions>[];
  final TextEditingController _textController = TextEditingController();

  bool _isRecording = false;
  // RecorderStream _recorder = RecorderStream();
  StreamSubscription ?_recorderStatus;
  StreamSubscription<List<int>> ?_audioStreamSubscription;
  BehaviorSubject<List<int>>? _audioStream;
  //start recording code
  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;
//end recording code
  @override
  void initState() {
    //record
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) => setState(() => _amplitude = amp));
    //record
    super.initState();
    initPlugin();
  }



  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // We don't do anything with this but printing
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );

        // final devs = await _audioRecorder.listInputDevices();
        // final isRecording = await _audioRecorder.isRecording();

        await _audioRecorder.start();
        _recordDuration = 0;
        _startTimer();
      }
    } catch (e) {
     print(e);
    }
  }
  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
  Future<void> _stop() async {
    _timer?.cancel();
    _recordDuration = 0;
    final path = await _audioRecorder.stop();
  }

  Future<void> _pause() async {
    _timer?.cancel();
    await _audioRecorder.pause();
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();
  }




  @override
  void dispose() {
    //new
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    //new
    _recorderStatus?.cancel();
    _audioStreamSubscription?.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlugin() async {
    // TODO Get a Service account
    // Get a Service account
    final serviceAccount = ServiceAccount.fromString(
        '${(await rootBundle.loadString('assets/carevicinity-371605-e79b5b2f6639.json'))}');
    // Create a DialogflowGrpc Instance
    dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);
    try{
      DetectIntentResponse data = await dialogflow!.detectIntent("Welcome", 'en-in');
      String fulfillmentText = data.queryResult.fulfillmentText;
      //test
      var  chips = data.queryResult.fulfillmentMessages[1].suggestions;
      chips.suggestions.forEach((element) {
        Suggestions sug=Suggestions(title:element.title.toString());
       setState(() {
         _suggestions.insert(0, sug);
       });
      });
      //test
      print("response text ::$fulfillmentText");
      if(fulfillmentText.isNotEmpty) {
        ChatMessage botMessage = ChatMessage(
          text: fulfillmentText,
          name: "Carebot",
          type: false,
        );
        print(botMessage);
        setState(() {
          _messages.insert(0, botMessage);
        });
      }
    }catch(e){
      print("Here is error :: $e");
    }


    // initialized aoudio striming
    // _recorderStatus = _recorder.status.listen((status) {
    //   if (mounted)
    //     setState(() {
    //       _isRecording = status == SoundStreamStatus.Playing;
    //     });
    // });

    // await Future.wait([
    //   _recorder.initialize()
    // ]);

  }


  void stopStream() async {
    // await _recorder.stop();
    await _audioStreamSubscription?.cancel();
    await _audioStream?.close();
  }


  void handleSubmitted(text)async{
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 1),
          curve: Curves.fastOutSlowIn);
    });
    print(text);
    _textController.clear();
    _suggestions.clear();
    //TODO Dialogflow Code
    ChatMessage message = ChatMessage(
      text: text,
      name: "You",
      type: true,
    );
    setState(() {
      _messages.insert(0, message);
    });
    try{
      DetectIntentResponse data = await dialogflow!.detectIntent(text, 'en-in');
      String fulfillmentText = data.queryResult.fulfillmentText;
      //test
      if(data.queryResult.fulfillmentMessages.length>1){
        var  chips = data.queryResult.fulfillmentMessages[1].suggestions;
        chips.suggestions.forEach((element) {
          Suggestions sug=Suggestions(title:element.title.toString());
          setState(() {
            _suggestions.insert(0, sug);
          });
        });
      }
      //test
      print("response text ::$fulfillmentText");
      if(fulfillmentText.isNotEmpty) {
        ChatMessage botMessage = ChatMessage(
          text: fulfillmentText,
          name: "Carebot",
          type: false,
        );
      print(botMessage);
        setState(() {
          _messages.insert(0, botMessage);
        });
      }
    }catch(e){
      print("Here is error :: $e");
    }

  }

  void handleStream() async {
    // _recorder.start();
    _audioStream = BehaviorSubject<List<int>>();
    // _audioStreamSubscription = _recorder.audioStream.listen((data) {
    //   print(data);
    //   _audioStream!.add(data);
    // });

    // TODO Create SpeechContexts
    // Create an audio InputConfig
    var biasList = SpeechContextV2Beta1(
        phrases: [
          'Dialogflow CX',
          'Dialogflow Essentials',
          'Action Builder',
          'HIPAA'
        ],
        boost: 20.0
    );

    // See: https://cloud.google.com/dialogflow/es/docs/reference/rpc/google.cloud.dialogflow.v2#google.cloud.dialogflow.v2.InputAudioConfig
    var config = InputConfigV2beta1(
        encoding: 'AUDIO_ENCODING_LINEAR_16',
        languageCode: 'en-US',
        sampleRateHertz: 16000,
        singleUtterance: false,
        speechContexts: [biasList]
    );

    // TODO Make the streamingDetectIntent call, with the InputConfig and the audioStream
    // TODO Get the transcript and detectedIntent and show on screen

    final responseStream = dialogflow!.streamingDetectIntent(config, _audioStream!);
    // Get the transcript and detectedIntent and show on screen
    responseStream.listen((data) {
      print('First :: ----');
      setState(() {
        print("print recorded data $data");
        String transcript = data.recognitionResult.transcript;
        String queryText = data.queryResult.queryText;
        String fulfillmentText = data.queryResult.fulfillmentText;
        if(fulfillmentText.isNotEmpty) {
          ChatMessage message = new ChatMessage(
            text: queryText,
            name: "You",
            type: true,
          );
          ChatMessage botMessage = new ChatMessage(
            text: fulfillmentText,
            name: "Carebot",
            type: false,
          );
          _messages.insert(0, message);
          _textController.clear();
          _messages.insert(0, botMessage);

        }
        if(transcript.isNotEmpty) {
          _textController.text = transcript;
        }
      });
    },onError: (e){
      print("Error on audio record :: $e");
    },onDone: () {
      print('done');

    });

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        leading:Container(child: CircleAvatar(child: Icon(Icons.person,color: white,),backgroundColor: WAPrimaryColor,),padding: EdgeInsets.all(8.0),),
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Carebot",
                  textAlign: TextAlign.left,
                  style: boldTextStyle(
                      color: WAPrimaryColor,
                      size: 13,
                      fontFamily: appFontFamily),
                )
              ],
            ),
            Row(
              children: [
                Text("Your personal carevicinity assistant",
                    textAlign: TextAlign.left,
                    style:
                    secondaryTextStyle(size: 12, fontFamily: appFontFamily))
              ],
            ),
          ],
        ),
      ),
      body: Container(
        height: context.height(),
        width: context.width(),
        child: Stack(
          children: [
            Expanded(child: ListView.builder(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(left: 8.0,right: 8.0,bottom: 130.0,top: 0.0),
              reverse: true,
              shrinkWrap: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ))
          ,

            Positioned(
              child: Column(
                children: [
                  Container(
                    height: 48,
                    padding: EdgeInsets.only(left: 16.0,right: 16.0),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor),
                    child:ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: AlwaysScrollableScrollPhysics(),
                      reverse: true,
                      itemBuilder: (_, int index){
                       var suggestion= _suggestions[index];
                        return Container(
                          decoration:
                          BoxDecoration(border: Border.all(color: WAPrimaryColor,width: 2),borderRadius: BorderRadius.all(Radius.circular(16.0))),
                          padding: EdgeInsets.only(top:8.0,bottom: 8.0,left: 16.0,right: 16.0),
                          margin: const EdgeInsets.all(5.0),
                          child: Text(suggestion.title!,textAlign: TextAlign.center,style: boldTextStyle(fontFamily: appFontFamily,size: 13,color: WAPrimaryColor),),
                        ).onTap((){
                          handleSubmitted(suggestion.title!);
                        });
                      },
                      itemCount: _suggestions.length,
                    ),),
                  Container(
                      decoration: BoxDecoration(color: Theme.of(context).cardColor),
                      child: IconTheme(
                        data: IconThemeData(color: Theme.of(context).accentColor),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: <Widget>[
                              Flexible(
                                child: TextField(
                                  controller: _textController,
                                  onSubmitted:handleSubmitted,
                                  decoration: InputDecoration.collapsed(
                                      hintText: "Send a message"),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 4.0),
                                child: IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: (){
                                    if(_textController.text.toString().isNotEmpty){
                                      handleSubmitted(_textController.text);
                                    }
                                  }

                                ),
                              ),
                              IconButton(
                                iconSize: 30.0,
                                icon:
                                    Icon(_isRecording ? Icons.mic_off : Icons.mic),
                                onPressed:(){
                                  (_recordState != RecordState.stop) ? _stop() : _start();
                                }
                                // _isRecording ? stopStream : handleStream,
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
            )
          ],
        ),
      ),
    ));
  }
}

//------------------------------------------------------------------------------------
// The chat message balloon
//
//------------------------------------------------------------------------------------
class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.name, this.type});

   String ?text;
   String? name;
   bool ?type;
  List<Widget> otherMessage(context) {
    return <Widget>[
      new Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(child:  Text('B',style: boldTextStyle(fontFamily: appFontFamily,color: white),),backgroundColor: WAPrimaryColor,),
      ),
      new Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(this.name!, style: boldTextStyle(color: WAPrimaryColor,size: 14)),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text!,style: secondaryTextStyle(fontFamily: appFontFamily,size: 13),),
            ),
          ],
        ),
      ),
    ];
  }
  List<Widget> myMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(this.name!, style:boldTextStyle(size: 14,color: blueColor,fontFamily: appFontFamily)),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text!,style: secondaryTextStyle(fontFamily: appFontFamily,size: 13),),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
            child: Text(
          this.name![0],
          style: boldTextStyle(color: white,fontFamily: appFontFamily),
        )),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.type! ? myMessage(context):otherMessage(context),
      ),
    );
  }
}


//suggetions

class Suggestions extends StatelessWidget {
  Suggestions({this.title});
  String ?title;

  Widget mySuggetions(context) {
    return Container(
      decoration:
      boxDecorationRoundedWithShadow(16,
        backgroundColor:white,
        shadowColor: Colors.grey
            .withOpacity(0.2),),
      padding: EdgeInsets.only(top:8.0,bottom: 8.0,left: 16.0,right: 16.0),
      margin: const EdgeInsets.all(5.0),
      child: Text(title!,textAlign: TextAlign.center,style: secondaryTextStyle(fontFamily: appFontFamily,size: 13,color: WAPrimaryColor),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return mySuggetions(context);
  }
}




