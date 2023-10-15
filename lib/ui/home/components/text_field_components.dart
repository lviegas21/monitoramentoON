import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextFielRequest extends StatelessWidget {
  final TextInputType keyboardType;
  final Rx<TextEditingController>? controller;
  final String? hintText;

  final bool isRequired;

  const TextFielRequest({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: TextFormField(
          enabled: false,
          controller: controller?.value,
          style: Theme.of(context).textTheme.bodyText1,
          keyboardType: keyboardType,
          validator: (value) {},
          decoration: InputDecoration(
            labelText: hintText!,
            labelStyle: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            hintText: controller?.value.text,
            filled: true,
            hintStyle: Theme.of(context).textTheme.bodyText1,
            fillColor: Theme.of(context).backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 1.3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Theme.of(context).secondaryHeaderColor, width: 1.3),
            ),
            focusedBorder: OutlineInputBorder(
              gapPadding: 0.0,
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 1.3),
            ),
          ),
        ),
      ),
    );
  }
}
