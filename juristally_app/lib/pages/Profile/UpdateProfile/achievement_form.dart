import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/pages/Profile/UpdateProfile/save_cancel_icons.dart';
import 'package:juristally/widget/InputField/custom-input.dart';
import 'package:juristally/widget/InputField/date-field.dart';
import 'package:juristally/widget/InputField/location-input.dart';
import 'package:provider/provider.dart';

class AchievementForm extends StatefulWidget {
  final List<AchievementModel>? achievements;
  AchievementForm({Key? key, required this.achievements}) : super(key: key);

  @override
  _AchievementFormState createState() => _AchievementFormState();
}

class _AchievementFormState extends State<AchievementForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isAdding = false;
  bool _isDeleting = false;
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _eventController = TextEditingController();
  final _descriptionController = TextEditingController();

  Map<String, dynamic> _addressData = {};
  Map<String, dynamic> _formData = {};
  List<AchievementModel>? _achievements = [];
  AchievementModel? _selectedAchievement;

  @override
  void initState() {
    super.initState();
    _achievements = widget.achievements;
  }

  _onSelectedSuggestion(suggestions) {
    final placename = suggestions["name"];
    final coords = suggestions['geometry']['location'];
    final address = suggestions['formatted_address'];
    setState(() {
      _addressController.text = address;
      _addressData['address'] = address;
      _addressData['latitude'] = coords['lat'];
      _addressData['langitude'] = coords['lng'];
      _addressData['place_name'] = placename;
    });
  }

  _snackBar(message) => Get.snackbar("", message, snackPosition: SnackPosition.BOTTOM);

  _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isAdding = true);
    try {
      final _ach = await Provider.of<AuthProvider>(context, listen: false)
          .updateAddAchievement(data: _formData, id: _selectedAchievement?.id);
      if (_selectedAchievement?.id != null) {
        int? index = _achievements!.indexWhere((element) => element.id == _selectedAchievement?.id);
        _achievements!.insert(index, _ach);
      } else {
        _achievements!.insert(0, _ach);
      }
    } catch (e) {
      Get.snackbar("", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
    setState(() => _isAdding = false);
    _clearFields();
  }

  _deleteAcheivement({String? id}) async {
    setState(() => _isDeleting = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).deleteAchievement(id: id);
      setState(() => _achievements!.removeWhere((element) => element.id == id));
    } catch (e) {
      print(e);
      _snackBar(e.toString());
    }
    setState(() => _isDeleting = false);
  }

  _clearFields() {
    setState(() {
      _formData.clear();
      _addressController.clear();
      _dateController.clear();
      _eventController.clear();
      _descriptionController.clear();
      _selectedAchievement = null;
      _formData.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: ExpansionTile(
          collapsedBackgroundColor: Colors.white,
          backgroundColor: Colors.white,
          title: Text("Achievement"),
          children: [
            Container(
              child: ListView.builder(
                itemCount: _achievements!.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final achievement = _achievements![index];
                  return ListTile(
                      leading: Icon(CupertinoIcons.person_2_alt),
                      title: Text("${achievement.eventName}", style: TextStyle(fontSize: 14)),
                      subtitle: Text(
                        "${DateFormat.yM().format(achievement.date ?? DateTime.now())}, ${achievement.location?.place ?? ''}",
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isDeleting
                              ? CircularProgressIndicator()
                              : IconButton(
                                  onPressed: () => _deleteAcheivement(id: achievement.id),
                                  icon: Icon(CupertinoIcons.delete, color: Colors.redAccent, size: 16)),
                          IconButton(
                            onPressed: () => setState(() {
                              _eventController.text = achievement.eventName ?? "";
                              _descriptionController.text = achievement.description ?? "";
                              _selectedAchievement = achievement;
                              _dateController.text = achievement.date.toString();
                            }),
                            icon: Icon(CupertinoIcons.pencil, size: 14),
                          )
                        ],
                      ));
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: InputField(
                onSubmit: (value) => setState(() => _formData['event_name'] = value),
                controller: _eventController,
                hintText: "Event Name",
                validator: (value) {
                  if (value.isEmpty)
                    return "Please enter event name";
                  else
                    return null;
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: DateField(
                onChanged: (value) => setState(() {
                  _formData['date'] = value.toString();
                  _dateController.text = value.toString();
                }),
                controller: _dateController,
                hintLabel: "Date",
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: LocationField(
                onSelectedSuggestion: _onSelectedSuggestion,
                controller: _addressController,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: InputField(
                maxLines: 4,
                onSubmit: (value) => setState(() => _formData['desscription'] = value),
                controller: _descriptionController,
                hintText: "Description",
              ),
            ),
            SaveCancelIconButton(isAdding: _isAdding, save: _submit, cancel: () {})
          ],
        ),
      ),
    );
  }
}
