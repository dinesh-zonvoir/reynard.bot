import 'dart:io';
import 'package:carevicinity/utils/WAColors.dart';
import 'package:carevicinity/utils/widgets/success_popup.dart';
import 'package:carevicinity/utils/widgets/warning_popup.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class DialogUtils {
  static DialogUtils _instance = new DialogUtils.internal();

  DialogUtils.internal();

  factory DialogUtils() => _instance;

  static void showOkDialog(BuildContext context, {required String title}) {
    showDialog(
        context: context,
        builder: (_) {
          return ErrorPopup(title);
        });
  }

  static void showOkSuccessDialog(BuildContext context,
      {required String title}) {
    showDialog(
        context: context,
        builder: (_) {
          return
            SuccessPopup(title);
        });
  }

  static void showLogoutDialog(BuildContext context) async{
      return await  showDialog(
          context: context,
          builder: (BuildContext context) {
            return
              AlertDialog(
              content: Container(
                height: 96,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Do you want to exit?",style: TextStyle(fontFamily: 'Poppins'),),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              exit(0);
                            },
                            child: Text("Yes",style: boldTextStyle(color: white,fontFamily: 'Poppins'),),
                            style: ElevatedButton.styleFrom(
                                backgroundColor:WAPrimaryColor),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("No", style: boldTextStyle(color: white,fontFamily: 'Poppins')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: errorColor,
                              ),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            );
          });
  }
}
