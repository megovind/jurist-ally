import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/pages/Auth/logo.dart';
import 'package:juristally/pages/Auth/update_signup_details.dart';
import 'package:juristally/pages/Landing/landing.dart';
import 'package:juristally/widget/Button/custom-elevated-button.dart';
import 'package:juristally/widget/Loader/progressbar_mk.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class SignUpInOTP extends StatefulWidget {
  SignUpInOTP({Key? key}) : super(key: key);

  @override
  _SignUpInOTPState createState() => _SignUpInOTPState();
}

class _SignUpInOTPState extends State<SignUpInOTP> {
  final _key = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  bool _isLoading = false;

  _showLoader(bool value) => setState(() => _isLoading = value);

  _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    _showLoader(true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).verifyOTP(data: _formData);
      final loggedInUser = Provider.of<AuthProvider>(context, listen: false).loggedInUser;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  loggedInUser != null && loggedInUser.type != null ? LandingPage() : SignUpUserUpdate()),
          (route) => false);
    } catch (e) {
      Get.snackbar("", 'Please Enter a valid OTP', snackPosition: SnackPosition.BOTTOM);
    }
    _showLoader(false);
  }

  @override
  Widget build(BuildContext context) {
    final emPh = Provider.of<AuthProvider>(context, listen: false).emailPhone;
    final emailPhone = emPh!.contains('@') ? "$emPh" : "+91 $emPh";
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      body: Progressbar(
        inAsyncCall: _isLoading,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                AppLogo(),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  child: Text('OTP Send to: $emailPhone'),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  child: PinCodeTextField(
                    appContext: context,
                    obscureText: true,
                    autoFocus: true,
                    length: 6,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() => _formData['code'] = int.parse(value)),
                    validator: (value) {
                      if (value!.isEmpty)
                        return 'Enter a valid OTP';
                      else
                        return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Did not get the OTP? '),
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            'RESEND',
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ))
                    ],
                  ),
                ),
                CustomElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    'Verify OTP',
                    style: TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
