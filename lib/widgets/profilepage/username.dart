import 'package:flutter/material.dart';

class Username extends StatelessWidget {
  final String firstname;
  final String lastname;
  final String username;

  Username({
    @required this.firstname,
    @required this.lastname,
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
            firstname + ' ' + lastname,
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
