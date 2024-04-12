import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomCheckBox extends StatelessWidget {
  final Function? onTap, onChanged;
  final bool? isSelected;
  final String labelText;
  const CustomCheckBox({Key? key, this.onTap, required this.onChanged, this.isSelected = false, this.labelText = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => onChanged!.call(isSelected),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              side: BorderSide(color: Colors.blueGrey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              value: isSelected,
              onChanged: (value) => onChanged!.call(value),
            ),
            Container(
              child: Text(
                labelText,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
