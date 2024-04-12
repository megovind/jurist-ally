import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/models/drop-down.model.dart';
import 'package:juristally/pages/Profile/UpdateProfile/save_cancel_icons.dart';
import 'package:juristally/widget/Checkbox/checkbox.dart';
import 'package:juristally/widget/InputField/custom-input.dart';
import 'package:juristally/widget/InputField/date-field.dart';
import 'package:juristally/widget/InputField/location-input.dart';
import 'package:juristally/widget/dropdown/drop_down.dart';
import 'package:provider/provider.dart';

class ExperienceForm extends StatefulWidget {
  final List<ExperienceModel>? experiences;
  ExperienceForm({Key? key, required this.experiences}) : super(key: key);

  @override
  _ExperienceFormState createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  DropDownModel? _selectedExTypes;
  List<DropDownModel> _expTypes = experienceTypes;
  final _addressController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _positionController = TextEditingController();
  final _companyController = TextEditingController();
  bool _isAdding = false;
  bool _isDeleting = false;
  bool _isPresent = false;
  Map<String, dynamic> _addressData = {};
  Map<String, dynamic> _formData = {};
  List<ExperienceModel>? _experiences = [];
  ExperienceModel? _selectedExperience;

  @override
  void initState() {
    super.initState();
    _experiences = widget.experiences;
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
    setState(() {
      _isAdding = true;
      _formData['is_present'] = _isPresent;
      _formData['type'] = _selectedExTypes?.type;
      _formData['location'] = _addressData;
    });
    try {
      final _newExp = await Provider.of<AuthProvider>(context, listen: false)
          .updateAddEexperince(data: _formData, id: _selectedExperience?.id);
      if (_selectedExperience?.id != null) {
        int? index = _experiences!.indexWhere((element) => element.id == _selectedExperience?.id);
        setState(() {
          _experiences!.insert(index, _newExp);
        });
      } else {
        setState(() {
          _experiences!.insert(0, _newExp);
        });
      }
    } catch (e) {
      print(e);
      _snackBar(e.toString());
    }
    setState(() => _isAdding = false);
    _clearFields();
  }

  _deleteExperience({String? id}) async {
    setState(() => _isDeleting = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).deleteExeperience(id: id);
      setState(() => _experiences!.removeWhere((element) => element.id == id));
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
      _startDateController.clear();
      _endDateController.clear();
      _isPresent = false;
      _selectedExperience = null;
      _positionController.clear();
      _companyController.clear();
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
          title: Text("Experience"),
          children: [
            Container(
              child: ListView.builder(
                itemCount: _experiences!.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final exp = _experiences![index];
                  return ListTile(
                      leading: Icon(CupertinoIcons.building_2_fill),
                      title: Text("${exp.position}, ${exp.company}", style: TextStyle(fontSize: 14)),
                      subtitle: Text(
                        "${DateFormat.yM().format(exp.startDate ?? DateTime.now())} - ${exp.isCurrently ? 'Currently working' : DateFormat.yM().format(exp.endDate ?? DateTime.now())} ${exp.location?.place}",
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isDeleting
                              ? CircularProgressIndicator()
                              : IconButton(
                                  onPressed: () => _deleteExperience(id: exp.id),
                                  icon: Icon(CupertinoIcons.delete, color: Colors.redAccent, size: 16)),
                          IconButton(
                            onPressed: () => setState(() {
                              _positionController.text = exp.position ?? "";
                              _companyController.text = exp.company ?? "";
                              _selectedExperience = exp;
                              _startDateController.text = exp.startDate.toString();
                              _endDateController.text = exp.endDate.toString();
                              _isPresent = exp.isCurrently;
                              _selectedExTypes = _expTypes.firstWhere((el) => el.type == exp.type);
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
                onSubmit: (value) => setState(() => _formData['designation'] = value),
                controller: _positionController,
                validator: (value) {
                  if (value.isEmpty)
                    return "Please enter position name";
                  else
                    return null;
                },
                hintText: "Position Name",
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: CustomDropDownInput(
                list: _expTypes,
                selectedItem: _selectedExTypes,
                ignore: false,
                onChanged: (value) => setState(() {
                  _formData['type'] = value.type;
                  _selectedExTypes = value;
                }),
                onSaved: (value) => setState(() => _selectedExTypes = value),
                isValidate: true,
                hintText: 'Select Employement Type',
                validateMessage: 'Please select employement type',
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: InputField(
                onSubmit: (value) => setState(() => _formData['company_name'] = value),
                controller: _companyController,
                validator: (value) {
                  if (value.isEmpty)
                    return "Please enter company name";
                  else
                    return null;
                },
                hintText: "Company Name",
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: DateField(
                onChanged: (value) => setState(() {
                  _formData['start_date'] = value.toString();
                  _startDateController.text = value.toString();
                }),
                hintLabel: "Start Date",
                controller: _startDateController,
                validateMessage: "Please select start date",
              ),
            ),
            CustomCheckBox(
              onChanged: (value) => setState(() => _isPresent = value),
              isSelected: _isPresent,
              labelText: "I am currently working in this role? ",
            ),
            !_isPresent
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: DateField(
                      onChanged: (value) => setState(() {
                        _formData['end_date'] = value.toString();
                        _endDateController.text = value.toString();
                      }),
                      hintLabel: "End Date",
                      controller: _endDateController,
                      validateMessage: "Please select end date",
                    ),
                  )
                : Container(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: LocationField(
                onSelectedSuggestion: _onSelectedSuggestion,
                controller: _addressController,
                validateMessage: "Please select location",
              ),
            ),
            SaveCancelIconButton(save: _submit, cancel: _clearFields, isAdding: _isAdding)
          ],
        ),
      ),
    );
  }
}
