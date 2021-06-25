import 'package:control_pad/views/joystick_view.dart';
import 'package:flutter/material.dart';

class ManeuverButton extends StatelessWidget {
  final double size;
  final Function onDirectionChange;
  ManeuverButton({this.size, this.onDirectionChange});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: JoystickView(
        size: size,
        showArrows: false,
        opacity: 0.8,
        backgroundColor: Theme.of(context).primaryColor,
        innerCircleColor: Theme.of(context).splashColor,
      ),
    );
  }
}
