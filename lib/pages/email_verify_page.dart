import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_planner/services/auth.dart';
import 'package:meal_planner/services/settings.dart';
import 'package:meal_planner/shared/constants.dart';

class EmailVerifyPage extends StatefulWidget {
  const EmailVerifyPage({Key? key}) : super(key: key);

  @override
  _EmailVerifyPageState createState() => _EmailVerifyPageState();
}

class _EmailVerifyPageState extends State<EmailVerifyPage> {
  late Timer _timer;

  @override
  void didChangeDependencies() {
    _timer = Timer.periodic(Duration(seconds: 10), _timerHandler);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _timerHandler(timer) async {
    if (!mounted) return;

    YogaSettings settings = Provider.of<YogaSettings>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Loading user again ... '),
      duration: Duration(milliseconds: 1000),
    ));

    AuthService().userReload();
    bool _verified = AuthService().currentUser()!.emailVerified;
    print(_verified.toString());
    if (_verified) settings.setUserVerified(_verified);
  }

  @override
  Widget build(BuildContext context) {
    dynamic user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Meal Easy'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              children: [
                SizedBox(height: 40),
                Image.asset(
                  "assets/icon/meal_easy_icon.png",
                  height: 80,
                  width: 80,
                ),
                SizedBox(height: 40),
                Container(
                  decoration: boxDeco,
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  child: Text(
                      'Waiting for email verification ...\n\nPlease check the email inbox for ${user.email}, and click on the verification link.'),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                    onPressed: () {
                      user.sendEmailVerification();
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: Text('Sent email to ${user.email}'),
                          title: Text('Email sent'),
                        ),
                      );
                    },
                    child: Text('Send verification email again')),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    AuthService().signOut();
                  },
                  child: Text('Back to sign in'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
