import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class DialogHelper {
  //show error dialog
  // static void showErroDialog(
  //     {String title = 'Error', String description = 'Something went wrong'}) {
  //   Get.dialog(
  //     Dialog(
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               title,
  //               style: Get.textTheme.headline4,
  //             ),
  //             Text(
  //               description ?? '',
  //               style: Get.textTheme.headline6,
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 if (Get.isDialogOpen) Get.back();
  //               },
  //               child: Text('Okay'),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  //show toast
  //show snack bar
  //show loading
  static void showLoading({String? message}) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(message ?? 'Loading...', style: TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'Roboto')),
            ],
          ),
        ),
      ),
    );
  }

  //hide loading
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  static void validationErroDialog({String title = 'Error', String description = 'Something went wrong'}) {
    Get.dialog(
      Container(
        margin: EdgeInsets.only(left: 0.0, right: 0.0),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 5.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 0.0,
                        offset: Offset(0.0, 0.0),
                      ),
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
                      ),
                      child: Text(
                        "Validation Error",
                        style: TextStyle(color: Colors.white, fontSize: 25.0, fontFamily: 'Roboto'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: new Text(description, style: TextStyle(fontSize: 20.0, color: Colors.black)),
                      ) //
                          ),
                    ),
                    SizedBox(height: 24.0),
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(left: 10.0, right: 10.0),
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0, right: 15.0, left: 15.0),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0))),
                        child: Text(
                          "OK",
                          style: TextStyle(color: Colors.white, fontSize: 25.0, fontFamily: 'Roboto'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      onTap: () {
                        if (Get.isDialogOpen ?? false) Get.back();
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
