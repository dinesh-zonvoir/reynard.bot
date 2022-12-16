import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:wallet_app_prokit/chatboat/Chat.dart';
import 'package:wallet_app_prokit/utils/WAColors.dart';

class WADashboardScreen extends StatefulWidget {
  static String tag = '/WADashboardScreen';

  @override
  WADashboardScreenState createState() => WADashboardScreenState();
}

class WADashboardScreenState extends State<WADashboardScreen> {

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {

    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(child: Chat(),),
    );
  }
}
