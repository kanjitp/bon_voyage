import 'package:flutter/material.dart';

class FillOutlineButton extends StatelessWidget {
  final bool isFilled;
  final VoidCallback press;
  final String text;

  const FillOutlineButton(
      {this.isFilled = false, this.press, this.text, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: Colors.black),
      ),
      elevation: isFilled ? 0 : 2,
      color: isFilled ? Theme.of(context).primaryColor : Colors.transparent,
      onPressed: press,
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontSize: 12),
      ),
    );
  }
}
