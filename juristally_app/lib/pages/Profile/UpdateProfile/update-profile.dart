import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/pages/Auth/signin_signup.dart';
import 'package:juristally/pages/Profile/UpdateProfile/achievement_form.dart';
import 'package:juristally/pages/Profile/UpdateProfile/education_form.dart';
import 'package:juristally/pages/Profile/UpdateProfile/experience_form.dart';
import 'package:juristally/pages/Profile/UpdateProfile/save_cancel_icons.dart';
import 'package:juristally/widget/InputField/custom-input.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  final UserModel? user;
  UpdateProfile({Key? key, required this.user}) : super(key: key);

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  UserModel? _user;
  bool _isLoading = false;
  @override
  void initState() {
    _user = Provider.of<AuthProvider>(context, listen: false).userProfile;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Update profile details',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      backgroundColor: Color(0xFFE5E5E5),
      body: ListView(
        children: [
          _introForm(),
          ExperienceForm(experiences: _user!.expereinces),
          EducationForm(eductions: _user!.educations),
          AchievementForm(achievements: _user?.achievements),
          Container(
            margin: EdgeInsets.fromLTRB(20, 150, 20, 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(width: 1, color: Colors.redAccent)),
            child: CupertinoButton(
                child: Text(
                  "DEACTIVATE",
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () async {
                  setState(() => _isLoading = true);
                  final isDeactivated = await Provider.of<AuthProvider>(context, listen: false).deactivateAccount();
                  setState(() => _isLoading = false);
                  isDeactivated
                      ? Navigator.pushNamedAndRemoveUntil(context, SignUpSignIn.routeName, (route) => false)
                      : Get.snackbar(
                          "",
                          "Account can not be deactivated!",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                        );
                }),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(width: 1, color: Colors.redAccent)),
            child: CupertinoButton(
                child: Text(
                  "SIGN OUT",
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).signout();
                  Navigator.pushNamedAndRemoveUntil(context, SignUpSignIn.routeName, (route) => false);
                }),
          )
        ],
      ),
    );
  }

  final _intoFormKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  bool _isAdding = false;
  _submit() async {
    if (!_intoFormKey.currentState!.validate()) return;
    _intoFormKey.currentState!.save();
    setState(() => _isAdding = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).updateUser(data: _formData);
    } catch (e) {
      Get.snackbar("", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
    setState(() => _isAdding = false);
  }

  _introForm() {
    print(_user?.fullName);
    return Form(
      key: _intoFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: ExpansionTile(
          collapsedBackgroundColor: Colors.white,
          backgroundColor: Colors.white,
          title: Text("Introduction"),
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: InputField(
                onSubmit: (value) => setState(() => _formData['full_name'] = value),
                initialValue: _user?.fullName,
                hintText: "Name",
                validator: (value) {
                  if (value.isEmpty)
                    return "Please enter you full name";
                  else
                    return null;
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: InputField(
                onSubmit: (value) {
                  _formData['designation'] = value;
                },
                initialValue: _user?.designation,
                hintText: "Designation",
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: InputField(
                onSubmit: (value) => setState(() => _formData['summary'] = value),
                initialValue: _user?.summary,
                hintText: "Bio...",
                maxLines: 5,
              ),
            ),
            SaveCancelIconButton(save: _submit, cancel: () {}, isAdding: _isAdding)
          ],
        ),
      ),
    );
  }
}
