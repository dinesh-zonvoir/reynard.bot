import 'dart:convert';

import 'package:bot/providers/Api.dart';
import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
class LoginProvider extends ChangeNotifier{

  Future<String> loginUser(BuildContext buildContext,String userId,password) async {
    try{
      var loginData=FormData.fromMap({
        'email':userId,
        'password':password
      });
      var result=await Api().login(loginData);
      var res = jsonDecode(result.toString());
      print(res.toString());
        if(res['success']==200&&res['message']=="You have login successfully."){
          appStore.isLogins(value: true);
          appStore.fullName(value: res['results']['data']['name'].toString());
          appStore.authTokens(value:res['results']['token'].toString());
          return res['message'].toString();
        }else{
          return res['message'].toString();
        }

    }catch (e){
      return errorSomethingWentWrong;
    }

  }

}