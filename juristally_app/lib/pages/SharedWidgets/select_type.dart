import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:juristally/models/drop-down.model.dart';
import 'package:juristally/widget/dropdown/drop_down.dart';

class SelectType extends StatelessWidget {
  final DropDownModel selectedItem;
  final Function? onSaved;
  final String? hint, validateMessage;
  const SelectType({
    Key? key,
    required this.onSaved,
    required this.selectedItem,
    this.validateMessage,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomDropDownInput(
      list: typesList,
      selectedItem: selectedItem,
      onSaved: onSaved,
      onChanged: onSaved,
      hintText: "Profesion",
      validateMessage: "Please select your profession",
    );
  }
}
