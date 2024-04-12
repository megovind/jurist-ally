import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DateField extends StatefulWidget {
  final Function? onSaved, onChanged;
  final TextEditingController? controller;
  final String? label, hintLabel, validateMessage;
  final String? initialValue;
  final bool isObscure, readOnly;
  final TextInputType? inputType;
  final Widget? suffixIcon;
  final Color? filledColor, borderColor, textColor;
  final int? lines, hintMaxlines;
  final double contentPadding;
  final TextCapitalization? textCapitalization;

  DateField({
    Key? key,
    this.onSaved,
    required this.onChanged,
    this.controller,
    this.isObscure = false,
    this.readOnly = false,
    this.label,
    this.inputType,
    this.initialValue,
    this.hintLabel,
    this.suffixIcon,
    this.filledColor,
    this.textColor = Colors.black,
    this.borderColor,
    this.lines,
    this.hintMaxlines,
    this.validateMessage,
    this.contentPadding = 10,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  _DateFieldState createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  DateTime? _currentDate = DateTime.now();

  _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _currentDate ?? DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != _currentDate) widget.onChanged!.call(pickedDate);
    setState(() {
      _currentDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController? _controller = TextEditingController();
    _controller.text = widget.controller!.text.split(" ").first;
    return Container(
      child: GestureDetector(
        onTap: () => _pickDate(),
        child: AbsorbPointer(
          child: TextFormField(
            controller: _controller,
            obscureText: widget.isObscure,
            style: TextStyle(color: widget.textColor),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(widget.contentPadding),
              hintText: widget.hintLabel ?? "",
              filled: true,
              hintMaxLines: widget.hintMaxlines ?? 1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              fillColor: widget.filledColor ?? Colors.white,
              suffixIcon: widget.suffixIcon,
            ),
            // onSaved: (String? value) => widget.onSaved!.call(value),
            keyboardType: widget.inputType,
            textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
            maxLines: widget.lines ?? 1,
            onChanged: (value) => widget.onChanged!.call(value),
            readOnly: widget.readOnly,
            validator: (String? value) {
              if (value != null && value.isEmpty)
                return widget.validateMessage;
              else
                return null;
            },
          ),
        ),
      ),
    );
  }
}
