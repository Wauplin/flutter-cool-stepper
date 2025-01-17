library cool_stepper;

export 'package:cool_stepper/src/models/cool_step.dart';
export 'package:cool_stepper/src/models/cool_stepper_config.dart';

import 'package:cool_stepper/src/models/cool_step.dart';
import 'package:cool_stepper/src/models/cool_stepper_config.dart';
import 'package:cool_stepper/src/widgets/cool_stepper_view.dart';
import 'package:flutter/material.dart';

/// CoolStepper
class CoolStepper extends StatefulWidget {
  /// The steps of the stepper whose titles, subtitles, content always get shown.
  ///
  /// The length of [steps] must not change.
  final List<CoolStep> steps;

  /// Actions to take when the final stepper is passed
  final VoidCallback onCompleted;

  /// Padding for the content inside the stepper
  final EdgeInsetsGeometry contentPadding;

  /// CoolStepper config
  final CoolStepperConfig config;

  /// This determines if or not a snackbar displays your error message if validation fails
  ///
  /// default is false
  final bool showErrorSnackbar;

  const CoolStepper({
    Key key,
    @required this.steps,
    @required this.onCompleted,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.config = const CoolStepperConfig(
      backText: "PREV",
      nextText: "NEXT",
      stepText: "STEP",
      ofText: "OF",
      finalText: "FINISH",
      backTextList: null,
      nextTextList: null,
    ),
    this.showErrorSnackbar = false,
  }) : super(key: key);

  @override
  _CoolStepperState createState() => _CoolStepperState();
}

class _CoolStepperState extends State<CoolStepper> {
  PageController _controller = PageController();

  int currentStep = 0;

  @override
  void dispose() {
    _controller.dispose();
    _controller = null;
    super.dispose();
  }

  switchToPage(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  bool _isFirst(int index) {
    return index == 0;
  }

  bool _isLast(int index) {
    return widget.steps.length - 1 == index;
  }

  _onStep({
    String Function() onValidation,
    VoidCallback onValid,
  }) {
    String validation = onValidation();

    if (validation == null) {
      onValid();
    } else {
      // Show Error Snakbar
      if (widget.showErrorSnackbar) {
        final snackBar = SnackBar(content: Text(validation ?? "Error!"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  onStepNext() {
    _onStep(
      onValidation: widget.steps[currentStep].onNextValidation,
      onValid: () {
        if (!_isLast(currentStep)) {
          setState(() {
            currentStep++;
          });
          FocusScope.of(context).unfocus();
          switchToPage(currentStep);
        } else {
          widget.onCompleted();
        }
      },
    );
  }

  onStepBack() {
    _onStep(
      onValidation: widget.steps[currentStep].onPrevValidation,
      onValid: () {
        if (!_isFirst(currentStep)) {
          setState(() {
            currentStep--;
          });
          switchToPage(currentStep);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Expanded(
      child: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: widget.steps.map((step) {
          return CoolStepperView(
            step: step,
            contentPadding: widget.contentPadding,
            config: widget.config,
          );
        }).toList(),
      ),
    );

    final counter = Container(
      child: Text(
        "${widget.config.stepText ?? 'STEP'} ${currentStep + 1} ${widget.config.ofText ?? 'OF'} ${widget.steps.length}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    String getNextLabel() {
      String nextLabel;
      if (_isLast(currentStep)) {
        nextLabel = widget.config.finalText ?? 'FINISH';
      } else {
        if (widget.config.nextTextList != null) {
          nextLabel = widget.config.nextTextList[currentStep];
        } else {
          nextLabel = widget.config.nextText ?? 'NEXT';
        }
      }
      return nextLabel;
    }

    String getPrevLabel() {
      String backLabel;
      if (_isFirst(currentStep)) {
        backLabel = '';
      } else {
        if (widget.config.backTextList != null) {
          backLabel = widget.config.backTextList[currentStep - 1];
        } else {
          backLabel = widget.config.backText ?? 'PREV';
        }
      }
      return backLabel;
    }

    final buttons = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _getNavButton(getPrevLabel(), Colors.grey, onStepBack),
          counter,
          _getNavButton(getNextLabel(), Colors.green, onStepNext),
        ],
      ),
    );

    return Container(
      child: Column(
        children: [content, buttons],
      ),
    );
  }
}

TextButton _getNavButton(String label, Color color, onPressed) {
  return TextButton(
    style: TextButton.styleFrom(
      padding: EdgeInsets.all(10.0),
    ),
    onPressed: onPressed,
    child: Text(
      label,
      style: TextStyle(
        color: color,
      ),
    ),
  );
}
