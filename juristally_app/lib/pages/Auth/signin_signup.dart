import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/helper/validator.dart';
import 'package:juristally/pages/Auth/logo.dart';
import 'package:juristally/pages/Auth/signin_up_otp.dart';
import 'package:juristally/widget/Button/custom-elevated-button.dart';
import 'package:juristally/widget/InputField/custom-input.dart';
import 'package:juristally/widget/Loader/progressbar_mk.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpSignIn extends StatefulWidget {
  static const routeName = "/signin-signup";
  SignUpSignIn({Key? key}) : super(key: key);

  @override
  _SignUpSignInState createState() => _SignUpSignInState();
}

class _SignUpSignInState extends State<SignUpSignIn> {
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
      await Provider.of<AuthProvider>(context, listen: false).authenticate(data: _formData);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignUpInOTP()), (route) => false);
    } catch (e) {
      Get.snackbar("", e.toString(), snackPosition: SnackPosition.BOTTOM);
      _showLoader(false);
    }
    _showLoader(false);
  }

  @override
  Widget build(BuildContext context) {
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
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: InputField(
                    onSubmit: (value) => setState(() => _formData['email_phone'] = value.trim()),
                    onChanged: (value) => setState(() => _formData['email_phone'] = value.trim()),
                    hintText: 'Enter your phone number/Email Id',
                    validator: (String value) {
                      final isNumber = Validator().isNumericUsingTryParse(value);
                      if (isNumber) {
                        if (!Validator().isPhoneValid(value)) return "Please enter a valid Phone Number";
                      } else {
                        if (!Validator().isEmailValid(value)) return "Please enter a valid email";
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: CustomElevatedButton(
                    verticalPadding: 10,
                    onPressed: _submit,
                    child: Text(
                      'SIGN IN',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () async {
                        const _url = 'https://juristally.com/TermsofServices.html';
                        await canLaunch(_url)
                            ? await launch(_url, forceSafariVC: true)
                            : throw 'Could not launch $_url';
                      },
                      child: Text(
                        'By Singing up you agree to the terms and conditions? Terms and Condition',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
