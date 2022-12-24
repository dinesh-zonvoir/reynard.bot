import 'package:bot/utils/ProgressHUD.dart';
import 'package:bot/utils/WAConstants.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:bot/screen/DashboardScreen.dart';
import 'package:bot/utils/WAColors.dart';
import 'package:bot/utils/WAWidgets.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/LoginProvider.dart';

class LoginScreen extends StatefulWidget {
  static String tag = '/LoginScreen';

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passWordFocusNode = FocusNode();
  bool visible = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
        inAsyncCall: visible,
        opacity: 0.3,
        child: Scaffold(
          key: _scaffoldKey,
          body: Center(
              child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  50.height,
                  Text("Log In", style: boldTextStyle(size: 24, color: black)),
                  Container(
                    margin: EdgeInsets.all(16),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Container(
                          width: context.width(),
                          padding:
                              EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          margin: EdgeInsets.only(top: 55.0),
                          decoration: boxDecorationWithShadow(
                              borderRadius: BorderRadius.circular(30),
                              backgroundColor: context.cardColor),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Text("Email",
                                        style: boldTextStyle(size: 14)),
                                    8.height,
                                    AppTextField(
                                      decoration: waInputDecoration(
                                          hint: 'Enter your email here',
                                          prefixIcon: Icons.email_outlined),
                                      textFieldType: TextFieldType.EMAIL,
                                      keyboardType: TextInputType.emailAddress,
                                      controller: emailController,
                                      focus: emailFocusNode,
                                      nextFocus: passWordFocusNode,
                                    ),
                                    16.height,
                                    Text("Password",
                                        style: boldTextStyle(size: 14)),
                                    8.height,
                                    AppTextField(
                                      decoration: waInputDecoration(
                                          hint: 'Enter your password here',
                                          prefixIcon: Icons.lock_outline),
                                      suffixIconColor: WAPrimaryColor,
                                      textFieldType: TextFieldType.PASSWORD,
                                      isPassword: true,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      controller: passwordController,
                                      focus: passWordFocusNode,
                                    ),
                                    16.height,
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text("Forgot password?",
                                          style: primaryTextStyle()),
                                    ),
                                    30.height,
                                    AppButton(
                                            text: "Log In",
                                            color: WAPrimaryColor,
                                            textColor: Colors.white,
                                            shapeBorder: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            width: context.width(),
                                            onTap: () {
                                              login(context);
                                            })
                                        .paddingOnly(
                                            left: context.width() * 0.1,
                                            right: context.width() * 0.1),
                                    30.height,
                                    // Container(
                                    //   width: 200,
                                    //   child: Row(
                                    //     children: [
                                    //       Divider(thickness: 2).expand(),
                                    //       8.width,
                                    //       Text('or', style: boldTextStyle(size: 16, color: Colors.grey)),
                                    //       8.width,
                                    //       Divider(thickness: 2).expand(),
                                    //     ],
                                    //   ),
                                    // ).center(),
                                    // 30.height,
                                    // Row(
                                    //   mainAxisSize: MainAxisSize.min,
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   children: [
                                    //     Container(
                                    //       decoration: boxDecorationRoundedWithShadow(16, backgroundColor: context.cardColor),
                                    //       padding: EdgeInsets.all(16),
                                    //       child: Image.asset('images/walletApp/wa_facebook.png', width: 40, height: 40),
                                    //     ),
                                    //     30.width,
                                    //     Container(
                                    //       decoration: boxDecorationRoundedWithShadow(16, backgroundColor: context.cardColor),
                                    //       padding: EdgeInsets.all(16),
                                    //       child: Image.asset('images/walletApp/wa_google_logo.png', width: 40, height: 40),
                                    //     ),
                                    //   ],
                                    // ).center(),
                                    // 30.height,
                                    // Row(
                                    //   mainAxisSize: MainAxisSize.min,
                                    //   crossAxisAlignment: CrossAxisAlignment.center,
                                    //   mainAxisAlignment: MainAxisAlignment.center,
                                    //   children: [
                                    //     Text('Don\'t have an account?', style: primaryTextStyle(color: Colors.grey)),
                                    //     4.width,
                                    //     Text('Register here', style: boldTextStyle(color: appStore.isDarkModeOn ? white : black)),
                                    //   ],
                                    // ).onTap(() {
                                    //   WARegisterScreen().launch(context);
                                    // }).center(),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 100,
                          width: 100,
                          decoration: boxDecorationRoundedWithShadow(30,
                              backgroundColor: context.cardColor),
                          child: Image.asset(
                            'images/walletApp/wa_app_logo.png',
                            height: 60,
                            width: 60,
                            color: appStore.isDarkModeOn ? white : black,
                            fit: BoxFit.cover,
                          ),
                        )
                      ],
                    ),
                  ),
                  16.height,
                ],
              ),
            ),
          )),
        ));
  }

  Future<void> login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      //invalid
      return;
    }
    setState(() {
      visible = true;
    });
    var ss = await Provider.of<LoginProvider>(context, listen: false).loginUser(
        context,
        emailController.text.toString(),
        passwordController.text.toString());
    if (ss=='You have login successfully.') {
      setState(() {
        visible = false;
      });
      WADashboardScreen().launch(context);
    } else {
      setState(() {
        visible = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          '$ss',
          textAlign: TextAlign.center,
          style:
              boldTextStyle(color: white, fontFamily: appFontFamily, size: 16),
        ),
        backgroundColor: errorColor,
      ));
    }
  }
}
