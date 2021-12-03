import 'package:Passenger/screens/auth/sign_in.dart';
import 'package:Passenger/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:Passenger/models/user.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //return either Home or Authenticate widget
    final user = Provider.of<Usermodel?>(context);

    // return either the Home or Authenticate widget
    if (user == null) {
      return SignIn();
    } else {
      return Home();
    }
  }
}
