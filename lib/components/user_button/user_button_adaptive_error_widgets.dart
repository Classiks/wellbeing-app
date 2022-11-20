import 'package:flutter/material.dart';

class ErrorsafeTextField extends StatelessWidget {
  const ErrorsafeTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.showError,
    this.autofocus = false,
    this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
  });

  final bool showError;
  final String labelText;
  final TextEditingController controller;
  final bool autofocus;
  final void Function(String)? onChanged;
  final bool obscureText;
  final IconButton? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        focusedBorder: conditionalErrorBorder(showError),
        enabledBorder: conditionalErrorBorder(showError),
        labelText: labelText,
        suffixIcon: suffixIcon,
      ),
      autofocus: autofocus,
      onChanged: onChanged,
      obscureText: obscureText,
    );
  }
}

class OptionalErrorFeedback extends StatelessWidget {
  const OptionalErrorFeedback({
    super.key,
    required this.showError,
    required this.errorText,
  }); 

  final bool showError;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return showError
      ? ErrorText(errorText)
      : Container();
  }
}


class ErrorUnderlineInputBorder extends UnderlineInputBorder {
  const ErrorUnderlineInputBorder({
    super.borderSide = const BorderSide(color: Colors.red),
  });
}

InputBorder? conditionalErrorBorder(show) => show
  ? const ErrorUnderlineInputBorder()
  : null;  


class ErrorText extends Text {
  const ErrorText(super.data, {
    super.key,
    super.style = const TextStyle(color: Colors.red),
  });
}
