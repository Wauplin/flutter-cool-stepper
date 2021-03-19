import 'package:flutter/widgets.dart';

class CoolStep {
  final String title;
  final String subtitle;
  final Widget content;
  final String Function() onPrevValidation;
  final String Function() onNextValidation;

  CoolStep({
    @required this.title,
    @required this.subtitle,
    @required this.content,
    @required this.onPrevValidation,
    @required this.onNextValidation,
  });
}
