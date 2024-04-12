import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:juristally/models/auth_model.dart';
import 'package:juristally/pages/Profile/UpdateProfile/save_cancel_icons.dart';
import 'package:juristally/widget/Checkbox/checkbox.dart';
import 'package:juristally/widget/InputField/custom-input.dart';
import 'package:juristally/widget/InputField/date-field.dart';
import 'package:juristally/widget/InputField/location-input.dart';
import 'package:provider/provider.dart';

class EducationForm extends StatefulWidget {
  final List<EducationModel>? eductions;
  EducationForm({Key? key, required this.eductions}) : super(key: key);

  @override
  _EducationFormState createState() => _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _instituteController = TextEditingController();
  final _degreeController = TextEditingController();

  bool _isAdding = false;
  bool _isPresent = false;
  bool _isDeleting = false;
  Map<String, dynamic> _addressData = {};
  Map<String, dynamic> _formData = {};
  List<EducationModel>? _educations;
  EducationModel? _selectedEducation;

  @override
  void initState() {
    _educations = widget.eductions;
    super.initState();
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

  _snackBar(message) => Get.snackbar("", message);

  _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    try {
      setState(() {
        _isAdding = true;
        _formData['is_present'] = _isPresent;
        _formData['location'] = _addressData;
      });
      print(_formData);
      final _newEdu = await Provider.of<AuthProvider>(context, listen: false)
          .updateAddEducation(data: _formData, id: _selectedEducation?.id);
      if (_selectedEducation?.id != null) {
        int? index = _educations!.indexWhere((element) => element.id == _selectedEducation?.id);
        _educations!.insert(index, _newEdu);
      } else {
        _educations?.insert(0, _newEdu);
      }
    } catch (e) {
      print(e);
      _snackBar(e.toString());
    }
    setState(() => _isAdding = false);
    _clearFields();
  }

  _deleteEducation({String? id}) async {
    setState(() => _isDeleting = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).deleteEducation(id: id);
      setState(() => _educations!.removeWhere((element) => element.id == id));
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
      _instituteController.clear();
      _degreeController.clear();
      _isPresent = false;
      _selectedEducation = null;
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
            title: Text("Education"),
            children: [
              Container(
                child: ListView.builder(
                  itemCount: _educations!.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final edu = _educations![index];
                    return ListTile(
                      leading: Icon(CupertinoIcons.rectangle_dock),
                      title: Text("${edu.degree}, ${edu.instituteName}", style: TextStyle(fontSize: 14)),
                      subtitle: Text(
                        "${DateFormat.yM().format(edu.startDate ?? DateTime.now())} - ${edu.isPursuing ? 'Present' : DateFormat.yM().format(edu.endDate ?? DateTime.now())}",
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isDeleting
                              ? CircularProgressIndicator()
                              : IconButton(
                                  onPressed: () => _deleteEducation(id: edu.id),
                                  icon: Icon(CupertinoIcons.delete, color: Colors.redAccent, size: 14)),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedEducation = edu;
                                _startDateController.text = edu.startDate.toString();
                                _endDateController.text = edu.endDate.toString();
                                _instituteController.text = edu.instituteName ?? "";
                                _degreeController.text = edu.degree ?? "";
                                _isPresent = edu.isPursuing;
                              });
                            },
                            icon: Icon(CupertinoIcons.pencil),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: InputField(
                  onSubmit: (value) => setState(() => _formData['institute_name'] = value),
                  controller: _instituteController,
                  hintText: "Institute Name",
                  validator: (value) {
                    if (value.isEmpty)
                      return "Please enter institute name";
                    else
                      return null;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: InputField(
                  onSubmit: (value) => setState(() => _formData['stream'] = value),
                  controller: _degreeController,
                  hintText: "Degree",
                  validator: (value) {
                    if (value.isEmpty)
                      return "Please enter your degree";
                    else
                      return null;
                  },
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
                labelText: "I am currently pursuing this degree.",
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
              SaveCancelIconButton(isAdding: _isAdding, save: () => _submit(), cancel: _clearFields)
            ],
          ),
        ));
  }
}
