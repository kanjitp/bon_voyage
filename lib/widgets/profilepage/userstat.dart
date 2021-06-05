import 'package:flutter/material.dart';

class UserStat extends StatelessWidget {
  final int memNum;
  final int followerNum;
  final int followingNum;

  UserStat({
    @required this.memNum,
    @required this.followerNum,
    @required this.followingNum,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.025),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                memNum.toString(),
                style: TextStyle(
                  color: Color(0xFF485777),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: mediaQuery.size.height * 0.005,
              ),
              Text(
                'Memories',
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(width: mediaQuery.size.width * 0.10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    followerNum.toString(),
                    style: TextStyle(
                      color: Color(0xFF485777),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    width: mediaQuery.size.width * 0.02,
                  ),
                  Text(
                    'Followers',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: mediaQuery.size.height * 0.015),
              Row(
                children: [
                  Text(
                    followingNum.toString(),
                    style: TextStyle(
                      color: Color(0xFF485777),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    width: mediaQuery.size.width * 0.02,
                  ),
                  Text(
                    'Following',
                    style: TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
