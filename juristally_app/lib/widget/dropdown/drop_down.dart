import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:juristally/models/drop-down.model.dart';

class CustomDropDownInput extends StatefulWidget {
  final List<DropDownModel>? list;
  final bool ignore, isValidate;
  final Function? onChanged, onSaved;
  final String? validateMessage, hintText, labelText;
  final DropDownModel? selectedItem;
  CustomDropDownInput({
    Key? key,
    required this.list,
    required this.onSaved,
    required this.hintText,
    required this.selectedItem,
    this.ignore = false,
    this.onChanged,
    this.isValidate = false,
    this.labelText,
    this.validateMessage,
  }) : super(key: key);

  @override
  _CustomDropDownInputState createState() => _CustomDropDownInputState();
}

class _CustomDropDownInputState extends State<CustomDropDownInput> {
  List<DropdownMenuItem<DropDownModel>>? _dropDownItems;

  @override
  void initState() {
    super.initState();
    _dropDownItems = buildDropDownMenuItems(widget.list ?? []);
  }

  List<DropdownMenuItem<DropDownModel>> buildDropDownMenuItems(List dropDownItems) {
    List<DropdownMenuItem<DropDownModel>> items = [];
    for (DropDownModel dropDownItem in dropDownItems) {
      items.add(DropdownMenuItem(value: dropDownItem, child: Text(dropDownItem.value)));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: IgnorePointer(
      ignoring: widget.ignore,
      child: DropdownButtonFormField<dynamic>(
        isExpanded: false,
        isDense: false,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          isDense: false,
          hintText: widget.hintText,
          filled: true,
          focusedBorder: OutlineInputBorder(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(color: Colors.white, width: 0, style: BorderStyle.none),
          ),
          fillColor: Colors.white,
        ),
        // selectedItemBuilder: (context) {
        //   return [
        //     Text(
        //       widget.selectedItem.value,
        //       style: TextStyle(color: Colors.blue),
        //     )
        //   ];
        // },
        value: widget.selectedItem,
        items: _dropDownItems,
        onChanged: (value) => widget.onChanged!.call(value),
        onSaved: (value) => widget.onSaved!.call(value),
        validator: (value) {
          if (widget.isValidate) {
            if (value == null) {
              return widget.validateMessage;
            }
          }
          return null;
        },
      ),
    ));
  }
}
