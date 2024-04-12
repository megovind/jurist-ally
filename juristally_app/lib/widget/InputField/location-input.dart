import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:juristally/Providers/AuthProvider/auth_providers.dart';
import 'package:provider/provider.dart';

class LocationField extends StatelessWidget {
  final FocusNode? node;
  final TextEditingController? controller;
  final Function? onSelectedSuggestion, getLocation;
  final String? validateMessage;
  final String? initialValue;
  final bool? isSuffixIcon;
  final double contentPadding;
  const LocationField(
      {this.initialValue,
      this.isSuffixIcon,
      this.getLocation,
      this.node,
      this.controller,
      this.onSelectedSuggestion,
      this.validateMessage,
      this.contentPadding = 10,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
          controller: controller,
          focusNode: node,
          decoration: InputDecoration(
            hintText: "Location",
            filled: true,
            contentPadding: EdgeInsets.all(contentPadding),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            fillColor: Colors.white,
          ),
        ),
        suggestionsCallback: (pattern) async {
          return await Provider.of<AuthProvider>(context, listen: false)
              .searchAddress(pattern: pattern);
        },
        itemBuilder: (context, dynamic suggestion) {
          return suggestion != null
              ? ListTile(title: Text(suggestion['formatted_address']))
              : Container();
        },
        transitionBuilder: (context, suggestionBox, controller) {
          return suggestionBox;
        },
        onSuggestionSelected: (suggestion) =>
            onSelectedSuggestion!.call(suggestion),
        validator: (value) {
          if (value!.isEmpty)
            return validateMessage;
          else
            return null;
        },
      ),
    );
  }
}
