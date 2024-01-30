import 'package:flutter/material.dart';

import '../constants/colors.dart';

class InputTextField extends StatelessWidget {
  const InputTextField({
    super.key,
    required this.controller,
    required this.onFieldSubmittedValue,
    required this.onValidate,
    required this.keyBoardType,
    required this.hint,
    required this.obscureText,
    required this.iconData,
    this.enable = true,
  });

  final TextEditingController controller;
  final FormFieldSetter onFieldSubmittedValue;
  final FormFieldValidator onValidate;
  final IconData iconData;

  final TextInputType keyBoardType;
  final String hint;
  final bool obscureText;
  final bool enable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: enable,
        onFieldSubmitted: onFieldSubmittedValue,
        validator: onValidate,
        obscureText: obscureText,
        keyboardType: keyBoardType,
        style: Theme.of(context)
            .textTheme
            .titleSmall!
            .copyWith(fontSize: 16, height: 1),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Icon(iconData),
          ),
          contentPadding: const EdgeInsets.all(15),
          hintStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.primaryTextTextColor.withOpacity(0.8),
              height: 1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.textFieldDefaultFocus,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black38, width: 3),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
                color: AppColors.textFieldDefaultBorderColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.alertColor, width: 2),
          ),
        ),
      ),
    );
  }
}
