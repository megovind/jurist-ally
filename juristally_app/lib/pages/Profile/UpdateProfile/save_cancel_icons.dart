import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SaveCancelIconButton extends StatelessWidget {
  final Function? save, cancel;
  final bool isAdding;
  const SaveCancelIconButton(
      {Key? key,
      required this.save,
      required this.cancel,
      this.isAdding = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            onTap: () => cancel!.call(),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.clear,
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
          SizedBox(width: 10),
          isAdding
              ? Container(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(),
                )
              : IconButton(
                  icon: Icon(
                    Icons.check,
                    size: 30,
                    color: Color(0xFF6dde93),
                  ),
                  onPressed: () => save?.call(),
                )
        ],
      ),
    );
  }
}
