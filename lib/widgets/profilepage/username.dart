import 'package:flutter/material.dart';

class Username extends StatelessWidget {
  final String name;
  final String username;

  Username({
    @required this.name,
    @required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Color(0xFF282728),
              fontWeight: FontWeight.w800,
              fontSize: 23,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          Text(
            '@' + username,
            style: TextStyle(
              color: Color(0xFF485777),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
