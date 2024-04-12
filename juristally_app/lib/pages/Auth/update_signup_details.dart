import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/helper/validator.dart';
import 'package:juristally/pages/Auth/logo.dart';
import 'package:juristally/pages/Landing/landing.dart';
import 'package:juristally/widget/Button/custom-elevated-button.dart';
import 'package:juristally/widget/InputField/custom-input.dart';
import 'package:juristally/widget/Loader/progressbar_mk.dart';
import 'package:provider/provider.dart';

class SignUpUserUpdate extends StatefulWidget {
  SignUpUserUpdate({Key? key}) : super(key: key);

  @override
  _SignUpSignInState createState() => _SignUpSignInState();
}

class _SignUpSignInState extends State<SignUpUserUpdate> {
  final _key = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {"type": "other"};
  bool _isLoading = false;
  _showLoader(bool value) => setState(() => _isLoading = value);

  _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    _showLoader(true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).updateUser(data: _formData);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LandingPage()), (route) => false);
    } catch (e) {
      Get.snackbar("", "Please check entered details", snackPosition: SnackPosition.BOTTOM);
    }
    _showLoader(false);
  }
  // 9155328999

  @override
  Widget build(BuildContext context) {
    final emPh = Provider.of<AuthProvider>(context, listen: false).emailPhone;
    final emailPhone = emPh!.contains('@');
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
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppLogo(),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: InputField(
                    onSubmit: (value) => setState(() => _formData['full_name'] = value),
                    onChanged: (value) => setState(() => _formData['full_name'] = value),
                    hintText: ' Full Name',
                    validator: (String value) {
                      if (value.isEmpty) return 'Please enter you full name';
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: InputField(
                    onSubmit: (value) => setState(() {
                      !emailPhone ? _formData['email'] = value : _formData['phone_number'] = value;
                    }),
                    onChanged: (value) => setState(() {
                      !emailPhone ? _formData['email'] = value : _formData['phone_number'] = value;
                    }),
                    hintText: !emailPhone ? "Email" : 'Phone Number',
                    inputType: !emailPhone ? TextInputType.emailAddress : TextInputType.phone,
                    validator: (String value) {
                      final isNumber = Validator().isNumericUsingTryParse(value);
                      if (isNumber && emailPhone) {
                        if (!Validator().isPhoneValid(value)) return "Please enter a valid Phone Number";
                      } else {
                        if (!Validator().isEmailValid(value)) return "Please enter a valid email";
                      }
                    },
                  ),
                ),
                CustomElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    'UPDATE',
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
