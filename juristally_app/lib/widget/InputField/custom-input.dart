import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class InputField extends StatelessWidget {
  final TextEditingController? controller;
  final Function? onSubmit;
  final Function? onChanged, onTap, validator;
  final bool isObscure, isReadOnly;
  final String? initialValue, hintText;
  final TextInputType inputType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final double contentPadding;
  const InputField(
      {this.initialValue,
      this.maxLines = 1,
      this.textCapitalization = TextCapitalization.none,
      this.inputType = TextInputType.text,
      this.controller,
      this.hintText,
      this.onChanged,
      this.onTap,
      this.validator,
      this.isObscure = false,
      this.isReadOnly = false,
      this.contentPadding = 10,
      this.onSubmit,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        onTap: () => onTap?.call(),
        onSaved: (value) => onSubmit!.call(value),
        controller: controller,
        validator: (value) => validator?.call(value),
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        keyboardType: inputType,
        readOnly: isReadOnly,
        initialValue: initialValue,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(contentPadding),
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white12),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
