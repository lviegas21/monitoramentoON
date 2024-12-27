import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextFieldRequest extends StatelessWidget {
  final TextInputType keyboardType;
  final Rx<TextEditingController> controller;
  final String hintText;
  final bool isEnabled;
  final bool isRequired;
  final EdgeInsetsGeometry padding;

  const TextFieldRequest({
    Key? key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.isEnabled = false,
    this.isRequired = false,
    this.padding = const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: padding,
        child: TextFormField(
          enabled: isEnabled,
          controller: controller.value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isEnabled ? null : Colors.black54,
          ),
          keyboardType: keyboardType,
          validator: isRequired 
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Este campo é obrigatório';
                }
                return null;
              }
            : null,
          decoration: InputDecoration(
            labelText: hintText,
            labelStyle: TextStyle(
              color: isEnabled ? Theme.of(context).primaryColor : Colors.black54,
              fontSize: 16,
            ),
            hintText: controller.value.text,
            filled: true,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black38,
            ),
            fillColor: isEnabled 
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.surface.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.3,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1.3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              gapPadding: 0.0,
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 1.3,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.black26,
                width: 1.3,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.3,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
